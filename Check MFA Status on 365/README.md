# Export Microsoft 365 MFA Status Using Microsoft Graph PowerShell

This guide explains how to use the provided PowerShell script to export the Multi-Factor Authentication (MFA) status of all users in your Microsoft 365 tenant.

---

## 🧩 Prerequisites

Before running the script, ensure you have:

1. **Microsoft Graph PowerShell SDK installed**

   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   ```

2. **Permission to read users’ authentication methods**

   * You must have at least one of the following roles:

     * Global Administrator
     * Privileged Authentication Administrator
     * Authentication Policy Administrator

3. **Signed in to Microsoft Graph**

   ```powershell
   Connect-MgGraph -Scopes "User.Read.All","Reports.Read.All","Directory.Read.All"
   ```

---

## 📜 Script Overview

The script performs the following steps:

1. **Fetches all users** from the Microsoft 365 tenant using `Get-MgUser`.
2. **Loops through each user** to check their MFA registration methods via `Get-MgUserAuthenticationMethod`.
3. **Identifies MFA methods** (e.g., Microsoft Authenticator, Phone, FIDO2 Key, etc.).
4. **Determines MFA status** — whether *Enabled* (has MFA method) or *Disabled*.
5. **Exports the results** to a CSV file named `MFAStatus.csv`.

---

## 🧠 Code Explanation

### 1. Get all users

```powershell
$users = Get-MgUser -All
```

Retrieves all user accounts from the Microsoft 365 tenant.

### 2. Loop through each user

```powershell
foreach ($user in $users) {
    $methods = Get-MgUserAuthenticationMethod -UserId $user.Id
}
```

Gets MFA methods for each user.

### 3. Identify MFA methods

The script checks the method type from Microsoft Graph and translates it into readable names:

* Microsoft Authenticator
* Phone (SMS/Call)
* FIDO2 Security Key
* OATH Token
* Email

### 4. Determine MFA status

```powershell
$mfaEnabled = if ($mfaMethods.Count -gt 0) { "Enabled" } else { "Disabled" }
```

### 5. Export results

```powershell
$results | Export-Csv -Path ".\MFAStatus.csv" -NoTypeInformation -Encoding UTF8
```

Saves the final report in CSV format.

---

## 📂 Output Example (`MFAStatus.csv`)

| UserPrincipalName                             | DisplayName | MFAStatus | MFAMethods                     |
| --------------------------------------------- | ----------- | --------- | ------------------------------ |
| [alice@contoso.com](mailto:alice@contoso.com) | Alice Smith | Enabled   | Microsoft Authenticator, Phone |
| [bob@contoso.com](mailto:bob@contoso.com)     | Bob Jones   | Disabled  |                                |

---

## ▶️ How to Run

1. Open **PowerShell** as Administrator.
2. Run the following commands:

   ```powershell
   Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All"
   ```
3. Copy and paste the script into your PowerShell session.
4. Wait until completion.
5. Check the exported file:

   ```
   MFAStatus.csv
   ```

---

## 🧾 Notes

* The script uses **Microsoft Graph API**, not the legacy MSOnline module.
* Use `-ErrorAction SilentlyContinue` to skip users that cannot be queried.
* The report is saved in the same directory where the script is executed.

---

✅ **Result:** You will get a complete MFA registration report for all users in your Microsoft 365 tenant in `MFAStatus.csv`.
