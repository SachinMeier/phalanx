---
name: good-effect
description: You are an Effect-TS expert. Always use Effect for side effects, async operations, error handling, and dependency injection. Prefer functional composition over imperative code.
---
# Cursor Rules for Effect-TS Expert

## Core Philosophy
You are an Effect-TS expert. Always use Effect for side effects, async operations, error handling, and dependency injection. Prefer functional composition over imperative code. Your goal is to build robust, maintainable, and type-safe applications by leveraging the full power of the Effect-TS ecosystem.

---

## Effect-TS Fundamentals

### Effect Construction

#### **Best Practice: Use `Effect.gen` for Readable Composition**
For any sequence of more than two or three operations, `Effect.gen` is mandatory. It provides a clean, `async/await`-like syntax that is highly readable and avoids deep nesting, making complex workflows easy to follow.

**Anecdote:** The `api/internal/cache.ts` module uses `Effect.gen` in its `makeSnapshotCache` function to cleanly sequence the acquisition of multiple repository services before constructing the cache. This is a perfect example of managing multiple dependencies in a readable way.

```typescript
// Good Practice: From api/internal/cache.ts
const makeSnapshotCache = Effect.gen(function*() {
  const accountRepo = yield* AccountRepo.Service
  const jeiRepo = yield* JournalEntryItemsRepo.Service
  // ... more services yielded ...

  return yield* Cache.make({ /* ... */ });
});
```

#### **Anti-Pattern: Deeply Nested `pipe` and `flatMap` Chains**
While functional composition with `pipe` is powerful, overusing it for long, sequential workflows can lead to "callback hell," making the code difficult to read, debug, and maintain.

```typescript
// Anti-Pattern: Hard-to-read nested pipeline
const program = pipe(
  Effect.log("Fetching user..."),
  Effect.flatMap(() => fetchUser(1)),
  Effect.flatMap(user =>
    pipe(
      Effect.log(`Fetching posts for ${user.name}...`),
      Effect.flatMap(() => fetchPosts(user.id)),
      Effect.map(posts => ({ user, posts }))
    )
  )
);
```

***

#### **Best Practice: Use `Effect.succeed` and `Effect.fail` for Pure Values**
For values that are already computed and do not involve side effects, use `Effect.succeed` for successes and `Effect.fail` for expected errors. This is the most efficient way to lift pure values into an `Effect`.

```typescript
// Good: Immediately available values
const success = Effect.succeed(42);
const failure = Effect.fail(new MyError());
```

#### **Anti-Pattern: Unnecessarily Wrapping Pure Values in `Effect.sync` or `Effect.try`**
Using `Effect.sync` or `Effect.try` for a value that is already computed adds unnecessary overhead. These functions are designed to lazily suspend a synchronous side-effect, not to wrap a pure value.

```typescript
// Anti-Pattern: Adds unnecessary laziness and overhead
const unnecessarySync = Effect.sync(() => 42);

// Anti-Pattern: More verbose and less clear than Effect.succeed
const unnecessaryTry = Effect.try(() => 42);
```

***

#### **Best Practice: Use `Effect.try` and `Effect.tryPromise` for Fallible Operations**
- Use `Effect.try` to wrap synchronous functions that can throw exceptions (e.g., `JSON.parse`).
- Use `Effect.tryPromise` for `Promise`-based APIs that can reject.

This safely catches runtime exceptions and moves them into the `Error` channel as typed errors, making your application robust.

**Anecdote:** Our drivers for third-party services like Nango (`drivers/nango.ts`) and Google Sheets (`drivers/GoogleSheets/index.ts`) extensively use `Effect.tryPromise` to safely interact with external SDKs. This is a critical pattern for maintaining stability at the boundaries of our system.

```typescript
// Good Practice: Safely wrapping a promise from an external SDK
const makeNewSheet = (spreadsheet: GoogleSpreadsheet) =>
  Effect.gen(function*() {
    const sheet = yield* Effect.tryPromise({
      try: () => spreadsheet.addSheet({ title: String(Date.now()) }),
      catch: (error) => new BatchUpdateError({ message: String(error) }) // Typed error
    });
    return sheet;
  });
```

