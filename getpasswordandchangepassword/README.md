# CyberArk API Password Retrieval & Rotation Script

This repository contains a script that automates password retrieval and rotation for privileged accounts managed by CyberArk. The script is designed to:

- Authenticate with the CyberArk API
- Retrieve a password for a specified account (for use in a third-party program or API)
- Change (rotate) its own CyberArk-managed password in the vault

---

## Features

- Automates secure password retrieval via CyberArk’s REST API
- Supports integration with third-party applications needing privileged credentials

---

## Requirements

- Access to CyberArk’s REST API (Privilege Cloud or Self-Hosted PAM)
- API user credentials with permissions to retrieve and change passwords

---

## How This Works

- The script uses the provided CyberArk account and its stored encrypted password to connect to the PVWA API.
- After a successful login, the script retrieves the account password that needs to be updated on the third-party service.
- The script then updates the password using the third-party service's API.
- Finally, the script updates the password of the CyberArk account it used to connect, generates a new password, and stores it in the encrypted password file.

---

## Security & Best Practices

- Never hardcode credentials in the script; use environment variables or secure vaults.
- Ensure API communication uses HTTPS.
- Limit API user permissions to only what is necessary.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Attribution

If you use or modify this script, please retain this attribution in your documentation or about section.
