---
name: reference_telnyx_voice
description: Telnyx voice infrastructure — API key in Keychain, Claudia's phone number, connection details
type: reference
---

Claudia's phone number: **+1 305 501 6501** (Telnyx, Miami area code)

- Telnyx API key stored in macOS Keychain: `security find-generic-password -s "telnyx-api-key" -w`
- TeXML Application: `claudia-pipecat` → webhook `https://voice.xurman.com/webhook/telnyx`
- Pipecat voice service runs on VPS at port 7860, behind nginx
- Replaces previous Twilio setup (+18596952433)
