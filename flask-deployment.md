# Deploying a Flask App with Gunicorn

This guide walks through deploying a Flask app on the lab server behind nginx using:

- **Gunicorn** — a Python web server that runs your Flask app
- **systemd user service** — keeps Gunicorn running in the background and restarts it on crashes/reboots
- **nginx** — reverse proxy that receives browser requests and forwards them to Gunicorn

```
Browser → nginx (port 80) → Gunicorn (port <PORT>) → Flask app
```

---

## Step 1: Write your Flask app for production

In `app.py`, make sure the app can bind to all interfaces for local testing:

```python
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=<PORT>, debug=True)
```

`host="0.0.0.0"` matters when running with `python app.py` directly. With Gunicorn, the bind address is set in the service file, but keep it here for local testing.

**Pick a port that isn't already in use.** Port 5000 is taken by macOS AirPlay on some systems. Check what's running:

```bash
ss -tlnp | grep <PORT>
```

---

## Step 2: Create a conda environment and install dependencies

```bash
conda create -n <ENV_NAME> python=3.11 -y
conda activate <ENV_NAME>
pip install flask gunicorn  # add your other dependencies here
```

Gunicorn must be installed in the same environment as your app. Find its path after installing:

```bash
which gunicorn
# e.g. /home/<YOUR_USERNAME>/miniconda3/envs/<ENV_NAME>/bin/gunicorn
```

---

## Step 3: Create the systemd user service file

Because home directories have restricted permissions (`drwx------`), system-level services (running as root) cannot access your files. Use a **user service** instead.

Create the directory if it doesn't exist:

```bash
mkdir -p ~/.config/systemd/user/
```

Create the service file:

```bash
nano ~/.config/systemd/user/<APP_NAME>.service
```

Paste this template, replacing the placeholders:

```ini
[Unit]
Description=<APP_DESCRIPTION>
After=network.target

[Service]
WorkingDirectory=/home/<YOUR_USERNAME>/<PATH_TO_YOUR_APP>
ExecStart=/home/<YOUR_USERNAME>/miniconda3/envs/<ENV_NAME>/bin/gunicorn -w 2 -b 127.0.0.1:<PORT> app:app
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

Key notes:
- **Use full absolute paths** — systemd does not expand `~`
- `-b 127.0.0.1:<PORT>` binds to localhost only, nginx handles the public-facing side
- `app:app` means "find the Flask object named `app` inside `app.py`"

---

## Step 4: Enable and start the service

```bash
systemctl --user daemon-reload
systemctl --user enable <APP_NAME>
systemctl --user start <APP_NAME>
systemctl --user status <APP_NAME>
```

**Check it's actually running:**

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:<PORT>/
```

You should get `200`. If you get `000`, Gunicorn isn't running. Check logs:

```bash
journalctl --user -u <APP_NAME> -n 50 --no-pager
```

Common errors:

| Error | Cause |
|---|---|
| `Permission denied` on Gunicorn path | Used `sudo systemctl` instead of `systemctl --user`, or included `User=` in the service file |
| `status=216/GROUP` | Included `User=<YOUR_USERNAME>` in a user service file, just remove it |
| `No such file or directory` | Wrong path to Gunicorn or `WorkingDirectory` |

---

## Step 5: Add the nginx location block

nginx is already running on the server. Add a location block for your app inside the existing `server { }` block in the nginx config file. The nginx .config is located in the /etc/nginx/conf.d directory in the antoniak-lab.conf file.

```nginx
location = /<YOUR_USERNAME>/<APP_NAME> {
    return 301 /<YOUR_USERNAME>/<APP_NAME>/;
}

location /<YOUR_USERNAME>/<APP_NAME>/ {
    proxy_pass http://127.0.0.1:<PORT>/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix /<YOUR_USERNAME>/<APP_NAME>;
}
```

Key notes:
- The first block (`return 301`) redirects requests without a trailing slash. Without it, the path without a trailing slash will 404
- The trailing slash on `proxy_pass http://127.0.0.1:<PORT>/` strips the URL prefix before passing to Gunicorn, so Flask receives `/` instead of `/<YOUR_USERNAME>/<APP_NAME>/`
- The `proxy_set_header` lines pass the original request metadata (real client IP, protocol, etc.) to your app

---

## Step 6: Reload nginx

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Always run `nginx -t` first. It's a dry run that catches config errors before you reload.

Your app will be live at:

```
http://antoniak-lab.colorado.edu/<YOUR_USERNAME>/<APP_NAME>/
```
