---
name: good-observability
description: Observability review and implementation standards for Effect-TS tracing. Use when adding spans, reviewing instrumentation, or auditing observability coverage.
---

# Observability Standards

Review instrumentation in an Effect-TS codebase exporting traces to LaunchDarkly Observability via OTLP. Ensure traces contain enough context to debug errors and derive usage metrics without cluttering business logic.

---

## Span Naming Rules

Pattern: `[section].[namespace].[action]`

### Rules

1. **Three segments**: section, namespace/object, action verb
2. **camelCase** for multi-word segments: `getSnapshot` not `get_snapshot`
3. **Singular nouns** for handlers: `statement` not `statements`
4. **Low cardinality**: no IDs, timestamps, or user data in names
5. **No outcomes in names**: `validate` not `validateFailed`

### Section Prefixes

| Section      | Use                    |
| ------------ | ---------------------- |
| `api`        | HTTP handlers          |
| `repo`       | Repository operations  |
| `middleware` | Request processing     |
| `driver`     | External service calls |

### Examples

```typescript
// CORRECT
"api.statement.create";
"api.drill.create";
"repo.account.getAll";
"repo.snapshot.getLatest";
"middleware.stytch.authenticate";
"driver.googleSheets.write";
"driver.nango.sync"
// WRONG: high cardinality
`api.statement.create.user-${userId}`;

// WRONG: outcome in name
("api.statement.createFailed");

// WRONG: too generic
("process");
("handler");

// WRONG: snake_case
("repo.account.get_all");
```

---

## Attribute Naming Rules

Pattern: `[category].[subcategory]` with dot separation and snake_case within segments.

### Rules

1. **Dot-separated namespaces**: `user.organization_id` not `organizationId`
2. **snake_case** within segments: `organization_id` not `organizationID`
3. **Category prefixes**: group related attributes
4. **Input/Output distinction**: Use different prefixes for inputs vs outputs

### Input/Output Attribute Naming

Every span must capture important inputs and outputs. Use these prefixes:

| Operation Type | Inputs      | Outputs      |
| -------------- | ----------- | ------------ |
| Network (HTTP) | `request.*` | `response.*` |
| Non-network    | `props.*`   | `result.*`   |

**Examples**:

```typescript
// HTTP/Network operations
Effect.withSpan("api.statement.create", {
  attributes: {
    "request.spreadsheet_id": payload.spreadsheetId,
    "request.has_budget": payload.includeBudget,
  },
});
// After completion: response.status, response.sheet_name

// Database/Service operations
Effect.withSpan("driver.googleSheets.write", {
  attributes: {
    "props.spreadsheet_id": spreadsheetId,
    "props.sheet_count": pages.length,
  },
});
// After completion: result.sheet_id, result.rows_written

// Middleware
Effect.withSpan("middleware.stytch.authenticate", {
  attributes: {
    "props.has_token": !!token,
  },
});
// After completion: result.member_id, result.organization_id
```

### Standard Categories

| Category     | Use                 | Examples                                        |
| ------------ | ------------------- | ----------------------------------------------- |
| `user.*`     | Tenant/user context | `user.organization_id`, `user.member_id`        |
| `request.*`  | Network inputs      | `request.spreadsheet_id`, `request.has_budget`  |
| `response.*` | Network outputs     | `response.status`, `response.sheet_name`        |
| `props.*`    | Non-network inputs  | `props.org_id`, `props.snapshot_id`             |
| `result.*`   | Non-network outputs | `result.count`, `result.sheet_id`               |
| `db.*`       | Database metrics    | `db.rows_returned`, `db.rows_affected`          |
| `error.*`    | Error context       | `error.type`, `error.message`, `error.input_id` |
| `feature.*`  | Usage analytics     | `feature.report_type`, `feature.has_group_by`   |
| `http.*`     | HTTP metadata       | `http.method`, `http.url`, `http.status_code`   |

### Required Attributes

**API handlers**: `user.organization_id`, relevant `request.*` params, `response.*` on completion

