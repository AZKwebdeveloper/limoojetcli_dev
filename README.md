## 📦 LimooJetCLI

**LimooJetCLI** is a lightweight shell-based tool designed to interact with JetBackup's API to automate and manage backup operations on Linux servers. It is especially useful when managing multiple servers with JetBackup 5 installed (AlmaLinux, Ubuntu, etc.).

This tool auto-detects JetBackup's configuration, retrieves necessary credentials from system files, confirms user intent before executing critical operations, and logs all events and errors for auditing.

---

### 🚀 Features

- ✅ Auto-detects **JetBackup API version**, URL, and token
- 📦 Supports **JetBackup 5+**
- 🔒 Requires **user confirmation before each sensitive action**
- 📄 Detailed **logging system** (`logs/limoojet.log`)
- 🧠 Written in **pure Bash + Python** with clean relative path usage (no absolute paths)
- 🌐 Executes remotely with:
  ```bash
  bash <(curl -s https://raw.githubusercontent.com/<your-username>/LimooJetCLI/main/run.sh)
  ```

---

### 📁 Project Structure

```
LimooJetCLI/
├── run.sh                     # Entry point script (bash)
├── jetbackup/
│   ├── main.py                # Main logic in Python
│   └── utils.py               # Logging and confirmation helpers
├── logs/
│   └── limoojet.log           # Runtime logs (auto-created)
```

---

### 🛠 Requirements

- Linux server with **JetBackup 5** installed
- `python3` and `curl` installed
- Read access to:
  - `/usr/local/jetapps/etc/jetbackup5/config.json`

---

### 🔧 How It Works

1. `run.sh` checks if `jetbackup5` CLI exists and fetches its version.
2. Reads JetBackup's internal `config.json` to extract:
   - API base URL
   - Access token
3. Asks for **confirmation** before any connection or action.
4. Calls `main.py` to interact with JetBackup’s API:
   - Lists all backup jobs
   - Logs results and errors to `logs/limoojet.log`

---

### 📄 Example Usage

```bash
bash <(curl -s https://raw.githubusercontent.com/your-username/LimooJetCLI/main/run.sh)
```

---

### 📌 Notes

- Only tested with JetBackup 5+ (not compatible with v4 or older).
- You may need to adjust the path to `config.json` if your JetBackup install differs.
- Do **not** share your token or log file contents publicly — they may contain sensitive data.

---

### 📚 License

MIT License — feel free to use, modify, and contribute!

---
