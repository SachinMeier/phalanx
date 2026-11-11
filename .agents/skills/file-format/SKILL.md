---
name: good-file-format
description: Correct file structure templates for domain and service modules. Use when you work on business (non-UI) code to ensure that your work follows the template structure to provide a unified, low-surprise code base to other engineers.
---

# File Formatting Patterns

## Domain Module Template

```typescript
/**
 * Domain Module Template
 *
 * A domain module organizes code around a NOUN (data structure) not a VERB (action).
 * Follow this section ordering EXACTLY for consistency across the codebase.
 *
 * NAMING CONVENTION (Effect-TS style):
 * - The main type MUST match the module name: __ModuleName__.__ModuleName__
 * - Example: Header.ts exports `type Header` → accessed as `Header.Header`
 * - For CQRS modules (separate read/write types), see cqrs-module/ templates
 *
 * WHEN TO USE THIS TEMPLATE:
 * - Single-file domain modules (e.g., Line.ts, Table.ts, Period.ts)
 * - The module represents a single concept without CQRS separation
 *
 * Sections (in order):
 * 1. Instance    - Constants (SCREAMING_SNAKE_CASE, often exported)
 * 2. Model       - Types derived from Codec, additional interfaces
 * 3. Error       - TaggedErrors for typed failures
 * 4. Codec       - Schema definitions (use "Codec" suffix)
 * 5. Constructor - make using Codec.make, of, from functions
 * 6. Destructor  - to functions (convert TO other representations)
 * 7. Operation   - Transformations: map, filter, merge, match, etc.
 * 8. Refinement  - Type guards: isX, hasX
 * 9. Order       - Ordering/sorting functions
 * 10. Arbitrary  - Test data generators
 * 11. Display    - String formatting for display
 * 12. Helper     - Non-exported private functions
 *
 * Include only the sections you need, but maintain this order.
 *
 * PLACEHOLDERS TO REPLACE:
 * - __ModuleName__ → Your module name (e.g., Header, Period, Line)
 */

import { Arbitrary } from "@effect/schema";
import { Data, Order, Schema } from "effect";

// --------------------------------------------------------
// Instance
// --------------------------------------------------------

export const DEFAULT_VALUE = 0 as const;

// --------------------------------------------------------
// Model
// --------------------------------------------------------

// Main type MUST be derived from Codec
export type __ModuleName__ = typeof Codec.Type;

// Additional types/interfaces for this module
export interface __ModuleName__Options {
  includeEmpty: boolean;
}

// --------------------------------------------------------
// Error
// --------------------------------------------------------

export class Invalid__ModuleName__Error extends Data.TaggedError(
  "@fpna/domain/__ModuleName__/Error/Invalid__ModuleName__Error",
)<{
  readonly input: string;
  readonly reason: string;
}> {}

// --------------------------------------------------------
// Codec
// --------------------------------------------------------

export const Codec = Schema.Struct({
  id: Schema.String,
  value: Schema.Number,
});

// --------------------------------------------------------
// Constructor
// --------------------------------------------------------

export const make = (id: string, value: number): __ModuleName__ =>
  Codec.make({ id, value });

export const makeEmpty = (): __ModuleName__ =>
  Codec.make({ id: "", value: DEFAULT_VALUE });

export const fromValue = (value: number): __ModuleName__ =>
  Codec.make({ id: "", value });

// --------------------------------------------------------
// Destructor
// --------------------------------------------------------

export const toId = (a: __ModuleName__): string => a.id;

export const toValue = (a: __ModuleName__): number => a.value;

// --------------------------------------------------------
// Operation
// --------------------------------------------------------

export const map = <A>(a: __ModuleName__, f: (value: number) => A): A =>
  f(a.value);

// --------------------------------------------------------
// Refinement
// --------------------------------------------------------

export const isEmpty = (a: __ModuleName__): boolean =>
  a.id === "" && a.value === DEFAULT_VALUE;

// --------------------------------------------------------
// Order
// --------------------------------------------------------

export const byValue = Order.mapInput(
  Order.number,
  (x: __ModuleName__) => x.value,
);

export const byId = Order.mapInput(Order.string, (x: __ModuleName__) => x.id);

// --------------------------------------------------------
// Arbitrary
// --------------------------------------------------------

export const makeArb = () => Arbitrary.make(Codec);

// --------------------------------------------------------
// Display
// --------------------------------------------------------

export const toDisplayString = (a: __ModuleName__): string =>
  `${a.id}: ${a.value}`;

// --------------------------------------------------------
// Helper
// --------------------------------------------------------

const formatInternal = (a: __ModuleName__): string => `[${a.id}] ${a.value}`;
```