**Database ops**: `db.rows_returned` or `db.rows_affected` (on framework span, not custom wrapper)

**External calls**: `props.*` inputs, `result.*` outputs

**Middleware**: `props.*` inputs, `result.*` outputs (e.g., extracted IDs)

---

## ERROR HANDLING

Errors must be traceable. Effect captures errors automatically; enhance with context.

### Pattern

```typescript
yield *
  operation.pipe(
    Effect.tapErrorCause((cause) =>
      Effect.annotateCurrentSpan({
        error: true,
        "error.type": cause._tag,
        "error.message": Cause.pretty(cause),
        "error.input_id": inputId,
      }),
    ),
    Effect.withSpan("repo.account.getById", {
      attributes: { "request.account_id": inputId },
    }),
  );
```

### Required Error Attributes

- `error`: boolean, always `true`
- `error.type`: Effect tag or exception class
- `error.message`: human-readable description
- `error.input_*`: inputs that caused the error (for reproduction)

---

## TRACE GAPS

**Dark time**: unaccounted time in a trace waterfall. If a root span shows 13.5s but child spans sum to 12.8s, 700ms is dark time.

### Common Sources

| Source             | Solution                                     |
| ------------------ | -------------------------------------------- |
| Auth middleware    | Span: `middleware.stytch.authenticate`       |
| Google OAuth       | Span: `middleware.googleOAuth.validateToken` |
| Request parsing    | Span: `middleware.parseBody`                 |
| Route matching     | Span: `middleware.routing`                   |
| DB pool checkout   | Ensure driver captures pool wait             |
| External API calls | Wrap in span: `driver.{service}.{action}`    |

### The Rule

Dark time should be < 5% of total request duration. If a span's self time exceeds 100ms, you must know what code executes during that time.

---

## CLIENT-INITIATED TRACING

Server traces capture server work. They cannot capture network latency, DNS/TCP/TLS time, or client processing. Client-generated trace IDs enable correlation.

### W3C traceparent Format

```
traceparent: 00-{traceId}-{spanId}-{flags}
```

- `traceId`: 32 hex chars
- `spanId`: 16 hex chars
- `flags`: `01` (sampled)

### Client (React/Fetch)

```typescript
function generateTraceId(): string {
  const array = new Uint8Array(16);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

function generateSpanId(): string {
  const array = new Uint8Array(8);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

async function apiCall<T>(endpoint: string, payload: unknown): Promise<T> {
  const traceId = generateTraceId();
  const spanId = generateSpanId();
  const traceparent = `00-${traceId}-${spanId}-01`;
  const startTime = performance.now();

  try {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json", traceparent: traceparent },
      body: JSON.stringify(payload),
    });
    const clientDuration = Math.round(performance.now() - startTime);
    console.info(
      `[TRACE] traceId=${traceId} client=${clientDuration}ms status=${response.status}`,
    );
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  } catch (error) {
    const clientDuration = Math.round(performance.now() - startTime);
    console.error(
      `[TRACE] traceId=${traceId} client=${clientDuration}ms error=${error}`,
    );
    throw error;
  }
}
```

### Server (Effect-TS)

```typescript
const extractTraceId = (
  request: HttpServerRequest.HttpServerRequest,
): string | undefined => {
  const traceparent = request.headers["traceparent"];
  if (!traceparent) return undefined;
  const parts = traceparent.split("-");
  return parts.length === 4 ? parts[1] : undefined;
};

// In tracing middleware
const clientTraceId = extractTraceId(request);
if (clientTraceId) {
  yield * Effect.annotateCurrentSpan("trace.client_id", clientTraceId);
}
```

### CORS

```typescript
allowedHeaders: ["Content-Type", "Authorization", "traceparent"],
exposedHeaders: ["Server-Timing"]
```

### Network Time

```typescript
const networkTime = clientDuration - serverDuration;
```

---

## EFFECT FRAMEWORK SPANS

Effect-TS creates framework spans automatically. Understanding them prevents duplication and noise.

