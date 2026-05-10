# Deploying a Potato Annotation Server

This guide covers deploying a [Potato](https://github.com/davidjurgens/potato) annotation task on the lab server using:

- **systemd user service** — runs Potato in the background and restarts it automatically
- **nginx** — reverse proxy that exposes the app at a URL prefix like `/<APP_PREFIX>/`

```
Browser → nginx (port 80) → Potato (port <PORT>)
```

---

## Step 1: Set up your task directory

Put your task in a self-contained directory:

```
/home/<YOUR_USERNAME>/potato/examples/<TASK_TYPE>/<TASK_DIR>/
├── config.yaml
└── data/
    └── input.jsonl
```

**Potato rejects data files outside the task project directory.** If your config points to a file in an unrelated folder, you'll get:

```text
ConfigSecurityError ... outside the project directory
```

Keep your data inside the task directory or a subdirectory of it.

---

## Step 2: Create `config.yaml`

A minimal config for a task deployed behind nginx at `/<APP_PREFIX>/`:

```yaml
server:
  host: 127.0.0.1
  port: <PORT>
  base_path: /<APP_PREFIX>
  workers: 2
  timeout: 120

server_name: potato annotator
annotation_task_name: <TASK_NAME>

task_dir: .
site_dir: default
task_layout: layouts/task_layout.html

output_annotation_dir: data/annotations/<TASK_DIR>/
output_annotation_format: jsonl

annotation_codebook_url: ""

data_files:
  - data/input.jsonl

user_config:
  allow_all_users: true
  users: []

admin_api_key: "<CHANGE_ME>"
```

Key notes:
- `host: 127.0.0.1` keeps the app local — nginx handles the public-facing side
- `port` should be a free port (e.g. `9001`, `9002`, `9003`) — check with `ss -ltnp | grep <PORT>`
- `base_path` must match the nginx prefix exactly (e.g. `/<APP_PREFIX>`)
- `task_dir: .` works when you run Potato from the task folder
- `output_annotation_dir` should be inside the task directory
- When switching datasets, use a fresh `output_annotation_dir` to avoid stale annotation data interfering

---

## Step 3: Test the task manually first

Before setting up systemd, confirm the task starts from the shell:

```bash
cd /home/<YOUR_USERNAME>/potato/examples/<TASK_TYPE>/<TASK_DIR>
/home/<YOUR_USERNAME>/miniconda3/envs/<POTATO_ENV>/bin/python -m potato interface config.yaml
```

Then test locally on the server:

```bash
curl -I http://127.0.0.1:<PORT>/<APP_PREFIX>/
```

---

## Step 4: Create a user systemd service

Use a **user** service, not a system-wide service. On this server, SELinux blocks system services from executing Conda Python out of a home directory. User services avoid this.

Create the directory if needed:

```bash
mkdir -p ~/.config/systemd/user
```

Create the service file:

```bash
nano ~/.config/systemd/user/potato-<APP_PREFIX>.service
```

```ini
[Unit]
Description=Potato <APP_PREFIX>
After=network.target

[Service]
WorkingDirectory=/home/<YOUR_USERNAME>/potato/examples/<TASK_TYPE>/<TASK_DIR>
ExecStart=/home/<YOUR_USERNAME>/miniconda3/envs/<POTATO_ENV>/bin/python -m potato interface config.yaml
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

---

## Step 5: Enable lingering

User services stop running when you log out unless lingering is enabled. Check:

```bash
loginctl show-user <YOUR_USERNAME> | grep Linger
```

You want `Linger=yes`. If not, ask a server admin to enable it for your account.

---

## Step 6: Start the service

```bash
systemctl --user daemon-reload
systemctl --user enable --now potato-<APP_PREFIX>
systemctl --user status potato-<APP_PREFIX>
```

Check logs if it doesn't start:

```bash
journalctl --user -u potato-<APP_PREFIX> -n 50 --no-pager
```

---

## Step 7: Add the nginx location block

The nginx .config is located in the /etc/nginx/conf.d directory in the antoniak-lab.conf file. Add this inside the existing `server { }` block in the nginx config file:

```nginx
location = /<APP_PREFIX> {
    return 301 /<APP_PREFIX>/;
}

location /<APP_PREFIX>/ {
    proxy_pass http://127.0.0.1:<PORT>;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Prefix /<APP_PREFIX>;
}
```

Note: use **no trailing slash** on `proxy_pass` when `base_path` is set in Potato's config — this preserves the prefix in the upstream request.

Then reload:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Test:

```bash
curl -I http://<SERVER_HOSTNAME>/<APP_PREFIX>/
```

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `ConfigSecurityError ... outside the project directory` | `data_files` points outside the task folder | Copy data into the task directory |
| CSS/JS broken under a prefix | Frontend generating root-absolute asset paths | Ensure `base_path` is set; pass `X-Forwarded-Prefix` from nginx; or use direct port |
| Service won't start | Wrong Conda path, bad working directory, typo in `config.yaml`, port in use | Check `journalctl --user -u potato-<APP_PREFIX> -n 100 --no-pager` |
| Works internally, not externally | Firewall, VPN, binding to `127.0.0.1`, nginx not reloaded | Check each in order |
| SELinux errors | System service trying to execute Conda Python from home directory | Switch to a user service |

---

## Deployment checklist

1. Put task and data in one self-contained directory
2. Set a free port in `config.yaml`
3. Set `base_path` in `config.yaml` to match the nginx prefix
4. Test the task manually from the shell
5. Create a user systemd service
6. `systemctl --user daemon-reload`
7. `systemctl --user enable --now potato-<APP_PREFIX>`
8. Add nginx location block
9. `sudo nginx -t && sudo systemctl reload nginx`
10. Open the URL and check logs if needed