## Domain Service Template

```typescript
/**
 * Domain Service Template
 *
 * Use this template for services that operate on domain types. This covers both:
 * - Services paired with a Model.ts file (import types from ./Model.js)
 * - Standalone services that define their own types (define types here)
 *
 * WHEN TO USE THIS TEMPLATE:
 * - Domain services that extract/transform data using domain types
 * - Infrastructure services (cache, API clients, wrappers)
 * - Any Effect.Service that manages stateful operations
 *
 * KEY RULES:
 * - Effect.Service infers the type from return value - NO separate interface
 * - Service methods return Effect with R = never (dependencies acquired upfront)
 * - Service definition comes EARLY (after Instance/Model/Error/Codec)
 * - Driver-dependent functions go INSIDE the Service class
 * - Pure helper functions go in Helper section at bottom (not exported)
 *
 * Sections (in order):
 * 1. Instance    - TAG and constants (SCREAMING_SNAKE_CASE)
 * 2. Model       - Types derived from Codec (or import from Model.ts)
 * 3. Error       - TaggedErrors for typed failures
 * 4. Codec       - Schema definitions (if needed for validation)
 * 5. Service     - Effect.Service definition (MAIN CONCEPT - comes early!)
 * 6. Constructor - (if applicable)
 * 7. Destructor  - (if applicable)
 * 8. Operation   - Exported pure helper functions
 * 9. Helper      - Non-exported private functions used by Service
 *
 * Include only the sections you need, but maintain this order.
 *
 * PLACEHOLDERS TO REPLACE:
 * - __ModuleName__ → Your module name (e.g., Header, Description, Cache)
 * - __DomainPath__ → Path to your domain (e.g., Spreadsheet, Query)
 * - __Dependency__ → Service dependency (e.g., Driver, Repository)
 */

import { Data, Effect, Schema, SynchronizedRef } from "effect";

// --------------------------------------------------------
// Instance
// --------------------------------------------------------

export const TAG = "@fpna/domain/__DomainPath__/__ModuleName__" as const;

export const MAX_CACHE_SIZE = 1000 as const;

// --------------------------------------------------------
// Model
// --------------------------------------------------------

// OPTION A: Import from Model.ts (domain service)
// import * as __ModuleName__ from "./Model.js"

// OPTION B: Define locally - type derived from Codec
export type __ModuleName__ = typeof Codec.Type;

// --------------------------------------------------------
// Error
// --------------------------------------------------------

export class __ModuleName__NotFoundError extends Data.TaggedError(
  "@fpna/domain/__DomainPath__/__ModuleName__/Error/NotFound",
)<{
  readonly id: string;
  readonly message: string;
}> {}

export class __ModuleName__ValidationError extends Schema.TaggedError<__ModuleName__ValidationError>()(
  "__ModuleName__.ValidationError",
  { message: Schema.String },
) {}

// --------------------------------------------------------
// Codec
// --------------------------------------------------------

export const Codec = Schema.Struct({
  id: Schema.String,
  value: Schema.Number,
});

// --------------------------------------------------------
// Service
// --------------------------------------------------------

export class Service extends Effect.Service<Service>()(TAG, {
  effect: Effect.gen(function* () {
    // 1. Acquire dependencies at construction time
    // const driver = yield* __Dependency__.Service

    // 2. Initialize internal state if needed
    const cache = yield* SynchronizedRef.make<Map<string, __ModuleName__>>(
      new Map(),
    );

    // 3. Define private helper functions INSIDE the service
    const validate = (value: number): boolean => value >= 0;

    // 4. Define service methods
    const getById = (
      id: string,
    ): Effect.Effect<__ModuleName__, __ModuleName__NotFoundError> =>
      Effect.gen(function* () {
        const map = yield* SynchronizedRef.get(cache);
        const item = map.get(id);
        if (!item) {
          return yield* Effect.fail(
            new __ModuleName__NotFoundError({ id, message: `${id} not found` }),
          );
        }
        return item;
      });

    const create = (
      id: string,
      value: number,
    ): Effect.Effect<__ModuleName__, __ModuleName__ValidationError> =>
      Effect.gen(function* () {
        if (!validate(value)) {
          return yield* Effect.fail(
            new __ModuleName__ValidationError({
              message: "Value must be non-negative",
            }),
          );
        }
        const item = Codec.make({ id, value });
        yield* SynchronizedRef.update(cache, (map) =>
          new Map(map).set(id, item),
        );
        return item;
      });

    // 5. Return service implementation - type is INFERRED
    return { getById, create };
  }),
  dependencies: [
    // __Dependency__.Service.Default
  ],
}) {}

// --------------------------------------------------------
// Constructor
// --------------------------------------------------------

export const make = (id: string, value: number): __ModuleName__ =>
  Codec.make({ id, value });

// --------------------------------------------------------
// Destructor
// --------------------------------------------------------

export const toId = (item: __ModuleName__): string => item.id;

// --------------------------------------------------------
// Operation
// --------------------------------------------------------

export const toDisplayString = (item: __ModuleName__): string =>
  `${item.id}: ${item.value}`;

// --------------------------------------------------------
// Helper
// --------------------------------------------------------

const formatInternal = (item: __ModuleName__): string =>
  `[${item.id}] ${item.value}`;
```