### Root Spans (HTTP Server)

Effect's HTTP server creates root spans: `http.server {method}` (e.g., `http.server POST`).

**Rule**: Do NOT create duplicate root spans. Instead, annotate the existing span:

```typescript
// WRONG: Creates duplicate root span
export const tracingMiddleware = <E, R>(app: HttpApp.Default<E, R>) =>
  app.pipe(
    Effect.withSpan("middleware.tracing.httpRequest", { ... }) // Duplicate!
  )

// CORRECT: Annotate existing span
export const tracingMiddleware = <E, R>(app: HttpApp.Default<E, R>) =>
  Effect.gen(function*() {
    const request = yield* HttpServerRequest.HttpServerRequest
    const clientTraceId = extractClientTraceId(request)
    if (clientTraceId) {
      yield* Effect.annotateCurrentSpan("trace.client_id", clientTraceId)
    }
    // Process app without creating new span
    return yield* app
  })
```

### SQL Resolver Spans

Effect SQL creates spans for every resolver operation. These cannot be disabled.

| Span Name                    | Created When                 | Useful For          |
| ---------------------------- | ---------------------------- | ------------------- |
| `sql.Resolver.execute {tag}` | Individual request execution | Request timing      |
| `sql.Resolver.batch {tag}`   | Batch processing             | Batch size analysis |
| `sql.execute`                | Actual SQL execution         | Query debugging     |

**CRITICAL RULE**: Do NOT wrap SQL Resolver operations with custom `repo.*` spans. The framework already provides spans. Adding custom spans creates duplicate/redundant nesting.

```typescript
// WRONG: Creates redundant span wrapping framework span
const snapshot = yield* snapshotRepo.getLatest(orgId).pipe(
  Effect.tap((s) => Effect.annotateCurrentSpan("db.rows_returned", 1)),
  Effect.withSpan("repo.snapshot.getLatest", { ... }) // WRONG: Duplicates sql.Resolver span
)

// CORRECT: Annotate the framework span directly, no custom wrapper
const snapshot = yield* snapshotRepo.getLatest(orgId).pipe(
  Effect.tap((s) => Effect.annotateCurrentSpan({
    "props.org_id": orgId,
    "result.snapshot_id": s.id.toString(),
    "db.rows_returned": 1
  }))
)
```

**Where to add `db.rows_returned`**: On the framework's `sql.Resolver.execute` span via `Effect.tap` annotation, NOT on a custom wrapper span.

**Guidance**:

- `sql.execute` is the most useful; contains actual SQL query
- `sql.Resolver.batch` shows batching behavior
- Use `Effect.tap` to annotate the existing framework span with `props.*`, `result.*`, and `db.rows_returned`
- NEVER create custom `repo.*` spans around repository calls

---

## TYPEID SERIALIZATION

TypeIDs are objects with `.toString()` methods. OpenTelemetry attributes must be primitives.

**Rule**: Always call `.toString()` when passing TypeIDs as span attributes:

```typescript
// WRONG: Serializes as {"type":"snapshot","suffix":"..."}
Effect.annotateCurrentSpan("request.snapshot_id", snapshot.id);

// CORRECT: Serializes as "snapshot_01h2x3y4z5..."
Effect.annotateCurrentSpan("request.snapshot_id", snapshot.id.toString());
```

This applies to all domain IDs: `accountId`, `snapshotId`, `scenarioId`, etc.

---

## WHEN TO INSTRUMENT

### Always

- API entry points
- External I/O (database, APIs, files)
- Batch operations

### Never

- Pure computations
- Trivial getters
- Internal helpers

One span per meaningful business operation. If you cannot describe it as "a thing the system does," it does not need a span.

---

## SCORING (1000 points)

### Coverage (400)

| Criterion                            | Points |
| ------------------------------------ | ------ |
| API entry points have root spans     | 150    |
| External I/O traced                  | 150    |
| Key business operations instrumented | 100    |

### Quality (400)