#### **Anti-Pattern: Using `Effect.sync` or `Effect.promise` for Unsafe Computations**
- Using `Effect.sync` for a computation that might throw is incorrect. If it throws, the error is treated as an unrecoverable **defect**, which will crash the fiber.
- Using `Effect.promise` for a promise that might reject will also cause the rejection to be treated as a defect.

```typescript
// Anti-Pattern: An exception here becomes a defect, bypassing the error channel.
const unsafeParse = (jsonString: string) => Effect.sync(() => JSON.parse(jsonString));
// This will crash the fiber instead of failing gracefully.
const program = unsafeParse('{ "invalid-json" '); // -> This will Die

// Anti-Pattern: A rejection here becomes a defect.
const unsafeFetch = (url: string) => Effect.promise(() => fetch(url));
// If this promise rejects, the fiber will die.
const program = unsafeFetch("https://api.example.com/invalid-url");
```
---

### Error Handling

#### **Best Practice: Distinguish Between Failures (E) and Defects (Die)**
- **Failures (`E`)** are expected, recoverable errors that are part of your domain (e.g., `UserNotFound`). They are tracked in the type system.
- **Defects (`Die`)** are unexpected, unrecoverable errors that indicate a bug (e.g., null pointer exception, out-of-memory). They are not tracked in the type signature.

**Never catch defects** unless at the absolute edge of your application (e.g., to log a crash before exiting). Your business logic should only handle failures.

#### **Best Practice: Design Typed Errors with `Data.TaggedError` or `Schema.TaggedError`**
All custom errors **must** extend `Data.TaggedError` or `Schema.TaggedError`. This adds a `_tag` property that enables exhaustive, type-safe error handling with combinators like `Effect.catchTag`.

**Anecdote:** Our Google Sheets driver (`drivers/GoogleSheets/index.ts`) defines a suite of specific, tagged errors like `SheetNotFoundError` and `LoadCellsError`. This allows consumers of the driver to handle specific failure modes with precision.

```typescript
import { Schema, Data } from "effect";

// Good: Using Schema.TaggedError for errors that are part of an API contract
export class SheetNotFoundError extends Schema.TaggedError<SheetNotFoundError>()(
  "SheetNotFoundError",
  { sheetName: Schema.String }
) {}

// Good: Using Data.TaggedError for internal domain errors
export class UserNotFound extends Data.TaggedError("UserNotFound")<{
  readonly userId: number;
}> {}
```

#### **Anti-Pattern: Using Generic `Error` or Strings**
Using generic `Error` objects or simple strings for failures makes it impossible to distinguish between different error types at compile time. This leads to brittle, runtime-dependent error handling logic.

```typescript
// Anti-Pattern: Error information is lost in the type system.
const findUser = (id: number) => {
  if (id === 0) {
    return Effect.fail("User ID cannot be zero"); // Just a string
  }
  return Effect.fail(new Error("Database offline")); // Generic Error
}
```

***

#### **Best Practice: Use `Effect.catchTag` for Specific Error Recovery**
With `Data.TaggedError`, you can use `Effect.catchTag` to handle specific error cases in a type-safe way. The compiler ensures you are handling a valid error type and correctly prunes the handled error from the `Error` channel.

```typescript
const program = findUser(123).pipe(
  Effect.catchTag("UserNotFound", (error) =>
    Effect.succeed({ name: `Default User for ID ${error.userId}` })
  )
); // The error channel no longer contains UserNotFound
```

#### **Anti-Pattern: Using `Effect.catchAll` with `instanceof`**
Using `Effect.catchAll` and then checking error types with `if` or `instanceof` is less efficient and less type-safe. The compiler cannot prune the error from the union, and you lose the benefits of structured error handling.

```typescript
// Anti-Pattern: Clunky, not fully type-safe, and requires re-throwing.
const program = findUser(123).pipe(
  Effect.catchAll((error) => {
    if (error instanceof UserNotFound) {
      return Effect.succeed({ name: "Default User" });
    }
    // You have to re-throw the error if it's not the one you want to handle.
    return Effect.fail(error);
  })
);
```

---

### Concurrency & Resources

