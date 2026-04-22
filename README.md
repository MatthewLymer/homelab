# homelab

Self-hosted infrastructure running on TrueNAS (on-premises), managed via Docker Compose. DNS, SSL, and secrets are handled through GCP.

**Domain:** `lymer.ca` with wildcard subdomains `*.lymer.ca`

## Services

| Subdomain | Service | Notes |
|-----------|---------|-------|
| `status.*` | nginx health check | Public |
| `budget.*` | Actual Budget | Public |
| `media.*` | Jellyfin | Public |
| `auth.*` | oauth2-proxy | Google auth handler for nginx |

## Authentication

Services are protected by [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/) using nginx forward auth. oauth2-proxy delegates authentication to Google and sets a session cookie scoped to `.lymer.ca`, shared across all subdomains.

To protect a new nginx service, add `include /etc/nginx/conf.d/auth.inc;` to its server block.

## Deployment

```bash
./publish.sh
```

This syncs configs to TrueNAS, pulls secrets from GCP Secret Manager, and brings containers up.

## GCP Secret Manager

The following secrets must exist in Secret Manager before deploying.

| Secret name | Description |
|-------------|-------------|
| `onprem-certbot_sa_key` | GCP service account key for certbot DNS-01 |
| `onprem-homelink_sa_key` | GCP service account key for homelink DNS updater |
| `oauth2-proxy-google-client-id` | Google OAuth2 client ID |
| `oauth2-proxy-google-client-secret` | Google OAuth2 client secret |
| `oauth2-proxy-cookie-secret` | Random 32-byte secret for session cookie encryption |
| `oauth2-proxy-allowed-emails` | Newline-separated list of allowed Gmail addresses |

### Setting up oauth2-proxy secrets

**1. Create a Google OAuth2 client**

1. Go to [Google Cloud Console](https://console.cloud.google.com) > **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth 2.0 Client ID**
3. Application type: **Web application**
4. Under **Authorized redirect URIs**, add: `https://auth.lymer.ca/oauth2/callback`
5. Click **Create** — copy the Client ID and Client Secret

**2. Create the secrets in GCP Secret Manager**

```bash
# From Google Console
echo -n "YOUR_CLIENT_ID" | gcloud secrets create oauth2-proxy-google-client-id \
  --project=matthewlymer-production --data-file=-

echo -n "YOUR_CLIENT_SECRET" | gcloud secrets create oauth2-proxy-google-client-secret \
  --project=matthewlymer-production --data-file=-

# Generate a random cookie encryption key
openssl rand -base64 32 | tr -d '\n' | gcloud secrets create oauth2-proxy-cookie-secret \
  --project=matthewlymer-production --data-file=-

# Newline-separated list of Gmail addresses that are allowed to log in
printf "you@gmail.com" | gcloud secrets create oauth2-proxy-allowed-emails \
  --project=matthewlymer-production --data-file=-
```

**Updating an existing secret value:**

```bash
echo -n "NEW_VALUE" | gcloud secrets versions add SECRET_NAME \
  --project=matthewlymer-production --data-file=-
```
