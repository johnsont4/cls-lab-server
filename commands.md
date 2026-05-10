# Useful Server Commands

Quick reference for managing services, checking logs, and working with nginx. Replace `<SERVICE_NAME>` with your actual service name (e.g. `my-flask-app` or `potato-mytask`).

---

## systemctl — managing user services

```bash
# Reload systemd after creating or editing a service file
systemctl --user daemon-reload

# Enable a service to start automatically on login/reboot
systemctl --user enable <SERVICE_NAME>

# Start / stop / restart
systemctl --user start <SERVICE_NAME>
systemctl --user stop <SERVICE_NAME>
systemctl --user restart <SERVICE_NAME>

# Check current status
systemctl --user status <SERVICE_NAME>

# Disable autostart
systemctl --user disable <SERVICE_NAME>
```

> Always run `daemon-reload` after editing a `.service` file before restarting.

---

## journalctl — viewing logs

```bash
# View the last 50 log lines for a service
journalctl --user -u <SERVICE_NAME> -n 50 --no-pager

# View the last 100 lines
journalctl --user -u <SERVICE_NAME> -n 100 --no-pager

# Follow logs in real time (Ctrl+C to exit)
journalctl --user -u <SERVICE_NAME> -f

# View logs since a specific time
journalctl --user -u <SERVICE_NAME> --since "1 hour ago"
journalctl --user -u <SERVICE_NAME> --since "2024-01-01 12:00:00"
```

---

## nginx

```bash
# Test config for syntax errors (always do this before reloading)
sudo nginx -t

# Reload nginx (picks up config changes without dropping connections)
sudo systemctl reload nginx

# Check nginx status
sudo systemctl status nginx

# View nginx error log
sudo tail -n 50 /var/log/nginx/error.log

# View nginx access log
sudo tail -n 50 /var/log/nginx/access.log
```

---

## Ports — checking what's running

```bash
# See what's listening on all ports
ss -tlnp

# Check a specific port
ss -tlnp | grep <PORT>

# Check if something is already using a port before deploying
ss -ltnp | grep <PORT>
```

---

## Lingering — keeping user services alive after logout

```bash
# Check if lingering is enabled for your account
loginctl show-user <YOUR_USERNAME> | grep Linger

# Enable lingering (requires admin/sudo)
sudo loginctl enable-linger <YOUR_USERNAME>
```

Lingering must be enabled for your user services to keep running when you're not logged in.

---

## Conda

```bash
# Find the path to a binary in a conda env (useful for service files)
/home/<YOUR_USERNAME>/miniconda3/envs/<ENV_NAME>/bin/python --version
which gunicorn  # only works when the env is activated

# Activate an environment
conda activate <ENV_NAME>

# List environments
conda env list
```

---

## Quick diagnostics

```bash
# Test if a local service is responding
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:<PORT>/

# Test if a path is accessible through nginx
curl -I http://antoniak-lab.colorado.edu/<APP_PREFIX>/

# Check disk usage in your home directory
du -sh ~/*

# Check overall disk usage
df -h
```