#### **Best Practice: Use `Effect.forEach` with Concurrency Options for Parallelism**
To process a collection of items in parallel, use `Effect.forEach` with the `concurrency` option. Set it to `"unbounded"` for maximum parallelism or a number to limit concurrent executions.

**Anecdote:** The `api/internal/cache.ts` file uses `Effect.all([...], { concurrency: "unbounded" })` to fetch all data from multiple repositories in parallel. This dramatically reduces the latency of a cache miss from a sequential ~6 seconds to under 1 second.

```typescript
// Good Practice: from api/internal/cache.ts
const [accounts, jeis, bills, ...] = yield* Effect.all(
  [
    accountRepo.getAll({ orgId: key.orgId, snapshotId: key.snapshotId }),
    jeiRepo.getAll({ orgId: key.orgId, snapshotId: key.snapshotId }),
    // ... more repo calls
  ],
  { concurrency: "unbounded" }
);
```

#### **Anti-Pattern: Using Manual Loops for Unnecessary Sequential Execution**
If the order of execution doesn't matter, processing items sequentially in a `for...of` loop inside `Effect.gen` is inefficient and misses a major opportunity for parallelism.

```typescript
// Anti-Pattern: Inefficiently sequential when parallelism is possible.
const program = Effect.gen(function* () {
  const results = [];
  for (const item of items) {
    results.push(yield* processItem(item)); // Each iteration waits for the previous one.
  }
  return results;
});
```
***

#### **Best Practice: Use `Effect.acquireRelease` and `Layer.scoped` for Safe Resource Management**
This is the canonical way to ensure a resource (like a file handle or database container) is safely acquired and **always** released, even if errors or interruptions occur.

**Anecdote:** Our database integration tests in `db/postgresContainer.ts` use `Layer.scoped` with `Effect.acquireRelease` to manage the lifecycle of a PostgreSQL test container. This guarantees the container is started before tests run and is torn down afterward, preventing resource leaks.

```typescript
// Good Practice: from db/postgresContainer.ts
const ContainerLive = Layer.scoped(
  PgContainer,
  Effect.acquireRelease(
    Effect.promise(() => new PostgreSqlContainer("postgres:alpine").start()), // Acquire
    (container) => Effect.promise(() => container.stop()) // Release is guaranteed
  )
);
```

#### **Anti-Pattern: Manual Cleanup with `try/finally` or `Effect.ensuring`**
While `Effect.ensuring` acts like a `finally` block, it is less robust than `acquireRelease` because it does not automatically handle interruptions. A standard `try/finally` block is an even bigger anti-pattern, as it offers no protection against fiber interruptions at all.

```typescript
// Anti-Pattern: This will leak the resource if the fiber is interrupted.
const file = openFile("...");
try {
  useFile(file);
} finally {
  closeFile(file);
}
```

---

### Dependency Injection

#### **Best Practice: Use `Effect.Service` for Concise Service and Layer Definition**
`Effect.Service` is a modern, high-level API that combines the creation of a service `Tag` and its `Layer` in one step. It reduces boilerplate and makes defining services and their dependencies clear.

**Anecdote:** All of our core services, such as `drivers/GoogleSheets/index.ts` and `repos/Account.ts`, are defined using the `Effect.Service` pattern. This provides a consistent and predictable structure across the codebase.

```typescript
// Good Practice: from drivers/GoogleSheets/index.ts
export class Service extends Effect.Service<Service>()(TAG, {
  effect: Effect.gen(function*() {
    // ... implementation ...
    return { write: (spreadsheetId, page) => { /*...*/ } };
  }),
  dependencies: [] // Explicitly list service dependencies here
}) {}
```

#### **Best Practice: Keep Service Method Signatures Free of Dependencies**
The methods within a service interface should not require any further dependencies (`R` should be `never`). The service itself is the dependency.

```typescript
// Good Practice
export interface UserService {
  // R is `never`, the dependency is on UserService, not the method.
  readonly getById: (id: number) => Effect.Effect<User, UserNotFound, never>
}

// Anti-Pattern
export interface BadUserService {
  // The caller needs to provide Database, which breaks encapsulation.
  readonly getById: (id: number) => Effect.Effect<User, UserNotFound, Database>
}
```

