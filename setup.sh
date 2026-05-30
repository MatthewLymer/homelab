#!/bin/bash
# Interactive setup script for all dependencies required by publish.sh.

set -euo pipefail

GOOGLE_PROJECT=$(grep 'GOOGLE_PROJECT=' .env | cut -d'=' -f2-)

# ── helpers ──────────────────────────────────────────────────────────────────

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

secret_exists() {
    gcloud secrets describe "$1" --project="$GOOGLE_PROJECT" &>/dev/null
}

secret_has_version() {
    gcloud secrets versions list "$1" --project="$GOOGLE_PROJECT" \
        --filter="state=ENABLED" --format="value(name)" 2>/dev/null | grep -q .
}

ensure_secret_resource() {
    local secret_id=$1
    if ! secret_exists "$secret_id"; then
        echo "  Creating secret resource: $secret_id"
        gcloud secrets create "$secret_id" \
            --project="$GOOGLE_PROJECT" \
            --replication-policy=automatic \
            --quiet
    fi
}

add_secret_version() {
    local secret_id=$1
    local value=$2
    printf '%s' "$value" | gcloud secrets versions add "$secret_id" \
        --project="$GOOGLE_PROJECT" \
        --data-file=- \
        --quiet
}

prompt_secret() {
    local secret_id=$1
    local prompt_text=$2
    local value
    while true; do
        read -rsp "  $prompt_text: " value
        echo
        if [[ -n "$value" ]]; then
            break
        fi
        yellow "  Value cannot be empty. Try again."
    done
    echo "$value"
}

# ── prerequisite checks ───────────────────────────────────────────────────────

bold "==> Checking prerequisites"

if ! command -v gcloud &>/dev/null; then
    red "ERROR: gcloud CLI not found. Install from https://cloud.google.com/sdk/docs/install"
    exit 1
fi
green "  gcloud OK"

if ! command -v docker &>/dev/null; then
    red "ERROR: docker not found. Install Docker before deploying."
    exit 1
fi
green "  docker OK"

if ! command -v ssh &>/dev/null; then
    red "ERROR: ssh not found."
    exit 1
fi
green "  ssh OK"

if [[ ! -f .env ]]; then
    red "ERROR: .env file not found. Create it with DOMAIN, ZONE, and GOOGLE_PROJECT."
    exit 1
fi
green "  .env OK (GOOGLE_PROJECT=$GOOGLE_PROJECT)"

# ── gcloud auth ───────────────────────────────────────────────────────────────

bold "==> Verifying gcloud authentication"
if ! gcloud auth print-access-token &>/dev/null; then
    yellow "  Not authenticated. Running 'gcloud auth login'..."
    gcloud auth login
fi

# Verify project is accessible
if ! gcloud projects describe "$GOOGLE_PROJECT" &>/dev/null; then
    red "ERROR: Cannot access GCP project '$GOOGLE_PROJECT'. Check your credentials and project ID."
    exit 1
fi
green "  Authenticated and project '$GOOGLE_PROJECT' is accessible"

# ── SSH connectivity ──────────────────────────────────────────────────────────

bold "==> Checking SSH access to TrueNAS (deployer@truenas.local)"
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes deployer@truenas.local true 2>/dev/null; then
    yellow "  WARNING: Cannot SSH to deployer@truenas.local without a password prompt."
    yellow "  publish.sh requires passwordless SSH. Set up your SSH key:"
    yellow "    ssh-copy-id deployer@truenas.local"
    read -rp "  Continue anyway? [y/N] " cont
    if [[ "$cont" != "y" && "$cont" != "Y" ]]; then
        exit 1
    fi
else
    green "  SSH OK"
fi

# ── Terraform-managed secrets (check only) ────────────────────────────────────

bold "==> Checking Terraform-managed secrets"
echo "  These are created and populated by Terraform. Run 'terraform apply' in"
echo "  infrastructure/wl-certbot and infrastructure/wl-homelink if they are missing."
echo

for secret_id in onprem-certbot_sa_key onprem-homelink_sa_key; do
    if ! secret_exists "$secret_id" || ! secret_has_version "$secret_id"; then
        yellow "  MISSING: $secret_id"
        yellow "    Run: cd infrastructure/wl-certbot && terraform init && terraform apply"
        yellow "         cd infrastructure/wl-homelink && terraform init && terraform apply"
    else
        green "  OK: $secret_id"
    fi
done

# ── Transmission OpenVPN credentials ─────────────────────────────────────────