## CQRS Template

In the rarer cases where the "read" and "write" side have different shapes we follow the below templates.

### Domain Input Template (Write-side example)

```typescript
/**
 * Input (Write-Side) Template
 *
 * The Input type is what callers provide when creating/updating entities.
 * It extends the Model type and adds write-only fields.
 *
 * WHEN THIS FILE IS USED:
 * - Part of a CQRS module (has sibling Model.ts and index.ts)
 * - Represents the "write" side - what callers provide
 * - May have additional write-only fields (e.g., formulaFn, computedFn)
 *
 * NAMING CONVENTION:
 * - Use `Input` as the type name (extends the parent module's type)
 * - Access via explicit Write namespace: `Cell.Write.make()`
 * - Access type: `Cell.Input`
 *
 * Key characteristics:
 * - Type derived from Codec using `typeof Codec.Type`
 * - Extends the Model type conceptually (may add write-only fields)
 * - MUST have a toModel destructor for round-trip support
 *
 * Sections (in order):
 * 1. Instance    - Constants (SCREAMING_SNAKE_CASE)
 * 2. Model       - Type derived from Codec
 * 3. Error       - TaggedErrors (if not in Model.ts)
 * 4. Codec       - Schema definitions
 * 5. Constructor - make using Codec.make, from functions
 * 6. Destructor  - toModel (MANDATORY) and other to functions
 * 7. Operation   - Transformations
 * 8. Refinement  - Type guards
 * 9. Helper      - Non-exported private functions
 *
 * Include only the sections you need, but maintain this order.
 *
 * PLACEHOLDERS TO REPLACE:
 * - __ModuleName__ → Your module name (e.g., Cell, Location, Placed)
 */

import { Schema } from "effect";
import * as __ModuleName__ from "./Model.js";

// --------------------------------------------------------
// Model
// --------------------------------------------------------

// Input type derived from Codec
export type Input = typeof Codec.Type;

// Write-only function type (not part of Codec)
export type ComputedFn = (self: Input) => string;

// --------------------------------------------------------
// Codec
// --------------------------------------------------------

// Extends Model's Codec with write-only fields
export const Codec = Schema.Struct({
  ...__ModuleName__.Codec.fields,
  // Note: computedFn is runtime-only, not in Codec (functions can't be serialized)
});

// --------------------------------------------------------
// Constructor
// --------------------------------------------------------

export const make = (props: {
  value?: number | string | boolean | null;
  label?: string | null;
  format?: string;
  alignment?: "left" | "center" | "right";
  computedFn?: ComputedFn;
}): Input & { computedFn?: ComputedFn } => ({
  ...Codec.make({
    value: props.value ?? null,
    label: props.label ?? null,
    format: props.format,
    alignment: props.alignment,
  }),
  computedFn: props.computedFn,
});

export const makeEmpty = (): Input => Codec.make({ value: null, label: null });

export const fromValue = (value: number): Input =>
  Codec.make({ value, label: null });

// --------------------------------------------------------
// Destructor
// --------------------------------------------------------

// MANDATORY: toModel destructor for round-trip support
export const toModel = (input: Input): __ModuleName__.__ModuleName__ =>
  __ModuleName__.Codec.make({
    value: input.value,
    label: input.label,
    format: input.format,
    alignment: input.alignment,
  });

// --------------------------------------------------------
// Operation
// --------------------------------------------------------

export const union = (a: Input, b: Input): Input =>
  Codec.make({
    value: b.value ?? a.value,
    label: b.label ?? a.label,
    format: b.format ?? a.format,
    alignment: b.alignment ?? a.alignment,
  });

export const unionAll = (inputs: ReadonlyArray<Input>): Input =>
  inputs.reduce((acc, input) => union(acc, input), makeEmpty());

// --------------------------------------------------------
// Refinement
// --------------------------------------------------------

export const hasValue = (input: Input): boolean => input.value !== null;

// --------------------------------------------------------
// Helper
// --------------------------------------------------------

const formatInternal = (input: Input): string =>
  `[${input.label ?? ""}] ${input.value}`;
```

