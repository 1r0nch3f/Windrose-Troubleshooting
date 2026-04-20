# R5EosProxySystem skip

## What you'll see in the log

```
R5LogEosProxy: FR5EosProxyModule::StartupModule  Skip eos sdk init by config
...
LogSubsystemCollection: Failed to initialize subsystem dependency (R5EosProxySystem)
```

## What it means

Epic Online Services (EOS) integration is deliberately disabled in current Windrose builds. The game authenticates through Steam, not EOS, and the EOS module's initialization is skipped by configuration. The "Failed to initialize subsystem dependency" log line is a follow-on effect of the skip, not a real failure.

## Is this a problem?

**No.** This appears in the logs of players who connect successfully. It's expected and benign.

## Safe to ignore

If you're troubleshooting a connection issue and this is the only suspicious line you see, it's not the cause. Look elsewhere.

## Why is it logged as a failure then?

The subsystem framework logs "Failed to initialize" whenever a module skips its init phase, regardless of whether the skip was intentional. It's a quirk of how Unreal's subsystem lifecycle reports intentional no-ops.
