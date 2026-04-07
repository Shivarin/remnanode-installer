# Remnawave Node — one-command install

[Russian / Русский](README.md) · **English**

This script installs **Docker**, **nano**, and dependencies, then opens an editor so you can paste the ready-made **`docker-compose.yml`** from the [Remnawave](https://docs.rw/docs/install/remnawave-node/) panel. After you save the file, the node container starts — you do not need to hand-compose anything on the server.

**OS:** aimed at **Ubuntu** (typical VPS: Ubuntu 22.04 / 24.04 LTS). The same flow works on **Debian** and other distros with **`apt-get`**. On RHEL / Alpine / Arch without `apt`, install `nano` / `curl` and Docker yourself, then run the script.

Anyone deploying a node on a **fresh VPS** can follow the same steps.

---

## Requirements

| Requirement | Why |
|-------------|-----|
| **Linux** VPS | Where the node runs |
| **root** over **SSH** | Script installs packages and Docker |
| **Ubuntu** (recommended) or **Debian** with `apt` | Auto-installs `nano`, `curl` via `apt-get` |
| Normal **SSH** session in a terminal | **Interactive** TTY required (**nano** will open) |
| Node already created in Remnawave Panel | YAML is copied from there |

---

## Step 1 — Remnawave Panel (before you SSH to the server)

1. Log in to **Remnawave Panel**.
2. Open **Nodes** → **Management**.
3. Click **+** (add node), fill in the fields (node port, name, etc.).
4. Click **Copy docker-compose.yml** — the full file is copied to the clipboard.
5. **Do not finish the wizard with “Create” yet** — install the node on the server first (step 2), then return to the panel and complete creation (step 3).

Keep the copied text somewhere or leave it in the clipboard — you will paste it in nano.

---

## Step 2 — Server: install commands

Connect to the VPS over SSH (PuTTY, Terminal, Windows Terminal — any **real** terminal is fine).

Run **these three lines** (copy-paste as a block):

```bash
curl -fsSL https://raw.githubusercontent.com/Shivarin/remnanode-installer/main/install.sh -o /root/install-remnanode.sh
chmod +x /root/install-remnanode.sh
sudo /root/install-remnanode.sh
```

**Why not `curl ... | bash`:** if you feed **`curl`** straight into **`bash`**, the script runs **without an interactive TTY** — **nano will not open**. Save the file first (`-o /root/install-remnanode.sh`), then run **`bash /root/install-remnanode.sh`** — that is intentional.

### What happens next (automatically)

1. **nano**, **curl**, and **ca-certificates** are installed (**Ubuntu / Debian** via `apt`).
2. If Docker is missing, it is installed from [get.docker.com](https://get.docker.com).
3. Directory **`/opt/remnanode`** and file **`docker-compose.yml`** are created.
4. **nano** opens: **paste the full YAML** from the panel (**Ctrl+Shift+V** / right-click depending on client).
5. Save: **Ctrl+O**, **Enter**, exit: **Ctrl+X**.
6. **`docker compose pull`** and **`docker compose up -d`** run — the node starts in Docker.

If you leave the file empty and exit, the script stops with an error — you must paste the YAML from the panel.

---

## Step 3 — Panel again: finish creating the node

1. Go back to this node’s card in Remnawave.
2. Click **Next**, choose **Config Profile**.
3. Click **Create** (or the equivalent in your panel version).

Without this, the panel may not link the config profile to the node.

---

## Firewall

On the node server, open **`NODE_PORT`** (as in `docker-compose` / panel) **only** to the **Remnawave Panel IP** — otherwise the panel cannot reach the node API. Details: [official documentation](https://docs.rw/docs/install/remnawave-node/).

---

## Check and logs

```bash
cd /opt/remnanode && docker compose ps
cd /opt/remnanode && docker compose logs -f -t
```

---

## Troubleshooting

| Issue | What to do |
|-------|------------|
| Script says **no TTY** | Do not use `curl ... | bash` without a proper SSH terminal; SSH in and run the three commands from step 2. |
| **nano** did not open | Ensure the SSH session is interactive (not all automation provides a PTY). |
| Not **Ubuntu / Debian** (no `apt`) | Install Docker and `curl` manually per your distro docs, then run `sudo bash install.sh` again. |
| **docker compose** error | Ensure the YAML from the panel was pasted in full, not truncated. |

---

## Alternative: clone the repo

```bash
git clone https://github.com/Shivarin/remnanode-installer.git
cd remnanode-installer
sudo bash install.sh
```

Then the same **nano** + YAML flow.

---

## Environment variables (optional)

| Variable | Default |
|----------|---------|
| `INSTALL_DIR` | `/opt/remnanode` |
| `COMPOSE_FILE` | `docker-compose.yml` |

Example custom install directory:

```bash
sudo env INSTALL_DIR=/srv/remnanode bash /root/install-remnanode.sh
```

(Adjust the script path if you used a different location.)

---

## Security

Do not commit or publish a production **`docker-compose.yml`** from the server if it contains **secrets** (keys, tokens) — that is full access to the node.

---

## Links

- [Remnawave Node — installation](https://docs.rw/docs/install/remnawave-node/)
- Script source: [github.com/Shivarin/remnanode-installer](https://github.com/Shivarin/remnanode-installer)