### Domain Model Template (Read-side)

```typescript
/**
 * Model (Read-Side) Template
 *
 * The Model type is the canonical, hydrated representation with full provenance.
 * It contains all attributes needed for round-trip fidelity.
 *
 * WHEN THIS FILE IS USED:
 * - Part of a CQRS module (has sibling Input.ts and index.ts)
 * - Represents the "read" side - what is stored/retrieved
 * - Does NOT contain write-only fields like formula functions
 *
 * NAMING CONVENTION:
 * - Type name = parent module name (e.g., `type Cell` in Cell/Model.ts)
 * - This follows Effect-TS style: Cell.Cell, Location.Location
 * - Barrel re-exports type at top level for clean access
 *
 * Key characteristics:
 * - Type derived from Codec using `typeof Codec.Type`
 * - Contains ALL attributes needed to reconstruct the entity
 * - Supports round-trip: read -> write -> read without data loss
 * - Use `null` for legitimately absent domain values
 *
 * Sections (in order):
 * 1. Instance    - Constants (SCREAMING_SNAKE_CASE)
 * 2. Model       - Type derived from Codec, additional interfaces
 * 3. Error       - TaggedErrors
 * 4. Codec       - Schema definitions
 * 5. Constructor - make using Codec.make, from functions
 * 6. Destructor  - to functions
 * 7. Operation   - Transformations
 * 8. Refinement  - Type guards
 * 9. Helper      - Non-exported private functions
 *
 * Include only the sections you need, but maintain this order.
 *
 * PLACEHOLDERS TO REPLACE:
 * - __ModuleName__ → Your module name (e.g., Cell, Location, Placed)
 */

import { Schema } from "effect";

// --------------------------------------------------------
// Instance
// --------------------------------------------------------

export const DEFAULT_ALIGNMENT = "left" as const;

// --------------------------------------------------------
// Model
// --------------------------------------------------------

// Type name = parent module name, derived from Codec
export type __ModuleName__ = typeof Codec.Type;

// --------------------------------------------------------
// Codec
// --------------------------------------------------------

export const Codec = Schema.Struct({
  value: Schema.NullOr(
    Schema.Union(Schema.Number, Schema.String, Schema.Boolean),
  ),
  label: Schema.NullOr(Schema.String),
  format: Schema.optional(Schema.String),
  alignment: Schema.optional(Schema.Literal("left", "center", "right")),
});

// --------------------------------------------------------
// Constructor
// --------------------------------------------------------

export const make = (props: {
  value?: number | string | boolean | null;
  label?: string | null;
  format?: string;
  alignment?: "left" | "center" | "right";
}): __ModuleName__ =>
  Codec.make({
    value: props.value ?? null,
    label: props.label ?? null,
    format: props.format,
    alignment: props.alignment,
  });

export const makeEmpty = (): __ModuleName__ =>
  Codec.make({ value: null, label: null });

export const fromValue = (value: number | string | boolean): __ModuleName__ =>
  Codec.make({ value, label: null });

// --------------------------------------------------------
// Destructor
// --------------------------------------------------------

export const toValue = (
  model: __ModuleName__,
): number | string | boolean | null => model.value;

export const toLabel = (model: __ModuleName__): string | null => model.label;

// --------------------------------------------------------
// Refinement
// --------------------------------------------------------

export const hasValue = (model: __ModuleName__): boolean =>
  model.value !== null;

export const hasLabel = (model: __ModuleName__): boolean =>
  model.label !== null;

export const isEmpty = (model: __ModuleName__): boolean =>
  model.value === null && model.label === null;

// --------------------------------------------------------
// Helper
// --------------------------------------------------------

const formatInternal = (model: __ModuleName__): string =>
  `[${model.label ?? ""}] ${model.value}`;
```

