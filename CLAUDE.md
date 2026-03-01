# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Self-hosted homelab infrastructure running on **TrueNAS** (on-premises) with cloud management via **Google Cloud Platform**. Services run in Docker Compose containers, with DNS, SSL, secrets, and backups managed through Terraform and GCP.

**Domain:** `lymer.ca` with wildcard subdomains `*.lymer.ca`

## Common Commands

### Local Development
```bash
docker compose up                    # Start all services locally (uses .data/ for volumes)
docker compose up <service>          # Start a single service
docker compose logs -f <service>     # Follow logs for a service
```

### Production Deployment
```bash
./publish.sh                         # Full deploy: syncs configs, pulls secrets, starts containers
```

### Terraform (inside each module directory)
```bash
terraform init
terraform plan
terraform apply
```

Each workload under `infrastructure/` has its own Terraform state (separate `backend` config per module).

## Architecture

### Deployment Model
- **Local compose:** `docker-compose.yml` is the base; `docker-compose.production.yml` overlays production paths and `restart: unless-stopped` policies.
- **`publish.sh`:** Orchestrates deployment — grants Docker access on TrueNAS, creates remote directories, pulls secrets from GCP Secret Manager, tars/syncs configs, and brings containers up.
- **Secrets:** All credentials fetched from GCP Secret Manager at deploy time and written directly into service subdirectories under `$WORKSPACE_ROOT` on the remote TrueNAS host (e.g. `$WORKSPACE_ROOT/certbot/certbot_sa_key.json`). Containers receive them via read-only volume mounts.

### Services (docker-compose.yml)
| Service | Role | Internal Port | Nginx Subdomain |
|---------|------|--------------|-----------------|
| nginx | Reverse proxy + SSL termination | 13448 (HTTPS), 10808 (HTTP) | — |
| certbot | DNS-01 SSL cert renewal (12h cycle) | — | — |
| homelink | Dynamic DNS updater (15min poll) | — | — |
| autoheal | Restarts unhealthy containers | — | — |
| actual | Budget manager | 5006 | `budget.*` |
| jellyfin | Media server | 8096 | `media.*` |
| transmission | Torrent client + OpenVPN | 9091 | — |
| sonarr | Primary media manager (search, grab, monitor) | 8989 | `sonarr.*` |
| prowlarr | Indexer manager | 9696 | — |

### Nginx Routing Pattern
Nginx uses dynamic `$target` variables resolved via Docker's internal DNS (`resolver 127.0.0.11`) so services can be unavailable without crashing nginx:
```nginx
set $target "http://actual:5006";
proxy_pass $target;
```
Custom configs go in `workloads/nginx/conf.d/` — they're mounted into `/etc/nginx/conf.d/` alongside (not replacing) the default config. See `workloads/nginx/README.md` for details.

Nginx hot-reloads when SSL certificates change (checked every 60 min via `workloads/nginx/docker-entrypoint.d/50-hot-reload.sh`).

### SSL / DNS
- Certbot uses DNS-01 validation via a GCP service account (no port 80/443 needed).
- `homelink` fetches the external IP from `icanhazip.com` and updates the `*.lymer.ca` A record in Cloud DNS.

### Terraform Structure (`infrastructure/`)
Each subdirectory is an independent Terraform module with its own GCS backend:
- `project/` — GCP project, DNS zone, billing, MX records
- `wl-certbot/` — Service account + Secret Manager entry for certbot
- `wl-homelink/` — Service account + Secret Manager entry for homelink
- `wl-transmission/` — OpenVPN credentials in Secret Manager
- `wl-backups/` — Cloud Storage backup infrastructure

### Media Pipeline
Sonarr is the primary media flow: it uses Prowlarr for indexers, triggers Transmission for downloads (into the `/tv-sonarr` directory), and manages its own file organization. Transmission's `on-torrent-done.sh` explicitly skips transfers in `/tv-sonarr` and only organizes manually-initiated downloads via hardlinks into `/data/shows/`, `/data/movies/`, or `/data/other/`. Jellyfin serves the library from shared NAS paths (`/mnt/main/`).

### Finances Automation (`workloads/finances/`)
Standalone Node.js/TypeScript Express app with its own `docker-compose.yml`. Uses Selenium (standalone-chromium) to scrape TD Easyweb accounts. Has a Finite State Machine for MFA flows and stores data in an encrypted volume.

## Key Files
- `docker-compose.yml` — All service definitions
- `docker-compose.production.yml` — Production path/restart overrides
- `.env` — `DOMAIN`, `ZONE`, `GOOGLE_PROJECT` (non-sensitive)
- `publish.sh` — Deployment script; sets `SSH_CREDS=deployer@truenas.local`, `WORKSPACE_ROOT=/mnt/main/home/deployer/homelab`
- `workloads/nginx/conf.d/` — Nginx virtual host configs
- `workloads/transmission/scripts/` — Post-download organization scripts