| Criterion                             | Points |
| ------------------------------------- | ------ |
| Span naming follows pattern           | 150    |
| Attributes namespaced with IDs/counts | 150    |
| Errors include type, message, inputs  | 100    |

### Hygiene (200)

| Criterion                      | Points |
| ------------------------------ | ------ |
| < 25 spans per request         | 100    |
| Tracing does not obscure logic | 100    |

---

## DEDUCTIONS

### Critical (-50 each)

- ID/timestamp in span name
- Missing root span on handler
- No `user.organization_id`
- `console.log` instead of `Effect.log`
- > 10% dark time
- > 200ms unexplained self time
- Duplicate root span (creating span when Effect already provides one)
- Custom `repo.*` span wrapping SQL Resolver operation (use annotation instead)
- Client not sending `traceparent` header

### Severe (-25 each)

- Flat attribute names (`orgId` vs `organization.id`)
- Missing `error.type` on errors
- Gap between middleware and handler spans
- Missing count attributes on batch ops
- TypeID serialized as object (missing `.toString()`)
- Missing `db.rows_returned` on SQL Resolver spans
- Missing `props.*` or `result.*` attributes on spans
- Using `request.*` for non-network operations (should use `props.*`)

### Moderate (-10 each)

- Missing `feature.*` attributes
- > 3 log statements per operation
- 5-10% dark time

---

## REVIEW CHECKLIST

### Naming

- [ ] Spans follow `[section].[namespace].[action]`
- [ ] camelCase for multi-word segments
- [ ] Singular nouns for handlers
- [ ] No IDs or timestamps in span names
- [ ] Attributes use dot-namespaced keys

### Coverage

- [ ] API handlers have root span (via Effect, not duplicated)
- [ ] SQL Resolver operations NOT wrapped with custom `repo.*` spans
- [ ] `db.rows_returned` annotated on framework SQL spans
- [ ] External API calls traced with custom spans
- [ ] Dark time < 5%
- [ ] Google OAuth validation has span

### Errors

- [ ] `Effect.tapErrorCause` with context
- [ ] `error.type` and `error.message` present
- [ ] `error.input_*` for reproduction

### Client Tracing

- [ ] Client generates trace ID via `tracedFetch` utility
- [ ] `traceparent` header sent with every API call
- [ ] Server extracts and annotates `trace.client_id`
- [ ] Client logs timing with trace ID

### Attributes

- [ ] TypeIDs use `.toString()` in attributes
- [ ] No object serialization in attributes (all primitives)
- [ ] Framework spans not duplicated
- [ ] Network operations use `request.*`/`response.*` for inputs/outputs
- [ ] Non-network operations use `props.*`/`result.*` for inputs/outputs
- [ ] Every span captures important inputs AND outputs

---

## VIEWING TRACES FROM LAUNCHDARKLY

LaunchDarkly does not expose a CLI or API for trace queries. Traces must be retrieved manually from the web UI and pasted into the conversation.

### How Trace IDs Appear in Logs

**Server logs** emit trace IDs at request completion:

```
[TRACE] trace_id=abc123def456 span_id=789xyz method=POST path=/v1/statement status=200 duration=1523ms
```

**Client logs** (when using `tracedFetch`) emit:

```
[TRACE] trace_id=abc123def456 client=1823ms status=200
```

The `trace_id` correlates server and client spans. The `span_id` identifies the root HTTP span. Use `span_id` to find the trace in LaunchDarkly.

### Workflow: AI Requesting Trace Data

When debugging requires trace inspection:

1. **AI identifies the trace ID** from server logs or asks the user for it
2. **AI provides a direct link** to the LaunchDarkly UI
3. **User copies the trace JSON** from the UI
4. **User pastes JSON** into the conversation for analysis

**AI prompt template:**

```
To debug this issue, I need the trace data. Please:

1. Open this link:
   https://app.launchdarkly.com/projects/default/traces?query=span_id%3D{SPAN_ID}&relativeTime=last_24_hours&env=dev-mh

2. Click on the trace to open the waterfall view
3. Click "Copy json" (top-right of the trace panel) to export all spans
4. Paste the full trace JSON here

If the trace is very large, you can alternatively:
- Right-click a specific span → "Copy span and child spans as json" for a subtree
```

