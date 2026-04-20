# Steam ticket authentication failures

## What you'll see in the log

Look for lines from `R5LogSteamworks` around `GetSteamTicket` or `OnGetTicketForWebApiResponse`, followed by errors from `R5LogHttp` or `R5LogAuthProxy` indicating authentication failed.

A healthy flow looks like:

```
R5LogSteamworks: UR5SteamAuthClient::GetSteamTicket  Get new request for steam ticket
R5LogSteamworks: OnGetTicketForWebApiResponse  Steam ticket response for ticket: <n>, result k_EResultOK
R5LogHttp: UR5BaseHttpClient::HttpRequest  Sent request. Route https://r5coopapigateway-*.windrose.support/api/v1/Auth/AuthenticateClientBySteam. IsOk true
R5LogHttp: UR5BaseHttpClient::ProcessReply  Reply received. IsOk true
```

If you see `k_EResult` values other than `OK`, the ticket didn't generate. If you see HTTP errors at the `AuthenticateClientBySteam` step, the backend rejected the ticket.

## What it means

The game obtains an authentication ticket from Steam, then sends it to the Windrose backend to prove the player is who they say they are. If Steam can't produce a ticket, or the backend rejects it, authentication fails and no further progress happens.

## Common causes

### Steam is in offline mode

The ticket flow requires Steam to contact Steam's servers. Offline mode blocks that.

Fix: Steam menu, Go Online.

### Stale Steam session

Steam occasionally gets into a state where it thinks it's online but its session is stale.

Fix: fully quit Steam (check the system tray), restart, sign in.

### Game launched outside Steam

The game needs to be launched through Steam to have a live Steamworks context. Desktop shortcuts sometimes launch the game directly, bypassing Steam's auth setup.

Fix: launch from your Steam library.

### Clock skew

Auth tickets are time-sensitive. If your system clock is significantly off, tickets may be rejected.

Fix: enable automatic time sync in your OS settings.

### Linux/Proton quirks

Steam's ticket generation under Proton generally works, but specific Proton versions have been reported to produce tickets the backend doesn't like.

Fix: try switching to Proton Experimental, Proton GE, or a different stable Proton version.

### VPN or proxy blocking the backend

The backend gateway (`r5coopapigateway-*.windrose.support`) must be reachable. VPNs and filtering proxies can break this.

Fix: test with the VPN/proxy off.

## Related errors

If Steam auth succeeds but the connection still fails later with a [BL disconnect](bl-disconnect.md), the ticket was accepted but something later in the handshake broke.