#### **Anti-Pattern: Manual `Context.Tag` and `Layer` Construction**
While `Context.Tag` and `Layer.succeed`/`Layer.effect` are the foundational building blocks, using them manually for every service is verbose and error-prone. `Effect.Service` simplifies this common pattern.

```typescript
// Anti-Pattern: More verbose for a common use case.
interface MyService { readonly doSomething: () => Effect.Effect<void> }
const MyService = Context.Tag<MyService>();
const MyServiceLive = Layer.succeed(MyService, { doSomething: () => Effect.log("...") });
```

---

### State Management

#### **Best Practice: Use `Ref` for Safe, Concurrent State**
When you need to manage mutable state that can be accessed by multiple fibers, use `Ref`. It provides atomic operations (`update`, `get`, `set`) that prevent race conditions.

```typescript
import { Effect, Ref } from "effect"

const program = Effect.gen(function* () {
  const counter = yield* Ref.make(0);
  const inc = Ref.update(counter, (n) => n + 1);

  // Run three increments concurrently
  yield* Effect.all([inc, inc, inc], { concurrency: "unbounded" });

  const finalValue = yield* Ref.get(counter); // Guaranteed to be 3
  console.log(`Final count: ${finalValue}`);
});
```

#### **Anti-Pattern: Using `let` for Shared Mutable State**
Using a standard mutable variable (`let`) in a concurrent context is unsafe and will lead to race conditions and unpredictable behavior.

```typescript
import { Effect } from "effect"

// Anti-Pattern: Race condition waiting to happen
let counter = 0;
const inc = Effect.sync(() => { counter++ });

const program = Effect.gen(function* () {
  yield* Effect.all([inc, inc, inc], { concurrency: "unbounded" });
  console.log(`Final count: ${counter}`); // Unpredictable! Could be 1, 2, or 3.
});
```

---

### Observability

#### **Best Practice: Use `Effect.withSpan` for Tracing**
Wrap key business logic operations in `Effect.withSpan("span-name")` to create traces. This provides invaluable insight into the performance and behavior of your application in production.

```typescript
// Good Practice: Add a span to trace the operation
const getUser = (id: number) =>
  db.findUser(id).pipe(
    Effect.mapError(() => new UserNotFound({ id })),
    Effect.withSpan("Database.findUser", { attributes: { "db.user.id": id } })
  );
```

#### **Best Practice: Use `Effect.log` for Structured Logging**
Use `Effect.log` for all logging. It automatically includes contextual information like the fiber ID, trace ID, and any annotations. This makes debugging distributed systems vastly easier.

```typescript
// Good Practice: Structured, context-aware logging
const program = Effect.gen(function*() {
  yield* Effect.log("Starting user creation.");
  // ... logic ...
  yield* Effect.log("User created successfully.");
}).pipe(
  Effect.annotateLogs({ userId: 123, component: "AuthService" })
);
```

#### **Anti-Pattern: Using `console.log`**
`console.log` is a fire-and-forget side effect that is not managed by the Effect runtime. It lacks structure, context (like trace IDs), and cannot be configured or redirected in different environments.

```typescript
// Anti-Pattern: Loses all context and cannot be managed by the runtime.
const program = Effect.sync(() => {
  console.log("Starting user creation...");
  // ...
  console.log("User created successfully.");
});
```

---

### Schema & Validation

#### **Best Practice: Use `@effect/schema` for All Runtime Validation**
Always validate data coming from external sources (APIs, files, user input) using `@effect/schema`. Use `Schema.decodeUnknown` at the boundaries of your application to transform `unknown` data into your strongly-typed domain models.

**Anecdote:** Every API endpoint in `api/internal/api.ts` defines request and response codecs using `Schema`. This ensures that no invalid data can enter our system from the outside world.

```typescript
// Good Practice: from api/internal/api.ts
export const CreateStatementRequestCodec = Schema.Struct({
  spreadsheetId: Schema.String.pipe(Schema.pattern(SPREADSHEET_ID_PATTERN)),
  dateRange: Schema.Struct({
    fromDate: Schema.DateTimeUtc,
    toDate: Schema.DateTimeUtc
  }),
  // ...
});
```

