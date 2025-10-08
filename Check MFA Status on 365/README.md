# 📊 Export Microsoft 365 MFA Status Using Microsoft Graph PowerShell

This guide explains how to use the PowerShell script to **export the Multi-Factor Authentication (MFA) status** for all users in your Microsoft 365 tenant.
The script works with **Microsoft Graph PowerShell SDK** and includes detection for both **Per-user MFA** and **Conditional Access (CA)**-based MFA enforcement.

---

## 🧩 Prerequisites

Before running the script, ensure you have:

1. **Microsoft Graph PowerShell SDK installed**

   ```powershell
   Install-Module Microsoft.Graph -Scope CurrentUser
   ```

2. **Sufficient admin permissions**

   You must have one of the following roles:

   * Global Administrator
   * Privileged Authentication Administrator
   * Authentication Policy Administrator

3. **Connect to Microsoft Graph**

   Run this command to authenticate:

   ```powershell
   Connect-MgGraph -Scopes "User.Read.All","Policy.Read.All","Directory.Read.All","UserAuthenticationMethod.Read.All"
   ```

---

## 📜 Script Overview

The script performs the following key steps:

1. **Connects to Microsoft Graph** with the necessary scopes.
2. **Fetches all users** in your Microsoft 365 tenant using `Get-MgUser`.
3. **Retrieves Conditional Access policies** that enforce MFA.
4. **Checks per-user MFA settings** (`StrongAuthenticationRequirements`).
5. **Checks registered MFA methods** using `Get-MgUserAuthenticationMethod`.
6. **Determines enforcement type** — *Per-user MFA*, *Conditional Access MFA*, or *None*.
7. **Exports the final report** to a CSV file named `MFAStatus.csv`.

---

## 🧠 Code Explanation

### 1. Get all users

```powershell
$users = Get-MgUser -All -Property "id,displayName,userPrincipalName,strongAuthenticationRequirements"
```

Retrieves all user accounts with key properties needed to evaluate MFA.

---

### 2. Get Conditional Access policies that enforce MFA

```powershell
$CAPolicies = Get-MgIdentityConditionalAccessPolicy -All | Where-Object {
    $_.GrantControls.BuiltInControls -contains "mfa" -and $_.State -eq "enabled"
}
```

Filters Conditional Access policies that are **enabled** and require **MFA** as a grant control.

---

### 3. Get MFA registration methods for each user

```powershell
$methods = Get-MgUserAuthenticationMethod -UserId $user.Id
```

Retrieves all authentication methods registered by each user and translates the Graph type into readable names:

* Microsoft Authenticator
* Phone (SMS/Call)
* FIDO2 Security Key
* OATH Token
* Email
* Temporary Access Pass (TAP)

---

### 4. Determine MFA registration and enforcement

```powershell
$isRegistered = if ($mfaMethods.Count -gt 0) { "Yes" } else { "No" }
```

Checks if the user has registered at least one MFA method.

```powershell
if ($mfaState -eq "Enabled") {
    $enforcedType = "Per-user MFA"
}
elseif ($caApplies) {
    $enforcedType = "Conditional Access MFA"
}
else {
    $enforcedType = "None"
}
```

Determines how MFA is enforced — either by per-user setting or Conditional Access.

---

### 5. Export results to CSV

```powershell
$results | Export-Csv -Path ".\MFAStatus.csv" -NoTypeInformation -Encoding UTF8
```

Saves the report to a CSV file in the same directory as the script.

---

## 📂 Output Example (`MFAStatus.csv`)

| UserPrincipalName                                 | DisplayName | MFA_Registered | MFA_Enforced           | MFAMethods              |
| ------------------------------------------------- | ----------- | -------------- | ---------------------- | ----------------------- |
| [alice@contoso.com](mailto:alice@contoso.com)     | Alice Smith | Yes            | Conditional Access MFA | Microsoft Authenticator |
| [bob@contoso.com](mailto:bob@contoso.com)         | Bob Jones   | No             | None                   |                         |
| [charlie@contoso.com](mailto:charlie@contoso.com) | Charlie Kim | Yes            | Per-user MFA           | FIDO2 Security Key, SMS |

---

## ▶️ How to Run

1. **Open PowerShell** as Administrator.
2. **Connect to Microsoft Graph** (you’ll be prompted to sign in):

   ```powershell
   Connect-MgGraph -Scopes "User.Read.All","Policy.Read.All","Directory.Read.All","UserAuthenticationMethod.Read.All"
   ```
3. **Run the script** (save it as `Export-MFAStatus.ps1`):

   ```powershell
   .\Export-MFAStatus.ps1
   ```
4. Wait for the script to finish collecting user data.
5. Once complete, check your output file:

   ```
   MFAStatus.csv
   ```

---

## 🧾 Notes

* The script uses the **Microsoft Graph PowerShell SDK** — the modern replacement for legacy modules like *MSOnline* and *AzureAD*.
* Users who can’t be queried (e.g., service accounts or external guests) will be skipped automatically.
* The exported file is saved in UTF-8 format for easy viewing in Excel.
* Large tenants may take several minutes to complete due to Graph API throttling.

---

## ✅ Result

After completion, you’ll get a detailed **MFA status report** showing:

* Whether each user has MFA registered
* Whether MFA is enforced (and by what method)
* Which MFA methods are configured

This report provides a **complete view of MFA adoption and enforcement** in your Microsoft 365 environment.

---

## 🧾 Changelog

| Version | Date             | Notes                                                          |
| ------- | ---------------- | -------------------------------------------------------------- |
| v1.0    | Initial          | Basic MFA registration check                                   |
| v2.0    | Enhanced         | Added Conditional Access and TAP detection                     |

---

**Author:** Warawuth Phralabraksa
**Last Updated:** October 2025
**Category:** Microsoft 365 Security & Compliance Automation
