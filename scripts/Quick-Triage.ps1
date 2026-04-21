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

$Version = '1.1.0'

# ISPs known to cause partial-outage symptoms with Windrose (router security
# features blocking UDP/3478, etc.). Patterns are regex alternations matched
# case-insensitively against the ipinfo.io "org" field.
$CulpritIsps = @(
    [pscustomobject]@{ Pattern = 'Spectrum|Charter';      Name = 'Spectrum (Charter)';     Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Comcast|Xfinity';       Name = 'Xfinity (Comcast)';      Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Cox Communications';    Name = 'Cox';                    Confirmed = $false }
    [pscustomobject]@{ Pattern = 'AT&T|AT&amp;T';         Name = 'AT&T';                   Confirmed = $false }
    [pscustomobject]@{ Pattern = 'CenturyLink|Lumen';     Name = 'CenturyLink/Lumen';      Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Verizon';               Name = 'Verizon Fios/5G Home';   Confirmed = $false }
    [pscustomobject]@{ Pattern = 'T-Mobile';              Name = 'T-Mobile Home Internet'; Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Optimum|Cablevision';   Name = 'Optimum (Altice)';       Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Frontier';              Name = 'Frontier';               Confirmed = $false }

    [pscustomobject]@{ Pattern = 'British Telecom|BT ';   Name = 'BT';                     Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Sky UK|Sky Broadband';  Name = 'Sky';                    Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Virgin Media';          Name = 'Virgin Media';           Confirmed = $false }
    [pscustomobject]@{ Pattern = 'TalkTalk';              Name = 'TalkTalk';               Confirmed = $false }

    [pscustomobject]@{ Pattern = 'Ziggo|VodafoneZiggo';   Name = 'Ziggo (NL)';             Confirmed = $true  }
    [pscustomobject]@{ Pattern = 'Orange ';               Name = 'Orange (FR/ES)';         Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Free SAS|Free ';        Name = 'Free (FR)';              Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Deutsche Telekom';      Name = 'Deutsche Telekom (DE)';  Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Telekom';               Name = 'Telekom (DE/EU)';        Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Vodafone';              Name = 'Vodafone (EU)';          Confirmed = $false }

    [pscustomobject]@{ Pattern = 'Rogers Communications'; Name = 'Rogers (CA)';            Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Bell Canada';           Name = 'Bell (CA)';              Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Telus';                 Name = 'Telus (CA)';             Confirmed = $false }

    [pscustomobject]@{ Pattern = 'Telstra';               Name = 'Telstra (AU)';           Confirmed = $false }
    [pscustomobject]@{ Pattern = 'Optus';                 Name = 'Optus (AU)';             Confirmed = $false }
)

# Quick endpoint list for DNS/TCP checks.
$Endpoints = @(
    [pscustomobject]@{ Name = 'EU/NA API Gateway'; HostName = 'r5coopapigateway-eu-release.windrose.support'; TcpPort = 443; UdpPort = $null }
    [pscustomobject]@{ Name = 'CIS API Gateway';   HostName = 'r5coopapigateway-ru-release.windrose.support'; TcpPort = 443; UdpPort = $null }
    [pscustomobject]@{ Name = 'KR/SEA API Gateway';HostName = 'r5coopapigateway-kr-release.windrose.support'; TcpPort = 443; UdpPort = $null }
)

# CHANGED: public comparison STUN endpoints are checked before drawing UDP conclusions.
$PublicStunServers = @(
    [pscustomobject]@{ Name = 'Google STUN 1'; HostName = 'stun.l.google.com';  Port = 19302 }
    [pscustomobject]@{ Name = 'Google STUN 2'; HostName = 'stun1.l.google.com'; Port = 19302 }
    [pscustomobject]@{ Name = 'Cloudflare STUN'; HostName = 'stun.cloudflare.com'; Port = 3478 }
)

$WindroseUdpEndpoint = [pscustomobject]@{
    Name = 'Windrose STUN/TURN (probe target)'
    HostName = 'windrose.support'
    Port = 3478
}

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
    if ($IpAddress -match '^(\d{1,3}\.\d{1,3})\.\d{1,3}\.\d{1,3}$') {
        return "$($matches[1]).xxx.xxx"
    }
    return '(redacted)'
}

