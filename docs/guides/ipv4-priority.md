# IPv4 priority

The Windrose backend is IPv4 only. Windows sometimes prefers IPv6 when resolving DNS, and when that happens the connection attempt goes to an address the backend does not answer on. The fix demotes IPv6 below IPv4 globally without disabling IPv6 entirely.

## The fix

Both methods below write the same value. You need administrator privileges for either one. A reboot is required before the change takes effect.

### Option 1: registry file (.reg)

Save the block below as a `.reg` file and double-click it to import.

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters]
"DisabledComponents"=dword:00000020
```

### Option 2: PowerShell one-liner

Run from an elevated PowerShell prompt (right-click, Run as administrator):

```powershell
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name DisabledComponents -Value 0x20 -Type DWord
```

Reboot after running either option.

## What this value does

`DisabledComponents` set to `32` (0x20) tells Windows to prefer IPv4 over IPv6 in address selection. IPv6 remains enabled and available to other applications that need it. Home networking, local services, and other software that depends on IPv6 are not affected.

Do not use `0xFF` or `0xFFFFFFFF`. Those values fully disable IPv6 and break Windows features that require it, including some HomeGroup and link-local functionality.

## Verification

After rebooting, run both checks below.

**Check prefix policy order:**

```
netsh interface ipv6 show prefixpolicies
```

The IPv4-mapped prefix `::ffff:0:0/96` should have a higher precedence value than the native IPv6 prefixes.

**Check DNS resolution order:**

```powershell
Resolve-DnsName r5coopapigateway-eu-release.windrose.support
```

The `A` record (IPv4) should appear before any `AAAA` record (IPv6) in the output. If only an `A` record appears, that is also correct.

If DNS still returns IPv6 first after a reboot, confirm the registry value was written correctly:

```powershell
Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name DisabledComponents
```

The output should show `DisabledComponents : 32`.
