# Authentication Patterns

Login flows, session persistence, OAuth, and 2FA patterns for icc browser surfaces.

**Related**: [session-management.md](session-management.md), [SKILL.md](../SKILL.md)

## Contents

- [Basic Login Flow](#basic-login-flow)
- [Saving Authentication State](#saving-authentication-state)
- [Restoring Authentication](#restoring-authentication)
- [OAuth / SSO Flows](#oauth--sso-flows)
- [Two-Factor Authentication](#two-factor-authentication)
- [Cookie-Based Auth](#cookie-based-auth)
- [Token Refresh Handling](#token-refresh-handling)
- [Security Best Practices](#security-best-practices)

## Basic Login Flow

```bash
icc browser open https://app.example.com/login --json
icc browser surface:7 wait --load-state complete --timeout-ms 15000

icc browser surface:7 snapshot --interactive
# [ref=e1] email, [ref=e2] password, [ref=e3] submit

icc browser surface:7 fill e1 "user@example.com"
icc browser surface:7 fill e2 "$APP_PASSWORD"
icc browser surface:7 click e3 --snapshot-after --json
icc browser surface:7 wait --url-contains "/dashboard" --timeout-ms 20000
```

## Saving Authentication State

After logging in, save state for reuse:

```bash
icc browser surface:7 state save ./auth-state.json
```

State includes cookies, localStorage, sessionStorage, and open tab metadata for that surface.

## Restoring Authentication

```bash
icc browser open https://app.example.com --json
icc browser surface:8 state load ./auth-state.json
icc browser surface:8 goto https://app.example.com/dashboard
icc browser surface:8 snapshot --interactive
```

## OAuth / SSO Flows

```bash
icc browser open https://app.example.com/auth/google --json
icc browser surface:7 wait --url-contains "accounts.google.com" --timeout-ms 30000
icc browser surface:7 snapshot --interactive

icc browser surface:7 fill e1 "user@gmail.com"
icc browser surface:7 click e2 --snapshot-after --json

icc browser surface:7 wait --url-contains "app.example.com" --timeout-ms 45000
icc browser surface:7 state save ./oauth-state.json
```

## Two-Factor Authentication

```bash
icc browser open https://app.example.com/login --json
icc browser surface:7 snapshot --interactive
icc browser surface:7 fill e1 "user@example.com"
icc browser surface:7 fill e2 "$APP_PASSWORD"
icc browser surface:7 click e3

# complete 2FA manually in the webview, then:
icc browser surface:7 wait --url-contains "/dashboard" --timeout-ms 120000
icc browser surface:7 state save ./2fa-state.json
```

## Cookie-Based Auth

```bash
icc browser surface:7 cookies set session_token "abc123xyz"
icc browser surface:7 goto https://app.example.com/dashboard
```

## Token Refresh Handling

```bash
#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="./auth-state.json"
SURFACE="surface:7"

if [ -f "$STATE_FILE" ]; then
  icc browser "$SURFACE" state load "$STATE_FILE"
fi

icc browser "$SURFACE" goto https://app.example.com/dashboard
URL=$(icc browser "$SURFACE" get url)

if printf '%s' "$URL" | grep -q '/login'; then
  icc browser "$SURFACE" snapshot --interactive
  icc browser "$SURFACE" fill e1 "$APP_USERNAME"
  icc browser "$SURFACE" fill e2 "$APP_PASSWORD"
  icc browser "$SURFACE" click e3
  icc browser "$SURFACE" wait --url-contains "/dashboard" --timeout-ms 20000
  icc browser "$SURFACE" state save "$STATE_FILE"
fi
```

## Security Best Practices

1. Never commit state files (they include auth tokens).
2. Use environment variables for credentials.
3. Clear state/cookies after sensitive tasks:

```bash
icc browser surface:7 cookies clear
rm -f ./auth-state.json
```