function New-StunBindingRequest {
    $txid = New-Object byte[] 12
    (New-Object System.Random).NextBytes($txid)

    $msg = New-Object byte[] 20
    $msg[0] = 0x00; $msg[1] = 0x01
    $msg[2] = 0x00; $msg[3] = 0x00
    $msg[4] = 0x21; $msg[5] = 0x12; $msg[6] = 0xA4; $msg[7] = 0x42
    [Array]::Copy($txid, 0, $msg, 8, 12)

    return [pscustomobject]@{ Bytes = $msg; TransactionId = $txid }
}

function Test-StunReply {
    param(
        [byte[]]$Response,
        [byte[]]$ExpectedTransactionId
    )

    if (-not $Response -or $Response.Length -lt 20) { return $false }

    # Conservative validation:
    # - STUN response class bits (message type high bits) should be 0x010x for success,
    #   or 0x011x for error response.
    # - Magic cookie must match RFC5389.
    # - Transaction ID should match request.
    $messageType = [int]$Response[0] -shl 8 -bor [int]$Response[1]
    $isResponseType = (($messageType -band 0x0110) -eq 0x0100)
    if (-not $isResponseType) { return $false }

    $cookieOk = ($Response[4] -eq 0x21 -and $Response[5] -eq 0x12 -and $Response[6] -eq 0xA4 -and $Response[7] -eq 0x42)
    if (-not $cookieOk) { return $false }

    for ($i = 0; $i -lt 12; $i++) {
        if ($Response[8 + $i] -ne $ExpectedTransactionId[$i]) { return $false }
    }

    return $true
}

function Invoke-StunProbe {
    <#
    CHANGED:
    - Returns a rich object (not just true/false) for safer verdict logic.
    - "No reply" is treated as endpoint-specific unless corroborated by public STUN failures.
    #>
    param(
        [string]$HostName,
        [int]$Port,
        [int]$TimeoutMs = 3000
    )

    $result = [ordered]@{
        HostName = $HostName
        Port = $Port
        DnsResolved = $false
        TargetIp = $null
        ProbeSent = $false
        UdpReplyReceived = $false
        ValidStunReply = $false
        Error = $null
    }

    $udp = $null
    try {
        $addr = [System.Net.Dns]::GetHostAddresses($HostName) |
                Where-Object { $_.AddressFamily -eq 'InterNetwork' } |
                Select-Object -First 1
        if (-not $addr) {
            $result.Error = 'No IPv4 address resolved.'
            return [pscustomobject]$result
        }

        $result.DnsResolved = $true
        $result.TargetIp = $addr.IPAddressToString

        $request = New-StunBindingRequest

        $udp = New-Object System.Net.Sockets.UdpClient
        $udp.Client.ReceiveTimeout = $TimeoutMs
        $udp.Client.SendTimeout = $TimeoutMs

        $endpoint = New-Object System.Net.IPEndPoint($addr, $Port)
        [void]$udp.Send($request.Bytes, $request.Bytes.Length, $endpoint)
        $result.ProbeSent = $true

        $remote = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, 0)
        $ar = $udp.BeginReceive($null, $null)
        $ok = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

        if ($ok) {
            $payload = $udp.EndReceive($ar, [ref]$remote)
            $result.UdpReplyReceived = $true
            $result.ValidStunReply = Test-StunReply -Response $payload -ExpectedTransactionId $request.TransactionId
        }
    } catch {
        $result.Error = $_.Exception.Message
    } finally {
        if ($udp) { $udp.Close() }
    }

    return [pscustomobject]$result
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
        $ok = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
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
Write-Line "  Windrose Quick Triage v$Version" 'Head'
Write-Line "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" 'Dim'
Write-Line "========================================================" 'Head'
Write-Line ''

# --- 1. Public IP and ISP ---------------------------------------------------

