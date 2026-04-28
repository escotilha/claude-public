---
name: gemini-api
description: "Guides usage of the Gemini API on Google Agent Platform (formerly Vertex AI) with the Google Gen AI SDK. Use when the user asks about using Gemini models, Vertex AI, Google Agent Platform, or the google-genai SDK. Covers SDK usage (Python, JS/TS, Go, Java, C#), text/multimodal generation, function calling, structured output, context caching, embeddings, Live Realtime API, and batch prediction."
user-invocable: false
context: inline
model: sonnet
effort: medium
allowed-tools:
  - Read
  - WebFetch
  - Bash
---

# Gemini API — Google Agent Platform

IMPORTANT: "Agent Platform" (full name: Gemini Enterprise Agent Platform) was previously named "Vertex AI". Many web resources use the legacy branding.

## Core Directives

- **Always use the unified Gen AI SDK** — `google-genai` (Python), `@google/genai` (JS/TS), `google.golang.org/genai` (Go), `com.google.genai:google-genai` (Java), `Google.GenAI` (C#).
- **Never use legacy SDKs** — `google-cloud-aiplatform`, `@google-cloud/vertexai`, `google-generativeai` are deprecated.

## Models

| Model | Use case | Context |
|---|---|---|
| `gemini-3.1-pro-preview` | Complex reasoning, coding, research | 1M tokens |
| `gemini-3-flash-preview` | Fast, balanced, multimodal | 1M tokens |
| `gemini-3-pro-image-preview` | Image generation & editing | — |
| `gemini-3.1-flash-image-preview` | Image generation & editing | — |
| `gemini-live-2.5-flash-native-audio` | Live Realtime API (audio/video) | — |

> Models `gemini-2.0-*`, `gemini-1.5-*`, `gemini-1.0-*` are legacy/deprecated — use models above.

## Authentication

### Application Default Credentials (ADC)

```bash
export GOOGLE_CLOUD_PROJECT='your-project-id'
export GOOGLE_CLOUD_LOCATION='global'   # use 'global' by default for auto-routing
export GOOGLE_GENAI_USE_VERTEXAI=true
```

### Express Mode (API key)

```bash
export GOOGLE_API_KEY='your-api-key'
export GOOGLE_GENAI_USE_VERTEXAI=true
```

### Client initialization (Python)

```python
from google import genai
client = genai.Client()  # picks up env vars automatically
```

## Quick Start

### Python

```python
from google import genai
client = genai.Client()
response = client.models.generate_content(
    model="gemini-3-flash-preview",
    contents="Explain quantum computing"
)
print(response.text)
```

### TypeScript/JavaScript

```typescript
import { GoogleGenAI } from "@google/genai";
const ai = new GoogleGenAI({ vertexai: { project: "your-project-id", location: "global" } });
const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: "Explain quantum computing"
});
console.log(response.text);
```

## Reference files (load on demand)

- **[references/text_and_multimodal.md](references/text_and_multimodal.md)** — Chat, multimodal inputs (image/video/audio), streaming
- **[references/structured_and_tools.md](references/structured_and_tools.md)** — JSON generation, function calling, search grounding, code execution
- **[references/embeddings.md](references/embeddings.md)** — Text embeddings for semantic search
- **[references/advanced_features.md](references/advanced_features.md)** — Content caching, batch prediction, thinking/reasoning, MCP
- **[references/media_generation.md](references/media_generation.md)** — Image and video generation
- **[references/live_api.md](references/live_api.md)** — Real-time bidirectional streaming (voice, vision, text)
- **[references/safety.md](references/safety.md)** — Responsible AI filters and thresholds
- **[references/model_tuning.md](references/model_tuning.md)** — Supervised fine-tuning and preference tuning

## Docs

- Agent Platform overview: https://docs.cloud.google.com/gemini-enterprise-agent-platform/overview
- REST API reference: https://docs.cloud.google.com/gemini-enterprise-agent-platform/reference/rest
- Auth guide: https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/gcp-auth
- Python samples: https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/genai
