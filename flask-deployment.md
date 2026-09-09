# Deploying a Flask App with Gunicorn

This guide walks through deploying a Flask app on the lab server behind nginx using:

- **Gunicorn** — a Python web server that runs your Flask app
- **systemd user service** — keeps Gunicorn running in the background and restarts it on crashes/reboots
- **nginx** — reverse proxy that receives browser requests and forwards them to Gunicorn

---

## Step 1: Write your Flask app for production

In `app.py`, make sure the app can bind to all interfaces for local testing:

```python
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=<PORT>, debug=True)
```

**Pick a port that isn't already in use.** Check what's running:

```bash
ss -tlnp | grep <PORT>
```

---

## Step 2: Create a conda environment and install dependencies

```bash
conda create -n <ENV_NAME> python=3.x -y
conda activate <ENV_NAME>
pip install flask gunicorn  # etc
```

Gunicorn must be installed in the same environment as your app. Find its path after installing:

```bash
which gunicorn
# e.g. /home/<YOUR_USERNAME>/miniconda3/envs/<ENV_NAME>/bin/gunicorn
```

---

## Step 3: Create the systemd user service file

Create this directory if it doesn't exist:

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