### Module Entrypoint Template

```typescript
/**
 * CQRS Module Barrel Template
 *
 * CQRS = Command Query Responsibility Segregation
 * Separates read (Model) and write (Input) representations.
 *
 * READ-SIDE DEFAULT CONVENTION:
 * - Read operations are far more common than writes (90/10 rule)
 * - Read-side (Model.ts) is exported as default via `export * from "./Model.js"`
 * - Write-side requires explicit namespace: `__ModuleName__.Write.make()`
 *
 * WHEN TO USE CQRS:
 * - Read and write operations have different type requirements
 * - Write operations need fields not present in stored data (e.g., formulaFn)
 * - System-generated fields (id, timestamps) should be hidden from write ops
 * - Examples: Cell, Location (have formula functions, placement context)
 *
 * WHEN NOT TO USE (use single-file domain-module.ts.template instead):
 * - Read and write types are identical
 * - Simple value objects without computed properties
 * - Examples: Header, Period, Money
 *
 * NAMING CONVENTION:
 * - Interface name = parent module name (Cell.Cell, Location.Location)
 * - This is the Effect-TS style, barrel re-exports type at top level
 *
 * Usage after import:
 *   import * as Cell from "./Cell"
 *
 *   // Read-side is DEFAULT (most common case)
 *   const readCell: Cell.Cell = Cell.make(...)
 *
 *   // Write-side requires explicit namespace
 *   const writeCell: Cell.Input = Cell.Write.make(...)
 *
 * PLACEHOLDERS TO REPLACE:
 * - __ModuleName__ → Your module name (e.g., Cell, Location, Placed)
 */

// Grouped namespaces (for explicit access)
export * as Write from "./Input.js";
export * as Read from "./Model.js";

// Top-level type aliases - __ModuleName__.__ModuleName__ is the canonical type
export { type Input } from "./Input.js";
export { type __ModuleName__ } from "./Model.js";

// Re-export Model (read-side) as default - THIS IS KEY
export * from "./Model.js";
```