Write-Line "[1/6] Detecting public IP and ISP..." 'Head'
$ispName = $null
$ispFlag = $false
$ispMatch = $null
$publicIp = $null
try {
    $resp = Invoke-RestMethod -Uri 'https://ipinfo.io/json' -TimeoutSec 5 -ErrorAction Stop
    $publicIp = $resp.ip
    $ispName = $resp.org
    $asNumber = if ($ispName -match '^(AS\d+)\b') { $matches[1] } else { '(no AS)' }
    Write-Line "    Public IP : $(Protect-IpAddress $publicIp)" 'Info'
    Write-Line "    Network   : $asNumber" 'Info'
    Write-Line "    Country   : $($resp.country)" 'Info'

    foreach ($c in $CulpritIsps) {
        if ($ispName -match $c.Pattern) {
            $ispFlag = $true
            $ispMatch = $c.Name
            $tag = if ($c.Confirmed) { 'confirmed to block Windrose' } else { 'known to block similar P2P games' }
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

Write-Line "[2/6] Resolving Windrose endpoints..." 'Head'
$dnsFailures = 0
foreach ($ep in ($Endpoints + @([pscustomobject]@{ HostName = $WindroseUdpEndpoint.HostName; Name = $WindroseUdpEndpoint.Name }))) {
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

Write-Line "[3/6] Testing TCP connectivity..." 'Head'
$tcpFailures = 0
$tcpTargets = $Endpoints | Where-Object { $_.TcpPort }
foreach ($ep in $tcpTargets) {
    $ok = Test-TcpPort -HostName $ep.HostName -Port $ep.TcpPort -TimeoutMs 3000
    if ($ok) {
        Write-Line ("    OK   : {0,-28} {1}/tcp" -f $ep.Name, $ep.TcpPort) 'Good'
    } else {
        $tcpFailures++
        Write-Line ("    FAIL : {0,-28} {1}/tcp" -f $ep.Name, $ep.TcpPort) 'Bad'
    }
}
$tcpPassed = ($tcpFailures -eq 0)
Write-Line ''

# --- 4. Public STUN comparison ----------------------------------------------

Write-Line "[4/6] Comparing UDP/STUN with public test servers..." 'Head'
$publicStunResults = @()
foreach ($srv in $PublicStunServers) {
    $probe = Invoke-StunProbe -HostName $srv.HostName -Port $srv.Port -TimeoutMs 3000
    $publicStunResults += [pscustomobject]@{ Name = $srv.Name; HostName = $srv.HostName; Port = $srv.Port; Probe = $probe }

    if ($probe.ValidStunReply) {
        Write-Line ("    OK   : {0,-16} {1}:{2} (valid STUN reply)" -f $srv.Name, $srv.HostName, $srv.Port) 'Good'
    } elseif ($probe.UdpReplyReceived) {
        # Conservative: reply exists but parser unsure. Still evidence of UDP path activity.
        Write-Line ("    WARN : {0,-16} {1}:{2} (UDP reply received; STUN parse inconclusive)" -f $srv.Name, $srv.HostName, $srv.Port) 'Warn'
    } elseif (-not $probe.DnsResolved) {
        Write-Line ("    FAIL : {0,-16} {1}:{2} (DNS failed)" -f $srv.Name, $srv.HostName, $srv.Port) 'Bad'
    } else {
        Write-Line ("    FAIL : {0,-16} {1}:{2} (no UDP reply)" -f $srv.Name, $srv.HostName, $srv.Port) 'Bad'
    }
}
$publicStunAnyReply = ($publicStunResults | Where-Object { $_.Probe.UdpReplyReceived -or $_.Probe.ValidStunReply }).Count -gt 0
$publicStunValidCount = ($publicStunResults | Where-Object { $_.Probe.ValidStunReply }).Count
Write-Line ''

# --- 5. Windrose UDP probe --------------------------------------------------

Write-Line "[5/6] Probing Windrose UDP endpoint (non-authoritative probe)..." 'Head'
$windroseUdpProbe = Invoke-StunProbe -HostName $WindroseUdpEndpoint.HostName -Port $WindroseUdpEndpoint.Port -TimeoutMs 3000

if ($windroseUdpProbe.ValidStunReply) {
    Write-Line ("    OK   : {0} {1}/udp (valid STUN reply)" -f $WindroseUdpEndpoint.HostName, $WindroseUdpEndpoint.Port) 'Good'
} elseif ($windroseUdpProbe.UdpReplyReceived) {
    Write-Line ("    WARN : {0} {1}/udp (UDP reply received; STUN parse inconclusive)" -f $WindroseUdpEndpoint.HostName, $WindroseUdpEndpoint.Port) 'Warn'
} elseif (-not $windroseUdpProbe.DnsResolved) {
    Write-Line ("    FAIL : {0} {1}/udp (DNS resolution failed)" -f $WindroseUdpEndpoint.HostName, $WindroseUdpEndpoint.Port) 'Bad'
} else {
    # CHANGED: no "likely blocked" claim from single endpoint no-reply.
    Write-Line ("    WARN : {0} {1}/udp (no reply from tested endpoint)" -f $WindroseUdpEndpoint.HostName, $WindroseUdpEndpoint.Port) 'Warn'
    Write-Line "           This does NOT by itself prove ISP/router UDP blocking." 'Dim'
}
$windroseUdpAnyReply = $windroseUdpProbe.UdpReplyReceived -or $windroseUdpProbe.ValidStunReply
Write-Line ''

# --- 6. Latency to nearest gateway ------------------------------------------

Write-Line "[6/6] Measuring latency..." 'Head'
$nearest = $Endpoints | Select-Object -First 1
$latency = Get-PingLatency -HostName $nearest.HostName
if ($null -ne $latency) {
    $tag = if ($latency -lt 80) { 'Good' } elseif ($latency -lt 200) { 'Warn' } else { 'Bad' }
    Write-Line ("    {0,-28} ~ {1} ms" -f $nearest.Name, $latency) $tag
} else {
    Write-Line "    Could not measure latency (ICMP may be filtered)." 'Warn'
}
Write-Line ''

# --- Signal summary block ---------------------------------------------------

Write-Line "========================================================" 'Head'
Write-Line "  Signal summary" 'Head'
Write-Line "========================================================" 'Head'
Write-Line ("  TCP connectivity passed          : {0}" -f ($(if ($tcpPassed) { 'Yes' } else { 'No' }))) 'Info'
Write-Line ("  Public STUN had UDP reply        : {0}" -f ($(if ($publicStunAnyReply) { 'Yes' } else { 'No' }))) 'Info'
Write-Line ("  Public STUN valid-reply count    : {0}/{1}" -f $publicStunValidCount, $PublicStunServers.Count) 'Info'
Write-Line ("  Windrose UDP endpoint replied    : {0}" -f ($(if ($windroseUdpAnyReply) { 'Yes' } else { 'No' }))) 'Info'
Write-Line ''

# --- Verdict ----------------------------------------------------------------

Write-Line "========================================================" 'Head'
Write-Line "  Verdict" 'Head'
Write-Line "========================================================" 'Head'

$verdict = ''
$verdictKey = ''
$steps = @()

# CHANGED decision tree:
# - Prioritize general TCP/connectivity failures first.
# - Use public STUN comparison before suggesting broad UDP filtering.
# - Treat Windrose no-reply as endpoint-specific unless public STUN also fails.
if (-not $tcpPassed -and $dnsFailures -gt 0) {
    $verdict = 'General connectivity issue (DNS + TCP failures)'
    $verdictKey = 'GeneralConnectivity'
} elseif (-not $tcpPassed) {
    $verdict = 'General TCP/connectivity issue'
    $verdictKey = 'TcpFailure'
} elseif (-not $publicStunAnyReply) {
    $verdict = 'Likely broader UDP path filtering/blocking'
    $verdictKey = 'BroadUdpFailure'
} elseif ($publicStunAnyReply -and -not $windroseUdpAnyReply) {
    $verdict = 'Windrose UDP endpoint did not respond to this probe'
    $verdictKey = 'WindroseEndpointNoReply'
} elseif ($tcpPassed -and $publicStunAnyReply -and $windroseUdpAnyReply -and $ispFlag) {
    $verdict = 'Checks passed (ISP still on known-culprit list)'
    $verdictKey = 'IspOkButCulprit'
} elseif ($tcpPassed -and $publicStunAnyReply) {
    $verdict = 'No broad network issue detected by quick triage'
    $verdictKey = 'AllOk'
} else {
    $verdict = 'Mixed results, see details above'
    $verdictKey = 'Mixed'
}

switch ($verdictKey) {
    'GeneralConnectivity' {
        $steps += 'DNS and TCP checks are failing together. Prioritize restoring basic internet connectivity first.'
        $steps += 'Reboot modem/router and PC, then re-run this script.'
        $steps += 'Try a different DNS resolver (1.1.1.1 or 8.8.8.8), then run: ipconfig /flushdns.'
        $steps += 'Test from another network (mobile hotspot) to isolate local network vs ISP path issues.'
    }
    'TcpFailure' {
        $steps += 'TCP gateway checks are failing, so troubleshoot general outbound connectivity before focusing on UDP/STUN.'
        $steps += 'Temporarily disable third-party firewall/antivirus and test again.'
        $steps += 'Review router firewall/parental-control rules for this device.'
        $steps += 'If possible, compare results on a different network to isolate the failure domain.'
    }
    'BroadUdpFailure' {
        $steps += 'TCP checks passed, but public STUN servers did not reply. This pattern suggests broader UDP/path filtering.'
        $steps += 'Check ISP app/portal for security features (Security Shield / Advanced Security / Network Protection) and disable for testing.'
        $steps += 'Check router firewall, parental controls, VPN policy, and endpoint security software for UDP filtering.'
        $steps += 'A known-good VPN can help confirm whether the block is on the local/ISP path.'
    }
    'WindroseEndpointNoReply' {
        $steps += 'Public STUN replies were observed, so general UDP/STUN path appears functional.'
        $steps += 'The tested Windrose UDP endpoint did not respond to this generic probe. This alone is NOT proof of ISP/router UDP blocking.'
        $steps += 'Re-test later and compare with the full Captain''s Chest toolkit for additional Windrose-specific checks.'
        $steps += 'If gameplay still fails, share this log with support so they can correlate with service-side telemetry.'
    }
    'IspOkButCulprit' {
        $steps += 'Current quick checks passed, but your ISP has known history with game-impacting filtering.'
        $steps += 'If issues recur later, verify ISP security features are still disabled.'
        $steps += 'If connection failures continue, run the full Captain''s Chest toolkit for deeper diagnostics.'
    }
    'AllOk' {
        $steps += 'Quick triage did not detect broad DNS/TCP/UDP path failure.'
        $steps += 'If gameplay still fails, the issue may be endpoint-specific, temporary backend load, or client-side configuration.'
        $steps += 'Run the full Captain''s Chest toolkit and include both logs when requesting support.'
    }
    default {
        $steps += 'Signals are mixed. Re-run the test and gather the full Captain''s Chest output for support.'
    }
}

Write-Line ''
$vcolor = if ($verdictKey -in @('AllOk','IspOkButCulprit')) { 'Good' } elseif ($verdictKey -in @('WindroseEndpointNoReply','BroadUdpFailure','TcpFailure','GeneralConnectivity')) { 'Warn' } else { 'Bad' }
Write-Line "  $verdict" $vcolor
Write-Line ''

Write-Line "========================================================" 'Head'
Write-Line "  What to try" 'Head'
Write-Line "========================================================" 'Head'
Write-Line ''
$stepNum = 1
foreach ($s in $steps) {
    Write-Line "  $stepNum. $s" 'Info'
    Write-Line ''
    $stepNum++
}

Write-Line "========================================================" 'Head'
Write-Line "  Next steps" 'Head'
Write-Line "========================================================" 'Head'
Write-Line "  Full toolkit   : https://github.com/1r0nch3f/Windrose-Captain-Chest" 'Dim'
Write-Line "  Troubleshooting: https://github.com/1r0nch3f/Windrose-Troubleshooting" 'Dim'
Write-Line ''

# --- Save log ---------------------------------------------------------------

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$desktop = [Environment]::GetFolderPath('Desktop')
$logPath = Join-Path $desktop "Windrose-Triage-$timestamp.log"

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