**Note:** Full trace export (all spans) is now supported. This is preferred over exporting individual spans.

### LaunchDarkly Trace URL Format

```
https://app.launchdarkly.com/projects/{PROJECT}/traces?query={QUERY}&page=1&relativeTime={TIME}&env={ENV}&selected-env={ENV}
```

| Parameter | Value                                                                                                 |
| --------- | ----------------------------------------------------------------------------------------------------- |
| `PROJECT` | `default` (or your project key)                                                                       |
| `QUERY`   | URL-encoded query, e.g., `span_id%3Dabc123`                                                           |
| `TIME`    | `last_15_minutes`, `last_hour`, `last_24_hours`, `last_7_days`                                        |
| `ENV`     | Environment key, e.g., `dev-mh`, `dev-ps`, `dev-sm`, `dev-[developer initials]`, `test`, `production` |

**Query examples:**

```
# By span ID (preferred - directly from server logs)
span_id=789xyz

# By trace ID
trace_id=abc123def456

# By span name
span_name=api.statement.create

# By span ID and errors
span_id=789xyz AND has_errors=true
```

### Copying Trace/Span JSON

LaunchDarkly supports **three export options**:

| Export Option | Location | What it Copies |
|---------------|----------|----------------|
| **Copy json** | Top-right of trace panel | ALL spans in the trace |
| **Copy span as json** | Span context menu (⋯) | Single span only |
| **Copy span and child spans as json** | Span context menu (⋯) | Parent span + all descendants |

**Recommended workflow:**

1. Click on a trace to open the waterfall view
2. For **full trace analysis**: Click **Copy json** (top-right) to get all spans
3. For **subtree analysis**: Right-click a span → **Copy span and child spans as json**
4. Paste the JSON into conversation for analysis

**Note:** Full trace export is preferred for debugging. Use subtree export when focusing on a specific operation branch.

### Analyzing Trace JSON

**Full trace export** returns an array of spans:

```json
[
  {
    "timestamp": "2025-01-13 10:00:00.000 AM",
    "span_name": "http.server POST",
    "duration": "1.5s",
    "parent_span_id": null,
    "trace_id": "def456",
    "span_id": "ghi789",
    "service_name": "fpna-internal",
    ...
  },
  {
    "span_name": "api.statement.create",
    "duration": "1.2s",
    "parent_span_id": "ghi789",
    ...
  }
]
```

**Single span** structure:

```json
{
  "timestamp": "2025-01-13 10:00:00.000 AM",
  "span_name": "api.statement.create",
  "duration": "1.5s",
  "parent_span_id": "abc123",
  "trace_id": "def456",
  "span_id": "ghi789",
  "service_name": "fpna-internal",
  "http": { ... },
  "props": { ... },
  "result": { ... },
  "events": { ... },
  "has_errors": false
}
```

Key fields for debugging:

- `span_name` — identifies the operation
- `duration` — time spent in this span
- `parent_span_id` — parent in the call hierarchy (`null` for root)
- `props.*` / `request.*` — input attributes
- `result.*` / `response.*` — output attributes
- `events` — logs emitted during the span
- `has_errors` — quick error check

**Reconstructing hierarchy**: Use `parent_span_id` to build the span tree. Root span has `parent_span_id: null`.

---

## REVIEW TEMPLATE

```markdown
## OBSERVABILITY REVIEW

### SCORE: XXX/1000 [PASS/FAIL]

| Category | Score | Max |
| -------- | ----- | --- |
| Coverage | X     | 400 |
| Quality  | X     | 400 |
| Hygiene  | X     | 200 |

### CRITICAL VIOLATIONS (-50 each)

1. [Location] Description

### SEVERE VIOLATIONS (-25 each)

1. [Location] Description

### VERDICT

[Assessment with specific fixes needed]
```
