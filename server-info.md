# Lab Server Info

## About the server

**Purpose:**
> This server provides a shared hosting environment for members of the Culture, Language, & Systems Lab to deploy annotation tools, demos, and other applications that can be accessed from anywhere (not just by CU-affiliates).

**Who maintains it:**
> Advait and Teagan primarily, but anyone in the Culture, Language, & Systems Lab can help. Also reach out to the CS computing resources team (cscihelp@colorado.edu), they've been helpful in setting up the server.

**How to get access:**
> The best way to gain access is to email the [CS computing resources team](https://www.colorado.edu/cs/students/computing-resources-students) (cscihelp@colorado.edu). Jinyoung Park was the IT employee that originally set up the lab server, but there are others in OIT that can grant you access. Originally the server name was antoniak-lab, but we're in the process of changing the name to cls-lb.

---

## What can you put on the server?

- **Annotation tools** (e.g., [Potato](https://github.com/davidjurgens/potato) tasks for data labeling)
- **Flask/web apps** (demos, research tools, lightweight APIs)

Considerations:
- Each app should run on its own port (`9001`, `9002`, `5001`, etc.). Check for conflicts before deploying. See helpful commands in the commands.md file.
- Heavy compute (model inference, large data processing) should go on dedicated compute resources, not this server

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