bold "==> Transmission OpenVPN credentials"
echo "  The secret resources are created by Terraform (infrastructure/wl-transmission)."
echo "  Values must be set manually."
echo

for secret_id in transmission-openvpn-username transmission-openvpn-password; do
    if ! secret_exists "$secret_id"; then
        yellow "  Secret resource missing: $secret_id"
        yellow "  Run: cd infrastructure/wl-transmission && terraform init && terraform apply"
        yellow "  Then re-run this script to set the value."
        continue
    fi

    if secret_has_version "$secret_id"; then
        green "  OK: $secret_id (already has a value)"
    else
        case "$secret_id" in
            transmission-openvpn-username)
                value=$(prompt_secret "$secret_id" "OpenVPN username")
                ;;
            transmission-openvpn-password)
                value=$(prompt_secret "$secret_id" "OpenVPN password")
                ;;
        esac
        add_secret_version "$secret_id" "$value"
        green "  Set: $secret_id"
    fi
done

# ── Sonarr API key (for Unpackerr) ───────────────────────────────────────────

bold "==> Sonarr API key (for Unpackerr)"
echo "  Find your Sonarr API key at: Settings → General → Security → API Key"
echo

secret_id="sonarr-api-key"
ensure_secret_resource "$secret_id"
if secret_has_version "$secret_id"; then
    green "  OK: $secret_id (already set)"
else
    value=$(prompt_secret "$secret_id" "Sonarr API Key")
    add_secret_version "$secret_id" "$value"
    green "  Set: $secret_id"
fi

# ── Radarr API key (for Unpackerr) ───────────────────────────────────────────

bold "==> Radarr API key (for Unpackerr)"
echo "  Find your Radarr API key at: Settings → General → Security → API Key"
echo

secret_id="radarr-api-key"
ensure_secret_resource "$secret_id"
if secret_has_version "$secret_id"; then
    green "  OK: $secret_id (already set)"
else
    value=$(prompt_secret "$secret_id" "Radarr API Key")
    add_secret_version "$secret_id" "$value"
    green "  Set: $secret_id"
fi

# ── oauth2-proxy secrets ──────────────────────────────────────────────────────

bold "==> oauth2-proxy secrets"

# cookie secret — auto-generated
secret_id="oauth2-proxy-cookie-secret"
ensure_secret_resource "$secret_id"
if secret_has_version "$secret_id"; then
    green "  OK: $secret_id (already set)"
else
    echo "  Generating random cookie secret..."
    cookie_secret=$(openssl rand -base64 32)
    add_secret_version "$secret_id" "$cookie_secret"
    green "  Generated and stored: $secret_id"
fi

# Google OAuth2 client credentials — user must create in Google Cloud Console
echo
yellow "  For oauth2-proxy-google-client-id and oauth2-proxy-google-client-secret:"
yellow "  Create an OAuth 2.0 Client ID in the Google Cloud Console:"
yellow "    https://console.cloud.google.com/apis/credentials"
yellow "  Application type: Web application"
yellow "  Authorized redirect URIs: https://auth.lymer.ca/oauth2/callback"
echo

for secret_id in oauth2-proxy-google-client-id oauth2-proxy-google-client-secret; do
    ensure_secret_resource "$secret_id"
    if secret_has_version "$secret_id"; then
        green "  OK: $secret_id (already set)"
    else
        case "$secret_id" in
            oauth2-proxy-google-client-id)
                value=$(prompt_secret "$secret_id" "Google OAuth2 Client ID")
                ;;
            oauth2-proxy-google-client-secret)
                value=$(prompt_secret "$secret_id" "Google OAuth2 Client Secret")
                ;;
        esac
        add_secret_version "$secret_id" "$value"
        green "  Set: $secret_id"
    fi
done

# allowed emails list
secret_id="oauth2-proxy-allowed-emails"
ensure_secret_resource "$secret_id"
if secret_has_version "$secret_id"; then
    green "  OK: $secret_id (already set)"
else
    echo
    echo "  Enter email addresses allowed to log in (one per line)."
    echo "  Press Ctrl+D when done:"
    allowed_emails=$(</dev/stdin)
    if [[ -z "$allowed_emails" ]]; then
        red "  ERROR: No email addresses entered. At least one is required."
        exit 1
    fi
    add_secret_version "$secret_id" "$allowed_emails"
    green "  Set: $secret_id"
fi

# ── done ─────────────────────────────────────────────────────────────────────

echo
green "==> Setup complete. You can now run ./publish.sh"