#### **Anti-Pattern: Trusting External Data or Manual Validation**
Failing to validate external data or writing manual `if/else` validation logic is risky, brittle, and leads to code duplication.

```typescript
// Anti-Pattern: Unsafe type assertion and manual checks.
const processUser = (input: any) => Effect.sync(() => {
  if (typeof input.id !== 'number' || typeof input.name !== 'string') {
    throw new Error("Invalid user object");
  }
  const user = input as User; // Unsafe assertion
  // ...
});```

#### **Best Practice: Use `Schema.transform` for Bidirectional Data Conversion**
When you need to convert between two representations (e.g., string ↔ domain object), use `Schema.transform` instead of manual parsing functions that return nullable values.

**Anecdote:** In the PageHeader refactor (PR #202), we converted a `parseCompactRange` function that returned `null` on failure into a proper `Schema.transform`. This gives us bidirectional encoding/decoding, proper error handling in the Effect channel, and test data generation.

```typescript
// Good Practice: from domain/utils/period.ts
const CompactRangeStringDecoder = Schema.String.pipe(
  Schema.filter((input): input is string => {
    return /^\d{4}$/.test(input) || /^\d{4}-Q[1-4]$/.test(input) || ...
  }, {
    message: (input) => `Invalid compact range format: ${input}`
  })
)

export const CompactRangeString = Schema.transform(
  CompactRangeStringDecoder,  // Source schema
  PeriodCodec,                // Target schema
  {
    strict: true,
    decode: (input) => {
      // Parse string into Period domain object
      if (/^\d{4}$/.test(input)) { /* full year */ }
      if (/^\d{4}-Q[1-4]$/.test(input)) { /* quarter */ }
      // ...
      return { name, from, to }
    },
    encode: (period) => toCompactRangeString(period)
  }
)

// Usage
const period = yield* Schema.decodeUnknown(Period.CompactRangeString)("2025-Q2")
// Returns: Effect<Period.Shape, ParseError>
```

#### **Anti-Pattern: Parsing Functions That Return `null`**
Returning `null` on parse failure puts errors in the success channel, bypassing Effect's error handling system.

```typescript
// Anti-Pattern: Error information lost, null checks everywhere
export const parseCompactRange = (input: string): { from: DateTime.Utc; to: DateTime.Utc } | null => {
  if (!input) return null
  // ... parsing logic
  return null // if no match
}

// Forces callers to handle null manually
const result = parseCompactRange(input)
if (!result) {
  // What went wrong? We don't know.
  return yield* Effect.fail(new GenericError())
}
```

---

### Domain Object Signatures

#### **Best Practice: Functions Should Accept Domain Objects, Not Primitives**
When a function operates on a domain concept, its signature should accept the domain object, not decomposed primitive fields.

**Anecdote:** In the PageHeader refactor, `Period.toCompactRangeString` originally accepted `(from: DateTime.Utc, to: DateTime.Utc)`. Michael's feedback: "input by default should be the domain object... signature should be `(period: Period.Shape)`."

```typescript
// Good Practice: from domain/utils/period.ts
export const toCompactRangeString = (period: Shape): string => {
  const startYear = toYear(period.from)
  const endYear = toYear(period.to)
  const startMonth = toMonth(period.from)
  const endMonth = toMonth(period.to)
  // ... formatting logic
}

// Call site constructs the domain object
const period = Period.fromRange(from, to)
const formatted = Period.toCompactRangeString(period)
```

#### **Anti-Pattern: Functions That Accept Decomposed Primitives**
Accepting individual fields instead of the domain object creates tight coupling and makes the function harder to evolve.

```typescript
// Anti-Pattern: Operates on Period but doesn't accept it
export const toCompactRangeString = (from: DateTime.Utc, to: DateTime.Utc): string => {
  // ... has to recompute things Period already knows
}

// Forces callers to decompose the object
const formatted = Period.toCompactRangeString(period.from, period.to)
```

**The principle**: If a function is namespaced under a module (e.g., `Period.toCompactRangeString`), it should accept that module's domain object. This is cohesion—the function belongs to the data it operates on.

---

### Passing Data Through Call Chains

#### **Best Practice: Pass Decoded Domain Objects, Not Strings**
Keep data in its richest, most structured form as long as possible. Stringification is a "destructive" operation that loses type information, so defer it to the absolute last moment.

**Anecdote:** In the PageHeader refactor, builders originally accepted `queryText: string`. Michael's feedback: "You want to pass around the decoded domain objects as long as possible... Let the PageHeader deal with turning it to a string at the last moment when necessary."

```typescript
// Good Practice: from drivers/GoogleSheets/legacy/internal/common.ts
export interface HeaderConfig {
  pageHeader: PageHeader.Shape  // ← Full structured object
  resultSize: { rows: number; columns: number }
  cutoffDate: DateTime.Utc
}

export const makeLinesHeader = (config: HeaderConfig) => {
  // Stringify at the LAST moment (when creating the cell)
  const queryText = PageHeader.toDisplayString(config.pageHeader)
  const queryCell = Cell.union(Cell.fromValue(queryText), options)
  // ...
}
```

#### **Anti-Pattern: Early Stringification**
Converting domain objects to strings early in the call chain loses type information and forces re-parsing if downstream code needs the structured data.

```typescript
// Anti-Pattern: Stringifies too early
const queryString = PageHeader.toDisplayString(pageHeader)
const page = PageBuilder.makePage(data, queryString)

// Builder receives a string and can't access pageHeader.period, .facets, etc.
export const makePage = (data: Data, queryString: string) => {
  // If we need to inspect the period or facets, we'd have to re-parse the string!
  const header = Common.makeLinesHeader({ queryString, ... })
}
```

**The principle**: Serialization destroys structure. Keep data structured until the moment you must serialize it (writing to disk, network, or display).

---

### Domain Modeling with Arrays

#### **Best Practice: Use Required Arrays, Not Optional Arrays**
When modeling collections in domain objects, use a required array field. The empty array `[]` already signals absence—making the field optional creates ambiguity.

**Anecdote:** In the PageHeader refactor, `facets` was originally `Schema.optional(Schema.Array(...))`. Michael's feedback: "You don't want to make things optional usually when you model a domain object. Especially if it is an Array, then the empty array signals the absence."

```typescript
// Good Practice: from domain/Spreadsheet/PageHeader.ts
export const Codec = Schema.Struct({
  reportKind: Schema.String,
  facets: Schema.Array(Schema.Struct({  // ← Required array
    kind: Schema.String,
    value: Schema.String
  })),
  // ...
})

// Usage: empty array signals no facets
const headerWithNoFacets = PageHeader.make({
  reportKind: "IS",
  facets: [],  // ← Clear and unambiguous
  // ...
})
```

#### **Anti-Pattern: Optional Arrays Create Three States**
Using `Schema.optional` for arrays creates unnecessary ambiguity with three possible states for "no items."

```typescript
// Anti-Pattern: Creates three states
facets: Schema.optional(Schema.Array(...))

// Now you have:
facets: undefined  // Field absent
facets: null       // Explicitly no value
facets: []         // Empty array

// Forces defensive checks everywhere
if (header.facets && header.facets.length > 0) { ... }
```

**The principle**: Make illegal states unrepresentable. Two states (empty vs. populated) are clearer than three.

---

### Schema Filters for Invalid States

#### **Best Practice: Use `Schema.filter` to Prevent Construction of Invalid Domain Objects**
When a domain object has invariants (rules that must always be true), encode them as Schema filters so invalid objects cannot be constructed.

**Anecdote:** In the PageHeader refactor, the `dimensions` struct originally allowed `{ dimensions: {} }` (all fields optional, all undefined). Michael's feedback: "current typing suggests that `{ dimensions: {} }` is a valid value—is that what we want?" We added a filter to enforce at least one dimension is present.

```typescript
// Good Practice: from domain/Spreadsheet/PageHeader.ts
const Dimensions = Schema.Struct({
  period: Schema.optional(Schema.Struct({ from: Schema.DateTimeUtc, to: Schema.DateTimeUtc })),
  rowLabel: Schema.optional(Schema.String),
  columnHeader: Schema.optional(Schema.String)
}).pipe(
  Schema.filter(
    (d) => d.period != null || d.rowLabel != null || d.columnHeader != null,
    { message: () => "At least one dimension must be present (period | rowLabel | columnHeader)" }
  )
)

// Now this fails at construction time:
PageHeader.make({ dimensions: {}, ... })  // ← ParseError
```

#### **Anti-Pattern: Allowing Invalid States to Be Constructed**
If your schema allows constructing nonsensical objects, you push validation to runtime throughout the codebase.

```typescript
// Anti-Pattern: All dimensions optional, no filter
dimensions: Schema.Struct({
  period: Schema.optional(...),
  rowLabel: Schema.optional(Schema.String),
  columnHeader: Schema.optional(Schema.String)
})

// This compiles and runs but is meaningless:
const badHeader = PageHeader.make({
  reportKind: "IS",
  dimensions: {},  // ← What does this page show? No one knows.
  facets: []
})
```

**The principle**: Use the type system to prevent bugs. If a PageHeader with no dimensions is nonsensical, make it impossible to create.

---

## HTTP APIs with Effect Platform

### API Structure
```typescript
// Endpoint definition from api/internal/api.ts
export const createStatement = HttpApiEndpoint.post("createStatement", "/statement")
  .setPayload(CreateStatementRequestCodec)
  .addSuccess(ProcessSheetResponse, { status: 200 })
  .addError(ProcessingError, { status: 400 });

// API group
export const InternalApi = HttpApiGroup.make("v1")
  .add(createStatement)
  // ... more endpoints
  .prefix("/v1");
```

### Handlers
```typescript
// Handler from api/internal/groups/internal.ts
import * as Statement from "./statement.js";

export const InternalApiGroup = HttpApiBuilder.group(Live, "v1", (handlers) =>
  handlers
    .handle("createStatement", makeHandler(({ payload }) => Statement.handler(payload)))
    // ... more handlers
);
```

### Server Setup
```typescript
// Server setup from api/internal/server.ts
const ApiLayer = HttpApiBuilder.api(Live).pipe(Layer.provide(InternalApiLive));

export const ServerLive = HttpApiBuilder.serve(composedMiddleware)
  .pipe(
    Layer.provide(ApiLayer),
    Layer.provide(StytchMiddleware.Live),
    HttpServer.withLogAddress,
    Layer.provide(NodeHttpServer.layer(createServer, { port }))
  );
``
---

## Testing with Effect

### **Best Practice: Use `TestClock` for Time-Dependent Logic**
Never rely on real-world time in tests. Use `TestClock.adjust` to deterministically control the flow of time, making tests for `Effect.sleep`, `debounce`, `throttle`, and `Schedule` instant and reliable.

```typescript
import { TestClock, Effect } from "effect";
import { describe, it, expect } from "@effect/vitest";

describe("Scheduled job", () => {
  it.effect("should run after one hour", () =>
    Effect.gen(function*() {
      const fiber = yield* myJob.pipe(Effect.fork);
      yield* TestClock.adjust("1 hour"); // Instantly advance time
      const result = yield* Fiber.join(fiber);
      expect(result).toBe("done");
    })
  );
});
```

### **Best Practice: Provide Test Implementations of Layers**
Use `Layer.succeed` to provide mock implementations of services for your tests. This allows you to test units of logic in isolation without relying on external infrastructure like databases or third-party APIs.

**Anecdote:** The `api/__tests__/internal.test.ts` file demonstrates creating a `mockAuthLayer` using `Layer.succeed` to bypass real authentication, allowing the test to focus solely on the API logic.

```typescript
// Good Practice: Mocking a database layer for a test
const MockDatabase = Layer.succeed(
  Database,
  Database.of({
    findUser: (id) => Effect.succeed({ id, name: "Mock User" })
  })
);

const testProgram = getUser(1).pipe(
  Effect.provide(MockDatabase)
);
```

---

## Code Style and Naming

#### **Best Practice: Use Full Import Aliases, Not Abbreviations**
When importing modules with namespace imports, use the full module name. Abbreviations save typing but cost cognitive load.

**Anecdote:** In PR #202, an import was abbreviated as `import * as PH from "@domain/Spreadsheet/PageHeader.js"`. Agustin's feedback: "we do not win much by abreviating that and makes the code more diffficult to read." Michael agreed.

```typescript
// Good Practice
import * as PageHeader from "@domain/Spreadsheet/PageHeader.js"
import * as Period from "@domain/utils/period.js"

// Usage is immediately clear
const header = PageHeader.make({ ... })
const formatted = Period.toCompactRangeString(period)
```

#### **Anti-Pattern: Abbreviating Import Aliases**
```typescript
// Anti-Pattern: Saves 9 characters, costs clarity
import * as PH from "@domain/Spreadsheet/PageHeader.js"
import * as Per from "@domain/utils/period.js"

// Reader has to mentally map abbreviations
const header = PH.make({ ... })  // What's PH again?
```

**The principle**: Optimize for reading, not writing. Code is read 10x more than it's written.

#### **Best Practice: Use camelCase for Local Constants**
Local constants and mappings inside functions should use camelCase. Reserve SCREAMING_SNAKE_CASE for exported module-level constants.

**Anecdote:** In PR #202, a mapping was named `GROUP_BY_FIELD_MAP` inside a function. This violates the codebase convention—local constants like `entityNameByIdMap`, `budgetByCode` are all camelCase.

```typescript
// Good Practice: from api/internal/groups/drill.ts
const groupByFieldMap: Record<"Customer" | "Vendor" | "Memo", keyof DrillDownEntry> = {
  Customer: "customerName",
  Vendor: "vendorName",
  Memo: "memo"
}

// Exported module constant (from drivers/GoogleSheets/legacy/style.ts)
export const FORMAT = {
  ColorBlack: { red: 256, blue: 256, green: 256 },
  Patterns: {
    showUSDSymbol: "_($* #,##0_);_($* (#,##0);_($* \"-\"_);_(@_)"
  }
}
```

#### **Anti-Pattern: SCREAMING_SNAKE_CASE for Local Variables**
```typescript
// Anti-Pattern: Local constant uses wrong convention
const GROUP_BY_FIELD_MAP = { ... }
const COLUMN_LABELS = ["A", "B", "C"]
```

**The convention**:
- **Local constants**: `camelCase` (e.g., `groupByFieldMap`, `entityNameByIdMap`)
- **Exported module constants**: `SCREAMING_SNAKE_CASE` (e.g., `FORMAT`, `CONFIG`)

---

## Key Principles
- **All side effects through Effect:** No raw promises, `async/await` (outside of `Effect.tryPromise`), or `try/catch` blocks in business logic.
- **Typed Errors, No Exceptions:** All expected failures are modeled as typed errors in the `E` channel. Unhandled exceptions are defects.
- **Dependency Injection via Context/Layer:** Services request dependencies via `Context.Tag` and are wired together with `Layer`.
- **Structured Concurrency:** Fibers' lifecycles are managed automatically, preventing resource leaks. Use `Effect.fork` and let Effect handle the cleanup.
- **Resource Safety with Scope:** `Effect.acquireRelease` and `Layer.scoped` guarantee cleanup.
- **Functional Composition with `pipe()` and `Effect.gen()`:** Prefer declarative pipelines and readable `gen` blocks over imperative loops.
- **Observability by Default:** Instrument code with `Effect.withSpan` and `Effect.log` to ensure visibility.
- **Schema Validation for All External Data:** Never trust data crossing a system boundary.
- **Schema Transforms for Parsing:** Use `Schema.transform` for bidirectional conversions, not nullable-returning functions.
- **Pass Decoded Objects:** Keep data structured as long as possible; defer serialization to the last moment.
- **Domain Object Signatures:** Functions should accept domain objects, not decomposed primitives.
- **Required Arrays:** Use `facets: Schema.Array(...)` not `Schema.optional(Schema.Array(...))`. Empty array signals absence.
- **Schema Filters for Invariants:** Use `Schema.filter` to prevent construction of invalid domain objects.
