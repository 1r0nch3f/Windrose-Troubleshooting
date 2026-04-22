#Requires -Version 5.1
<#
.SYNOPSIS
    Windrose Quick Triage, a lightweight diagnostic that checks the most common
    connection issues without needing the full Captain's Chest toolkit.

.DESCRIPTION
    Runs a fast subset of network checks used to diagnose Windrose connection
    issues. Intended to be run via:
        irm https://raw.githubusercontent.com/1r0nch3f/Windrose-Troubleshooting/main/scripts/Quick-Triage.ps1 | iex

    Produces a color-coded terminal summary, saves a redacted log to the Desktop,
    and (optionally) copies the log to the clipboard for pasting in Discord.

.PARAMETER Clipboard
    Copies the final log to the clipboard when the script finishes.

.NOTES
    Author : 1r0nch3f
    Repo   : https://github.com/1r0nch3f/Windrose-Troubleshooting
    Full   : https://github.com/1r0nch3f/Windrose-Captain-Chest
#>

[CmdletBinding()]
param(
    [switch]$Clipboard
)

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

# --- Config -----------------------------------------------------------------

$Version = '1.0.0'

# ISPs known to cause partial-outage symptoms with Windrose (router security
# features blocking UDP/3478, etc.). Patterns are regex alternations matched
# case-insensitively against the ipinfo.io "org" field.
#
# Kept in sync with the Captain's Chest culprit table. Entries marked
# "confirmed" have public reports of blocking Windrose specifically.
# Other entries are "known to block similar P2P games" (Palworld, Rust, Ark,
# etc.) using the same security features.
$CulpritIsps = @(
    # --- United States ---
    [pscustomobject]@{ Pattern = 'Spectrum|Charter';      Name = 'Spectrum (Charter)';     Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Comcast|Xfinity';       Name = 'Xfinity (Comcast)';      Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Cox Communications';    Name = 'Cox';                    Confirmed = $false }
    [pscustomobject]@{ Pattern = 'AT&T|AT&amp;T';         Name = 'AT&T';                   Confirmed = $false }
    [pscustomobject]@{ Pattern = 'CenturyLink|Lumen';     Name = 'CenturyLink/Lumen';      Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Verizon';               Name = 'Verizon Fios/5G Home';   Confirmed = $false }
    [pscustomobject]@{ Pattern = 'T-Mobile';              Name = 'T-Mobile Home Internet'; Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Optimum|Cablevision';   Name = 'Optimum (Altice)';       Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Frontier';              Name = 'Frontier';               Confirmed = $false }

    # --- United Kingdom ---
    [pscustomobject]@{ Pattern = 'British Telecom|BT ';   Name = 'BT';                     Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Sky UK|Sky Broadband';  Name = 'Sky';                    Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Virgin Media';          Name = 'Virgin Media';           Confirmed = $false }
    [pscustomobject]@{ Pattern = 'TalkTalk';              Name = 'TalkTalk';               Confirmed = $false }

    # --- Europe ---
    [pscustomobject]@{ Pattern = 'Ziggo|VodafoneZiggo';   Name = 'Ziggo (NL)';             Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Orange ';               Name = 'Orange (FR/ES)';         Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Free SAS|Free ';        Name = 'Free (FR)';              Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Deutsche Telekom';      Name = 'Deutsche Telekom (DE)';  Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Telekom';               Name = 'Telekom (DE/EU)';        Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Vodafone';              Name = 'Vodafone (EU)';          Confirmed = $false }

    # --- Canada ---
    [pscustomobject]@{ Pattern = 'Rogers Communications'; Name = 'Rogers (CA)';            Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Bell Canada';           Name = 'Bell (CA)';              Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Telus';                 Name = 'Telus (CA)';             Confirmed = $false }

    # --- Australia ---
    [pscustomobject]@{ Pattern = 'Telstra';               Name = 'Telstra (AU)';           Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Optus';                 Name = 'Optus (AU)';             Confirmed = $false }
)

# Endpoints to probe. Keep this list small, this is the QUICK triage.
# Matches Captain's Chest Fleet check endpoints.
$Endpoints = @(
    [pscustomobject]@{
        Name     = 'EU/NA API Gateway'
        HostName = 'r5coopapigateway-eu-release.windrose.support'
        TcpPort  = 443
        UdpPort  = $null
    }
    [pscustomobject]@{
        Name     = 'CIS API Gateway'
        HostName = 'r5coopapigateway-ru-release.windrose.support'
        TcpPort  = 443
        UdpPort  = $null
    }
    [pscustomobject]@{
        Name     = 'KR/SEA API Gateway'
        HostName = 'r5coopapigateway-kr-release.windrose.support'
        TcpPort  = 443
        UdpPort  = $null
    }
    [pscustomobject]@{
        Name     = 'STUN/TURN (P2P signaling)'
        HostName = 'windrose.support'
        TcpPort  = $null
        UdpPort  = 3478
    }
)

# --- Helpers ----------------------------------------------------------------

$script:LogLines = New-Object System.Collections.Generic.List[string]

function Write-Line {
    param(
        [string]$Text = '',
        [ValidateSet('Info','Good','Warn','Bad','Head','Dim')]
        [string]$Level = 'Info'
    )
    $color = switch ($Level) {
        'Good' { 'Green' }
        'Warn' { 'Yellow' }
        'Bad'  { 'Red' }
        'Head' { 'Cyan' }
        'Dim'  { 'DarkGray' }
        default { 'Gray' }
    }
    Write-Host $Text -ForegroundColor $color
    $script:LogLines.Add($Text) | Out-Null
}

function Protect-IpAddress {
    param([string]$IpAddress)
    if ([string]::IsNullOrWhiteSpace($IpAddress)) { return '(unknown)' }
    # Keep first two octets for IPv4, redact the rest.
    if ($IpAddress -match '^(\d{1,3}\.\d{1,3})\.\d{1,3}\.\d{1,3}$') {
        return "$($matches[1]).xxx.xxx"
    }
    return '(redacted)'
}

function Test-StunUdp {
    <#
    Real UDP/3478 test using a STUN binding request. If the server replies,
    UDP is reachable. If it times out, UDP is blocked (typical Spectrum
    Security Shield behavior).

    This is the only way to accurately detect the UDP block. A fire-and-forget
    Send() will always "succeed" locally regardless of whether the packet ever
    leaves the network.
    #>
    param(
        [string]$HostName,
        [int]$Port      = 3478,
        [int]$TimeoutMs = 3000
    )
    $udp = $null
    try {
        # Resolve to IP first so we can differentiate DNS vs UDP failures.
        $addr = [System.Net.Dns]::GetHostAddresses($HostName) |
                Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
                Select-Object -First 1
        if (-not $addr) { return $false }

        $udp = New-Object System.Net.Sockets.UdpClient
        $udp.Client.ReceiveTimeout = $TimeoutMs
        $udp.Client.SendTimeout    = $TimeoutMs

        # Build a minimal STUN Binding Request (RFC 5389):
        #   0x0001      = Binding Request
        #   0x0000      = Message Length (no attributes)
        #   0x2112A442  = Magic Cookie
        #   12 bytes    = random transaction ID
        $txid = New-Object byte[] 12
        (New-Object System.Random).NextBytes($txid)

        $msg = New-Object byte[] 20
        $msg[0]  = 0x00; $msg[1]  = 0x01  # Binding Request
        $msg[2]  = 0x00; $msg[3]  = 0x00  # Length
        $msg[4]  = 0x21; $msg[5]  = 0x12  # Magic Cookie
        $msg[6]  = 0xA4; $msg[7]  = 0x42
        [Array]::Copy($txid, 0, $msg, 8, 12)

        $endpoint = New-Object System.Net.IPEndPoint($addr, $Port)
        [void]$udp.Send($msg, $msg.Length, $endpoint)

        # Wait for response (valid STUN reply = UDP reachable)
        $remote = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $ar = $udp.BeginReceive($null, $null)
        $ok = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if ($ok) {
            $null = $udp.EndReceive($ar, [ref]$remote)
            return $true
        }
        return $false
    } catch {
        return $false
    } finally {
        if ($udp) { $udp.Close() }
    }
}

function Test-TcpPort {
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutMs = 2000
    )
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $iar = $tcp.BeginConnect($HostName, $Port, $null, $null)
        $ok  = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if ($ok -and $tcp.Connected) {
            $tcp.EndConnect($iar)
            $tcp.Close()
            return $true
        }
        $tcp.Close()
        return $false
    } catch {
        return $false
    }
}

function Get-PingLatency {
    param([string]$HostName)
    try {
        $p = Test-Connection -ComputerName $HostName -Count 2 -ErrorAction Stop
        $avg = ($p | Measure-Object -Property ResponseTime -Average).Average
        return [int]$avg
    } catch {
        return $null
    }
}

# --- Start ------------------------------------------------------------------

Clear-Host
Write-Line "========================================================" 'Head'
Write-Line "  Windrose Quick Triage v$Version"                         'Head'
Write-Line "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"                'Dim'
Write-Line "========================================================" 'Head'
Write-Line ''

# --- 1. Public IP and ISP ---------------------------------------------------

Write-Line "[1/5] Detecting public IP and ISP..." 'Head'
$ispName  = $null
$ispFlag  = $false
$ispMatch = $null
$publicIp = $null
try {
    $resp = Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 5 -ErrorAction Stop
    $publicIp = $resp.ip
    $ispName  = $resp.org
    # Extract the AS number if the org string is in the form "AS12345 Provider Name"
    $asNumber = if ($ispName -match '^(AS\d+)\b') { $matches[1] } else { '(no AS)' }
    Write-Line "    Public IP : $(Protect-IpAddress $publicIp)"  'Info'
    Write-Line "    Network   : $asNumber"                       'Info'
    Write-Line "    Country   : $($resp.country)"                'Info'

    foreach ($c in $CulpritIsps) {
        if ($ispName -match $c.Pattern) {
            $ispFlag  = $true
            $ispMatch = $c.Name
            $tag      = if ($c.Confirmed) { 'confirmed to block Windrose' } else { 'known to block similar P2P games' }
            Write-Line "    WARN      : ISP matched known culprit: $($c.Name) ($tag)." 'Warn'
            break
        }
    }
    if (-not $ispFlag) {
        Write-Line "    OK        : ISP not on the known-culprit list." 'Good'
    }
} catch {
    Write-Line "    ERROR     : Could not reach ipinfo.io. Check basic internet." 'Bad'
}
Write-Line ''

# --- 2. DNS resolution ------------------------------------------------------

Write-Line "[2/5] Resolving Windrose endpoints..." 'Head'
$dnsFailures = 0
foreach ($ep in $Endpoints) {
    try {
        $r = Resolve-DnsName -Name $ep.HostName -Type A -ErrorAction Stop |
             Where-Object { $_.IPAddress } |
             Select-Object -First 1
        if ($r) {
            Write-Line ("    OK   : {0,-46} -> {1}" -f $ep.HostName, $r.IPAddress) 'Good'
        } else {
            $dnsFailures++
            Write-Line ("    FAIL : {0,-46} -> no A record" -f $ep.HostName) 'Bad'
        }
    } catch {
        $dnsFailures++
        Write-Line ("    FAIL : {0,-46} -> DNS error" -f $ep.HostName) 'Bad'
    }
}
Write-Line ''

# --- 3. TCP connect tests ---------------------------------------------------

Write-Line "[3/5] Testing TCP connectivity..." 'Head'
$tcpFailures = 0
$tcpTargets  = $Endpoints | Where-Object { $_.TcpPort }
foreach ($ep in $tcpTargets) {
    $ok = Test-TcpPort -HostName $ep.HostName -Port $ep.TcpPort -TimeoutMs 3000
    if ($ok) {
        Write-Line ("    OK   : {0,-28} {1}/tcp" -f $ep.Name, $ep.TcpPort) 'Good'
    } else {
        $tcpFailures++
        Write-Line ("    FAIL : {0,-28} {1}/tcp" -f $ep.Name, $ep.TcpPort) 'Bad'
    }
}
Write-Line ''

# --- 4. UDP 3478 probe (real STUN binding request) --------------------------

Write-Line "[4/5] Probing UDP/3478 with STUN (the port commonly blocked)..." 'Head'
$udpFailures = 0
$udpTargets  = $Endpoints | Where-Object { $_.UdpPort }
foreach ($ep in $udpTargets) {
    $ok = Test-StunUdp -HostName $ep.HostName -Port $ep.UdpPort -TimeoutMs 3000
    if ($ok) {
        Write-Line ("    OK   : {0,-28} {1}/udp (STUN reply received)" -f $ep.Name, $ep.UdpPort) 'Good'
    } else {
        $udpFailures++
        Write-Line ("    FAIL : {0,-28} {1}/udp (no STUN reply, likely blocked)" -f $ep.Name, $ep.UdpPort) 'Bad'
    }
}
Write-Line ''

# --- 5. Latency to nearest gateway ------------------------------------------

Write-Line "[5/5] Measuring latency..." 'Head'
$latency = $null
$nearest = $Endpoints | Select-Object -First 1
$latency = Get-PingLatency -HostName $nearest.HostName
if ($null -ne $latency) {
    $tag = if     ($latency -lt 80)  { 'Good' }
           elseif ($latency -lt 200) { 'Warn' }
           else                      { 'Bad'  }
    Write-Line ("    {0,-28} ~ {1} ms" -f $nearest.Name, $latency) $tag
} else {
    Write-Line "    Could not measure latency (ICMP may be filtered)." 'Warn'
}
Write-Line ''

# --- Verdict ----------------------------------------------------------------

Write-Line "========================================================" 'Head'
Write-Line "  Verdict"                                                 'Head'
Write-Line "========================================================" 'Head'

$verdict = ''
$verdictKey = ''   # Used to select the 'What to try' steps
$steps   = @()

if ($ispFlag -and ($udpFailures -gt 0 -or $tcpFailures -gt 0)) {
    $verdict    = 'Likely ISP block'
    $verdictKey = 'IspBlock'
} elseif ($udpFailures -gt 0 -and $tcpFailures -eq 0) {
    $verdict    = 'Likely UDP/3478 block (ISP or router)'
    $verdictKey = 'UdpBlock'
} elseif ($tcpFailures -gt 0 -and $dnsFailures -eq 0) {
    $verdict    = 'Likely local firewall or router'
    $verdictKey = 'LocalFirewall'
} elseif ($dnsFailures -gt 0) {
    $verdict    = 'Likely DNS or basic connectivity issue'
    $verdictKey = 'DnsIssue'
} elseif ($tcpFailures -eq 0 -and $udpFailures -eq 0 -and $ispFlag) {
    $verdict    = 'All checks passed, but ISP is a known culprit'
    $verdictKey = 'IspOkButCulprit'
} elseif ($tcpFailures -eq 0 -and $udpFailures -eq 0) {
    $verdict    = 'No network issue detected'
    $verdictKey = 'AllOk'
} else {
    $verdict    = 'Mixed results, see details above'
    $verdictKey = 'Mixed'
}

# Build the 'What to try' steps based on the verdict.
# Keep steps generic (no ISP-specific toggle paths), in "try first, try next, last resort" order.
switch ($verdictKey) {
    'IspBlock' {
        $steps += 'Your ISP is on the known-culprit list and gateway ports are failing. The fix is almost always an ISP-provided security feature that is on by default.'
        $steps += 'Open your ISP''s account app or website and look for a setting called "Security Shield", "Advanced Security", "Network Protection", or similar. Turn it off.'
        $steps += 'Restart your router, then re-run this script. UDP/3478 should now show OK.'
        $steps += 'If the ISP toggle does not exist or does not help, try a VPN that forwards UDP (Mullvad, AirVPN, PIA) to confirm the block is on the ISP side.'
        $steps += 'Still stuck? Run the full Captain''s Chest toolkit for ISP-specific toggle paths: https://github.com/1r0nch3f/Windrose-Captain-Chest'
    }
    'UdpBlock' {
        $steps += 'TCP works but UDP to the gateway is failing. This is the classic Windrose-blocking pattern.'
        $steps += 'First, check your ISP''s account app or website for a "Security Shield" / "Advanced Security" / "Network Protection" feature. Turn it off.'
        $steps += 'Next, check your router admin page for firewall or parental-control features. Some routers block UDP traffic on non-standard ports by default.'
        $steps += 'Then check any third-party antivirus or firewall on your PC (Norton, McAfee, Kaspersky, ESET). Disable temporarily to test.'
        $steps += 'If none of the above works, a VPN that forwards UDP (Mullvad, AirVPN, PIA) will bypass the block entirely.'
    }
    'LocalFirewall' {
        $steps += 'DNS resolves but TCP connects are failing. Something between your PC and the wider internet is blocking outbound traffic.'
        $steps += 'Temporarily disable any third-party antivirus or firewall on your PC (Norton, McAfee, Kaspersky, ESET, Malwarebytes). Re-run.'
        $steps += 'Check Windows Defender Firewall allows outbound on 443/tcp. Press Win, type "Windows Defender Firewall", check Advanced settings > Outbound Rules.'
        $steps += 'Check your router for any outbound blocking or parental-control rules targeting your device.'
        $steps += 'Try from a different network (mobile hotspot is a quick test) to confirm whether it is your machine or your network.'
    }
    'DnsIssue' {
        $steps += 'DNS lookups are failing, which means your machine cannot translate the Windrose hostnames into IP addresses.'
        $steps += 'Switch your DNS to a public resolver: 1.1.1.1 (Cloudflare) or 8.8.8.8 (Google). Network settings > change adapter options > right-click your adapter > Properties > IPv4 > Use the following DNS servers.'
        $steps += 'After changing DNS, flush the local DNS cache: open an admin PowerShell and run ipconfig /flushdns.'
        $steps += 'Re-run this script. DNS entries should now show OK.'
        $steps += 'If DNS still fails after switching, your ISP may be blocking windrose.support at the DNS level, and a VPN will likely be needed.'
    }
    'IspOkButCulprit' {
        $steps += 'All checks passed, so your connection to Windrose is working right now. But your ISP is on the known-culprit list for blocking this game.'
        $steps += 'If the game breaks again later (especially after a router reboot or ISP app update), the ISP security toggle may have re-enabled itself. Check it again if that happens.'
        $steps += 'If the game is currently misbehaving, the cause is likely server-side (Windrose capacity) or client-side (crash, missing runtimes, driver).'
        $steps += 'For client-side issues, run the full Captain''s Chest toolkit: https://github.com/1r0nch3f/Windrose-Captain-Chest'
        $steps += 'Check tutorial completion: every player must finish the single-player tutorial on their own Steam account before they can join multiplayer. This is the most common cause of silent "dropped back to main menu" reports. Details: https://github.com/1r0nch3f/Windrose-Troubleshooting/blob/main/docs/scenarios/tutorial-not-completed.md'
    }
    'AllOk' {
        $steps += 'All network checks passed. Your connection to Windrose is working.'
        $steps += 'Check tutorial completion: every player must finish the single-player tutorial on their own Steam account before they can join multiplayer. This is the most common cause of silent "dropped back to main menu" reports. Details: https://github.com/1r0nch3f/Windrose-Troubleshooting/blob/main/docs/scenarios/tutorial-not-completed.md'
        $steps += 'If the game still will not connect, the cause is on Windrose''s side (server capacity during peak hours) or on your machine (crash, missing runtimes, driver, corrupted install).'
        $steps += 'For peak-hour issues, try again later, or host with Direct IP mode (port 7777) to bypass the backend entirely.'
        $steps += 'For client-side issues, run the full Captain''s Chest toolkit: https://github.com/1r0nch3f/Windrose-Captain-Chest'
    }
    'Mixed' {
        $steps += 'Some checks failed in ways that do not match a single known pattern. The combined signal is unclear.'
        $steps += 'Run the full Captain''s Chest toolkit for deeper diagnostics: https://github.com/1r0nch3f/Windrose-Captain-Chest'
        $steps += 'When asking for help, paste both this log and the Captain''s Chest output so helpers can see the full picture.'
        $steps += 'Check tutorial completion: every player must finish the single-player tutorial on their own Steam account before they can join multiplayer. This is the most common cause of silent "dropped back to main menu" reports. Details: https://github.com/1r0nch3f/Windrose-Troubleshooting/blob/main/docs/scenarios/tutorial-not-completed.md'
    }
}

Write-Line ''
$vcolor = if ($verdictKey -eq 'AllOk') { 'Good' } elseif ($verdictKey -in @('IspOkButCulprit','IspBlock','UdpBlock','LocalFirewall','DnsIssue')) { 'Warn' } else { 'Bad' }
Write-Line "  $verdict" $vcolor
Write-Line ''

Write-Line "========================================================" 'Head'
Write-Line "  What to try"                                             'Head'
Write-Line "========================================================" 'Head'
Write-Line ''
$stepNum = 1
foreach ($s in $steps) {
    Write-Line "  $stepNum. $s" 'Info'
    Write-Line ''
    $stepNum++
}

Write-Line "========================================================" 'Head'
Write-Line "  Next steps"                                              'Head'
Write-Line "========================================================" 'Head'
Write-Line "  Full toolkit   : https://github.com/1r0nch3f/Windrose-Captain-Chest" 'Dim'
Write-Line "  Troubleshooting: https://github.com/1r0nch3f/Windrose-Troubleshooting" 'Dim'
Write-Line ''

# --- Save log ---------------------------------------------------------------

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$desktop   = [Environment]::GetFolderPath('Desktop')
$logPath   = Join-Path $desktop "Windrose-Triage-$timestamp.log"

try {
    $script:LogLines | Out-File -FilePath $logPath -Encoding utf8 -Force
    Write-Line "  Log saved: $logPath" 'Good'
} catch {
    Write-Line "  Could not save log: $($_.Exception.Message)" 'Bad'
}

# --- Optional clipboard copy ------------------------------------------------

if ($Clipboard) {
    try {
        $script:LogLines -join "`r`n" | Set-Clipboard
        Write-Line "  Log copied to clipboard (paste it in Discord)." 'Good'
    } catch {
        Write-Line "  Could not copy to clipboard: $($_.Exception.Message)" 'Warn'
    }
}

Write-Line ''
