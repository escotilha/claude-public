---
name: mistake:chrome-devtools-mcp-fill-bypasses-react
description: chrome-devtools MCP fill tool sets DOM input.value directly which bypasses React's onChange — react-hook-form sees empty values and Zod validation fails silently. Use type_text or evaluate_script with native input event dispatch instead.
type: feedback
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
The `mcp__chrome-devtools__fill` tool writes directly to `inputElement.value`. This skips the standard React onChange propagation: React's synthetic event system listens on the actual input event, which `value =` assignment does NOT fire. So:

- The DOM looks correct (value shows in the field)
- But react-hook-form's internal state stays empty
- Zod validation runs against the empty internal state → fails
- Submit button stays disabled or form errors complain "field required"
- The test/automation looks broken; the form is fine

Hit during the 2026-04-29 R-0 walkthrough investigating Carlos's portal login. Initially appeared as a real RSC bug ("clicks navigate before POST fires"). False alarm: portal login form is correct. The artifact was the testing tool.

**How to apply:**

1. **Avoid `mcp__chrome-devtools__fill` for any React form** that uses react-hook-form, Formik, controlled-component pattern, or Zod validation. The tool's contract works for vanilla HTML forms but not for React.

2. **Use `type_text` instead** — simulates real keystrokes which DO fire input events through React's synthetic event system.

3. **Or use `evaluate_script`** to dispatch a native input event after setting the value:
   ```javascript
   const input = document.querySelector('input[name="email"]');
   const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
   setter.call(input, 'p@contably.ai');
   input.dispatchEvent(new Event('input', { bubbles: true }));
   ```
   This is the pattern React's testing-library uses for the same reason.

4. **Diagnostic check**: if a chrome-devtools fill SEEMS to work but the form's submit button stays disabled or validation errors say "field required" despite the field showing text — it's this bug, not a real form issue.

**Why this matters for QA loops:** any virtual-user or persona-test skill that uses chrome-devtools fill on Contably portal/admin will produce false positives ("login is broken!") that aren't real bugs. The contably product code is correct; only the test harness is wrong.

---

## Timeline

- **2026-04-29** — [failure] During R-0 staging walkthrough, attempted to test portal login as Carlos using chrome-devtools fill. Form refused to submit. Initial diagnosis: RSC navigation hijacking the click. Real diagnosis after code review: the form is correct, fill bypassed onChange, react-hook-form had empty state. Documented in docs/contably-alpha-roadmap-2026-Q2.md (2026-04-29 14:30 entry, point 5). Roadmap initially listed this as an alpha blocker; later corrected to "false alarm — testing artifact, not a real bug." (Source: failure — chrome-devtools-mcp fill on portal login form during R-0 walkthrough)
- **2026-04-30** — [consolidation] Promoted to `mistake:` memory per /cto retrospective recommendation. Cross-link to QA skills that may use chrome-devtools fill: virtual-user-testing, qa-conta, fulltest-skill. (Source: consolidation — CTO retro at .cto/review-2026-04-30-cascade-retrospective.md item #4)

Related:
- [pattern:autobrowse-failure-to-insight](pattern_autobrowse_failure_to_insight.md) — same general theme: browser-automation tooling lying about what the page actually saw
