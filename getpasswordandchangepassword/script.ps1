# =====================================================================
# PowerShell Script to Rotate CyberArk Password and Update Backup System
# =====================================================================
# NOTE: Before use, replace all placeholder values below with your actual environment details:
#   - <PVWA_URL>               : Your CyberArk PVWA API endpoint
#   - <CYBERARK_USERNAME>      : Service account username for CyberArk
#   - <SECURE_PASSWORD_PATH>   : Path to your encrypted password file
#   - <TARGET_ACCOUNT_NAME>    : Account name in CyberArk to retrieve
#   - <BACKUP_CRED_NAME>       : Credential name in your backup system
#   - <BACKUP_CRED_CMDS>       : Replace with your backup system's credential cmdlets if not Veeam
# =====================================================================

# --- Module Import and Validation ---
# Ensure the psPAS module is imported and available
if (-not (Get-Module -Name psPAS -ListAvailable)) {
    try {
        Import-Module psPAS -ErrorAction Stop
    } catch {
        Write-Error "psPAS module could not be imported. Ensure it is installed."
        exit 1
    }
}

# --- Configuration ---
# Define the PVWA (Privileged Vault Web Access) API URL
$pvwaURL = "<PVWA_URL>"

# --- CyberArk Authentication ---
# Define CyberArk service account credentials
$cyberArkUsername = "<CYBERARK_USERNAME>"

# Read the secure password from a file (ensure this file is protected)
try {
    $cyberArkPassword = Get-Content "<SECURE_PASSWORD_PATH>" | ConvertTo-SecureString
} catch {
    Write-Error "Failed to read or convert the secure password file."
    exit 1
}

# Create a PSCredential object for authentication
$cyberArkCred = New-Object System.Management.Automation.PSCredential ($cyberArkUsername, $cyberArkPassword)

# Establish a session with CyberArk PVWA using built-in authentication
try {
    New-PASSession -Credential $cyberArkCred -BaseURI $pvwaURL -type CyberArk
} catch {
    Write-Error "Failed to establish a session with CyberArk PVWA."
    exit 1
}

# --- Password Retrieval ---
# Retrieve the password for the target account from CyberArk
$targetAccountName = "<TARGET_ACCOUNT_NAME>"
$TargetAccount = Get-PASAccount -Search $targetAccountName

if ($TargetAccount) {
    try {
        # Retrieve the password as plain text, then convert to SecureString
        $plainPassword = Get-PASAccountPassword -AccountID $TargetAccount.ID
    } catch {
        Write-Error "Failed to retrieve the password from CyberArk."
        exit 1
    }
} else {
    Write-Host "No account found with the name: $targetAccountName"
    exit 1
}

# --- Backup System Credential Update ---
# Modify here to match the API of the backup system you're using

# Retrieve the existing backup system credentials object by name
try {
    # Replace 'Get-BackupCredentials' with your backup system's cmdlet
    $backupCredential = Get-BackupCredentials -Name "<BACKUP_CRED_NAME>"
} catch {
    Write-Error "Failed to retrieve backup system credentials."
    exit 1
}

# Update the backup system credential with the new password
try {
    # Replace 'Set-BackupCredentials' with your backup system's cmdlet
    Set-BackupCredentials -Credential $backupCredential -Password $plainPassword
    Write-Host "Backup system credentials updated successfully."
} catch {
    Write-Error "Failed to update backup system credentials."
    exit 1
}

# --- Password Rotation ---
# Change the password for the service account in CyberArk
$myAccount = Get-PASAccount -Search $cyberArkUsername
if ($myAccount) {
    # Generate a new random password (16 chars, 3 non-alphanumeric)
    $newPassword = [System.Web.Security.Membership]::GeneratePassword(16, 3)
    $secureString = ConvertTo-SecureString $newPassword -AsPlainText -Force

    # Update the password in CyberArk for the account
    try {
        Invoke-PASCPMOperation -AccountID $myAccount.ID -ChangeTask -ChangeImmediately $true -NewCredentials $secureString
    } catch {
        Write-Error "Failed to change the password in CyberArk."
        exit 1
    }

    # Save the new password securely for future use (protect this file!)
    $encryptedString = $secureString | ConvertFrom-SecureString
    Set-Content -Path "<SECURE_PASSWORD_PATH>" -Value $encryptedString
} else {
    Write-Host "No account found with the name: $cyberArkUsername"
    exit 1
}

exit 0
