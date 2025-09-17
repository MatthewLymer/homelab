# nginx configuration

The volume mounts are specifically written to not interfere with the default nginx image.

The default image provides:

* `/etc/nginx/conf.d/default.conf`
* `/docker-entrypoint.d/...`

Templating was leveraged at `/etc/nginx/conf.d/templates` which copies to `/etc/nginx/conf.d/`.

To avoid conflicts, a simple `default.conf.template` was made to load the `default.conf` from the `custom` folder.

This ensures the `/etc/nginx/conf.d/custom` mount can be bound without worrying about any files being copied there, furthermore, it allows for a read-only mount.

The `docker-entrypoint.d` scripts add watch capabilities to automatically reload the nginx config.
