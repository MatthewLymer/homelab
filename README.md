# homelab

Self-hosted infrastructure running on TrueNAS (on-premises), managed via Docker Compose. DNS, SSL, and secrets are handled through GCP.

**Domain:** `lymer.ca` with wildcard subdomains `*.lymer.ca`

## Services

| Subdomain | Service | Notes |
|-----------|---------|-------|
| `status.*` | nginx health check | Public |
| `budget.*` | Actual Budget | Public |
| `media.*` | Jellyfin | Public |
| `auth.*` | oauth2-proxy | Google OAuth sign-in page |

## Authentication

Some endpoints are protected by Google OAuth via [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/). Signing in at `auth.lymer.ca` sets a shared cookie on `.lymer.ca`, so one login covers all three services.

Sign out at `https://auth.lymer.ca/oauth2/sign_out`.

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
| `oauth2-proxy-google-client-id` | Google OAuth client ID |
| `oauth2-proxy-google-client-secret` | Google OAuth client secret |
| `oauth2-proxy-cookie-secret` | Random secret for cookie encryption |
| `oauth2-proxy-allowed-emails` | Newline-separated list of allowed Google accounts |

### Setting up OAuth secrets

**1. Create the OAuth client** in [GCP Console](https://console.cloud.google.com/apis/credentials) → Create Credentials → OAuth 2.0 Client ID (Web application). Set the authorized redirect URI to `https://auth.lymer.ca/oauth2/callback`.

**2. Store the client credentials:**
```bash
echo -n "your-client-id" | gcloud secrets create oauth2-proxy-google-client-id \
  --project=YOUR_PROJECT --data-file=-

echo -n "your-client-secret" | gcloud secrets create oauth2-proxy-google-client-secret \
  --project=YOUR_PROJECT --data-file=-
```

**3. Generate and store the cookie secret:**
```bash
openssl rand -base64 32 | tr -- '+/' '-_' | gcloud secrets create oauth2-proxy-cookie-secret \
  --project=YOUR_PROJECT --data-file=-
```

**4. Set the allowed email list** (one address per line):
```bash
printf "you@gmail.com\nsomeone@gmail.com" | gcloud secrets create oauth2-proxy-allowed-emails \
  --project=YOUR_PROJECT --data-file=-
```

To update the list later:
```bash
printf "you@gmail.com\nsomeone@gmail.com" | gcloud secrets versions add oauth2-proxy-allowed-emails \
  --project=YOUR_PROJECT --data-file=-
```
