# Kill Switch — iOS Shortcut Setup

Two options: SSH to your Mac, or direct API calls from phone.

## Option A: SSH to Mac Mini (simplest)

1. Open iOS Shortcuts app
2. Create new shortcut: "Kill VPS"
3. Add action: "Run Script over SSH"
   - Host: `100.66.244.112` (Mac Mini Tailscale IP)
   - Port: `22`
   - User: `psm2`
   - Auth: password or key
   - Script: `killswitch --force`
4. Optionally add to Home Screen as a red icon

Pros: Simplest, reuses all credential management on Mac.
Cons: Requires Mac Mini to be reachable (via Tailscale).

## Option B: Direct API calls (works without Mac)

Create an iOS Shortcut with these actions in sequence:

### Step 1: Get Contabo Token

- Action: "Get Contents of URL"
- URL: `https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token`
- Method: POST
- Request Body: Form
  - `client_id`: (your client ID)
  - `client_secret`: (your client secret)
  - `username`: (your API user email)
  - `password`: (your API password)
  - `grant_type`: password
- Save result to variable: `tokenResponse`

### Step 2: Extract token

- Action: "Get Value for Key" on `tokenResponse`
- Key: `access_token`
- Save to variable: `token`

### Step 3: Stop VPS

- Action: "Get Contents of URL"
- URL: `https://api.contabo.com/v1/compute/instances/YOUR_INSTANCE_ID/actions/stop`
- Method: POST
- Headers:
  - `Authorization`: `Bearer [token variable]`
  - `x-request-id`: (use "Generate UUID" action)
  - `Content-Type`: `application/json`

### Step 4: Remove from Tailscale

- Action: "Get Contents of URL"
- URL: `https://api.tailscale.com/api/v2/device/YOUR_DEVICE_ID`
- Method: DELETE
- Headers:
  - `Authorization`: `Basic [base64 of "TAILSCALE_API_KEY:"]`

### Step 5: Show notification

- Action: "Show Notification"
- Title: "VPS KILLED"
- Body: "Contabo stopped + Tailscale removed"

## WhatsApp Trigger

If you want WhatsApp to trigger the kill:

1. Set up Option A (SSH shortcut)
2. Create an iOS Automation: "When I receive a WhatsApp message containing 'KILLVPS'"
3. Have it run the "Kill VPS" shortcut

Or simpler: just open the shortcut manually from your phone. In an emergency,
tapping one icon is fast enough.
