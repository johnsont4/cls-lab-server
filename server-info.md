# Lab Server Info

## About the server

<!-- Why does this server exist? What problem does it solve for the lab? -->
<!-- Example: "The antoniak-lab server provides a shared hosting environment for lab members to deploy annotation tools, demos, and research applications accessible from any browser." -->

**Purpose:**
> This server provides a shared hosting environment for members of Antoniak lab to deploy annotation tools, demos, and other applications that can be accessed from anywhere.

**Who maintains it:**
> Advait and Teagan primarily, but anyone in the Antoniak lab can help.

**How to get access:**
> _need more info, come back later_

---

## What can you put on the server?

The server is well-suited for:

- **Annotation tools** (e.g., Potato tasks for data labeling)
- **Flask/web apps** (demos, research tools, lightweight APIs)
- **Static or semi-static sites** served through nginx

Considerations:
- Each app should run on its own port (`9001`, `9002`, `5001`, etc.) — check for conflicts before deploying. See helpful commands in the commands.md file.
- Apps run as user systemd services under your own account
- Heavy compute (model inference, large data processing) should go on dedicated compute resources, not this server

---

## Server specs

| | |
|---|---|
| **Hostname** | `antoniak-lab.colorado.edu` |
| **OS** | `<OS and version, e.g., Rocky Linux 8>` |
| **CPU** | `<e.g., 16-core Intel Xeon>` |
| **RAM** | `<e.g., 64 GB>` |
| **Storage** | `<e.g., 2 TB /home, shared NFS>` |
| **IP address** | `<SERVER_IP>` |

---

## Access

**SSH:**

```bash
ssh <YOUR_USERNAME>@antoniak-lab.colorado.edu
```

**Web:** Applications are served at:

```
http://antoniak-lab.colorado.edu/<YOUR_USERNAME>/<APP_NAME>/
```

**VPN:**
> If you are off CU wifi, you need to get set up on the CU VPN in order to SSH into the server. You can download the VPN [here](https://oit.colorado.edu/services/network-internet-services/vpn)

---

## Software environment

- **nginx** — already installed and running, shared across all users
- **firewalld** — manages port access
- **SELinux** — enforcing (this is why user services are used instead of system services)
- **Conda** — each user manages their own environments under `~/miniconda3/`

---

## Notes and constraints


> Anything?
