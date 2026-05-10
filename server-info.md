# Lab Server Info

## About the server

<!-- Why does this server exist? What problem does it solve for the lab? -->
<!-- Example: "The antoniak-lab server provides a shared hosting environment for lab members to deploy annotation tools, demos, and research applications accessible from any browser." -->

**Purpose:**
> _Fill in here._

**Who maintains it:**
> _Fill in here (e.g., lab PI, a specific lab member, IT contact)._

**How to get access:**
> _Fill in here (e.g., request an account from X, SSH key process, etc.)._

---

## What can you put on the server?

The server is well-suited for:

- **Annotation tools** (e.g., Potato tasks for data labeling)
- **Flask/web apps** (demos, research tools, lightweight APIs)
- **Static or semi-static sites** served through nginx

Considerations:
- Each app should run on its own port (`9001`, `9002`, `5001`, etc.) — check for conflicts before deploying
- Apps run as user systemd services under your own account
- Heavy compute (model inference, large data processing) should go on dedicated compute resources, not this server

---

## Server specs

| | |
|---|---|
| **Hostname** | `<SERVER_HOSTNAME>` |
| **OS** | `<OS and version, e.g., Rocky Linux 8>` |
| **CPU** | `<e.g., 16-core Intel Xeon>` |
| **RAM** | `<e.g., 64 GB>` |
| **Storage** | `<e.g., 2 TB /home, shared NFS>` |
| **IP address** | `<SERVER_IP>` |

---

## Access

**SSH:**

```bash
ssh <YOUR_USERNAME>@<SERVER_HOSTNAME>
```

**Web:** Applications are served at:

```
http://<SERVER_HOSTNAME>/<YOUR_USERNAME>/<APP_NAME>/
```

**VPN:** <!-- Is a VPN required? Fill in if applicable. -->
> _Fill in here._

---

## Software environment

- **nginx** — already installed and running, shared across all users
- **firewalld** — manages port access
- **SELinux** — enforcing (this is why user services are used instead of system services)
- **Conda** — each user manages their own environments under `~/miniconda3/`

---

## Notes and constraints

<!-- Add any lab-specific rules, quirks, or gotchas here. -->
<!-- Examples: -->
<!-- - "Don't run anything on port 8080, it's reserved." -->
<!-- - "Notify X before deploying a new app so they can document the port." -->
<!-- - "The server reboots for maintenance on the first Sunday of each month." -->

> _Fill in here._
