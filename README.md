[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![WSL2](https://img.shields.io/badge/Target-WSL2-informational)](#)
[![Status](https://img.shields.io/badge/Project-active-success)](#)

A collection of headless (terminal-only) setup scripts to bootstrap WSL2 development environments per Linux distro with reproducible installs, logging, and no GUI or systemd dependencies.

---


## What's Included (Technologies & Components)

This project currently includes the following technologies and building blocks:

- **WSL2-first automation** for terminal-only development environments.
- **Shell-based installers (`bash`)** for reproducible setup flows.
- **Debian Bookworm implementation** as the production-ready reference distro.
- **Package-list driven provisioning** (for example `apt-core.txt`) to keep installs consistent.
- **Shared shell library utilities** under `shared/lib` for common logic reuse.
- **Environment defaults/config** files to centralize install behavior.
- **Structured distro layout** under `distros/<distro>/<version>/wsl2/` for scalability.
- **Bootstrap dependencies** for fresh images (`wget`, `zip`, `git`) so repository cloning works immediately.
- **No GUI or systemd requirement**, optimized for lightweight headless usage.

<details>
<summary><strong>Current implementation footprint</strong></summary>

- `install.sh` (root entrypoint)
- `distros/debian/bookworm/wsl2/install.sh`
- `distros/debian/bookworm/wsl2/packages/apt-core.txt`
- `distros/debian/bookworm/wsl2/config/defaults.env`
- `shared/lib/common.sh`

</details>

---

---

## Distribution Guide

Use the expandable sections below. Debian is fully documented; other distros are currently marked as work in progress.

<details>
<summary><strong>Debian (Bookworm) | Complete</strong></summary>

### Scope
Debian is the reference workflow for this repository and includes the full setup process.

### Prerequisites (inside Debian WSL)
Run these commands first, especially on a new distro install:

```bash
sudo apt update
sudo apt install -y wget zip git
```

### Full step-by-step

1. **Clone this repository**

   ```bash
   git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
   cd wsl2-dev-distros
   ```

2. **Grant execute permission**

   ```bash
   chmod +x install.sh
   ```

3. **Run the main installer**

   ```bash
   ./install.sh
   ```

4. **Optional: run Debian installer directly**

   ```bash
   chmod +x distros/debian/bookworm/wsl2/install.sh
   ./distros/debian/bookworm/wsl2/install.sh
   ```

### Debian files used by the workflow
- `distros/debian/bookworm/wsl2/install.sh`
- `distros/debian/bookworm/wsl2/packages/apt-core.txt`
- `distros/debian/bookworm/wsl2/config/defaults.env`
- `shared/lib/common.sh`

### Development Tools Included (Debian Reference)

The Debian setup includes a practical developer toolchain out of the box:

#### Core system and network tools
- `ca-certificates`, `curl`, `wget`, `git`
- `gnupg`, `dirmngr`, `lsb-release`, `software-properties-common`

#### Build and compilation tools
- `build-essential`, `make`, `pkg-config`, `cmake`, `ninja-build`

#### Python and Python build dependencies
- Runtime/tooling: `python3`, `python3-pip`, `python3-venv`, `pipx`
- Build libs for custom Python builds (pyenv/python-build):
  `libssl-dev`, `zlib1g-dev`, `libbz2-dev`, `libreadline-dev`, `libsqlite3-dev`,
  `libncursesw5-dev`, `xz-utils`, `tk-dev`, `libffi-dev`, `liblzma-dev`, `uuid-dev`

#### Useful CLI developer utilities
- `unzip`, `zip`, `tar`, `jq`, `htop`, `net-tools`, `bc`

#### Language/runtime managers configured
- **pyenv** defaults via `defaults.env`:
  - `PYTHON_DEFAULT="3.13"`
  - `PYTHON_ALT="3.14"`
- **SDKMAN** Java/Gradle defaults via `defaults.env`:
  - Java LTS auto mode (`JAVA_LTS_MODE="auto"`) with Temurin matching (`JAVA_VENDOR_REGEX="tem"`)
  - Gradle latest mode (`GRADLE_MODE="latest"`)
- **nvm** defaults via `defaults.env`:
  - Node alias `lts/*`
  - nvm version `v0.40.4`

### Notes
- Terminal-first workflow (no GUI requirements).
- No systemd dependency required.

</details>

<details>
<summary><strong>Ubuntu | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo apt update
sudo apt install -y wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

<details>
<summary><strong>Kali Linux | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo apt update
sudo apt install -y wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

<details>
<summary><strong>Linux Mint (WSL-capable variant) | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo apt update
sudo apt install -y wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

<details>
<summary><strong>openSUSE | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo zypper refresh
sudo zypper install -y wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

<details>
<summary><strong>Fedora | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo dnf makecache
sudo dnf install -y wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

<details>
<summary><strong>Arch Linux | Work in Progress</strong></summary>

### Status
This distro flow is currently under construction.

### Initial bootstrap (new distro install)

```bash
sudo pacman -Sy --noconfirm wget zip git
```

### Planned execution flow

```bash
git clone https://github.com/<your-org-or-user>/wsl2-dev-distros.git
cd wsl2-dev-distros
chmod +x install.sh
./install.sh
```

</details>

---

## Support Matrix

| Distribution | State |
|---|---|
| Debian (Bookworm) | Complete |
| Ubuntu | Work in Progress |
| Kali Linux | Work in Progress |
| Linux Mint | Work in Progress |
| openSUSE | Work in Progress |
| Fedora | Work in Progress |
| Arch Linux | Work in Progress |

## License
[MIT](LICENSE)
