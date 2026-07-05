# Rules Examples (Templates for Code Projects)

This file collects Factory-style **code** rules as reusable templates. They are **not active by default**: a freshly specialized repo's active rules in `.opencode/rules/` govern only markdown, JSONC, and bash. Copy or adapt any rule below into `.opencode/rules/` (and add the file to the `instructions` glob) once the repo has application code in the matching language. The `specialize-template` skill offers to do this automatically when it detects a code-bearing stack.

Each rule follows the standard format defined in [`.opencode/rules/rule-format.md`](../.opencode/rules/rule-format.md): a `## [Rule Name]` heading with `Applies to`, `Rule`, `Correct`/`Avoid` examples, and `Rationale`. Copy a rule verbatim, or trim it to fit the downstream stack, then add the owning file to that project's `instructions` glob.

## TypeScript

### Prefer `interface` over `type` for object shapes

- **Applies to**: TypeScript object definitions.
- **Rule**: declare extensible object shapes with `interface`; reserve `type` for unions, tuples, and mapped/utility types.
- **Example**:
  Correct:
  ```typescript
  interface User {
    id: string;
    name: string;
  }
  ```
  Avoid:
  ```typescript
  type User = {
    id: string;
    name: string;
  };
  ```
- **Rationale**: interfaces are extendable via declaration merging and produce clearer error messages; `type` aliases shine for unions and mapped types, not plain shapes.

### Never use `any`; use `unknown` with type guards

- **Applies to**: all TypeScript code.
- **Rule**: ban `any`. For untyped external data use `unknown` and narrow it with a type guard or a schema validator before use.
- **Example**:
  Correct:
  ```typescript
  function handle(parsed: unknown) {
    if (typeof parsed === "string") {
      return parsed.trim();
    }
    throw new Error("expected a string");
  }
  ```
  Avoid:
  ```typescript
  function handle(parsed: any) {
    return parsed.trim(); // no compile-time safety
  }
  ```
- **Rationale**: `any` silently disables type-checking; `unknown` forces a safe narrowing and keeps the type system honest at boundaries.

### Use named exports, not default exports

- **Applies to**: all TypeScript/JavaScript modules.
- **Rule**: export named symbols. Avoid `export default`.
- **Example**:
  Correct:
  ```typescript
  export function createUser(input: UserInput): User {
    // ...
  }
  ```
  Avoid:
  ```typescript
  export default function (input: UserInput): User {
    // ...
  }
  ```
- **Rationale**: named exports are refactor-safe, greppable, and give consistent import names across consumers; default exports invite rename-on-import and circular ambiguity.

## React

### Use functional components only

- **Applies to**: React component definitions.
- **Rule**: author components as functions (plain or arrow). Do not use class components.
- **Example**:
  Correct:
  ```tsx
  function Welcome({ name }: WelcomeProps) {
    return <h1>Hello, {name}</h1>;
  }
  ```
  Avoid:
  ```tsx
  class Welcome extends React.Component<WelcomeProps> {
    render() {
      return <h1>Hello, {this.props.name}</h1>;
    }
  }
  ```
- **Rationale**: function components work with Hooks, are simpler to test, and match the modern React mental model; class components exist only for legacy compatibility.

### Name the props interface `{Component}Props`

- **Applies to**: every React component that accepts props.
- **Rule**: declare the props type as an `interface` named `{ComponentName}Props` and annotate the component with it.
- **Example**:
  Correct:
  ```tsx
  interface AvatarProps {
    src: string;
    alt: string;
  }

  function Avatar({ src, alt }: AvatarProps) {
    return <img src={src} alt={alt} />;
  }
  ```
  Avoid:
  ```tsx
  function Avatar(props: { src: string; alt: string }) {
    return <img src={props.src} alt={props.alt} />;
  }
  ```
- **Rationale**: a consistently named, hoisted interface is easy to locate, reuse, and mock in tests; inline anonymous prop types are not reusable.

## Testing

### Colocate test files with the code under test

- **Applies to**: test file placement.
- **Rule**: put a unit's test next to it as `{unit}.test.{ts|tsx}` (or `{unit}.spec.{ts|tsx}`), not in a parallel `tests/` tree.
- **Example**:
  Correct:
  ```text
  src/user/createUser.ts
  src/user/createUser.test.ts
  ```
  Avoid:
  ```text
  src/user/createUser.ts
  tests/user/createUser.test.ts
  ```
- **Rationale**: colocated tests are trivial to find from the source, move with the file on rename, and keep related context in one directory.

### Write descriptive test names: `should X when Y`

- **Applies to**: every test case (`it` / `test`).
- **Rule**: phrase the test name as a behavior: `should <expected outcome> when <condition>`.
- **Example**:
  Correct:
  ```typescript
  it("should throw when the email is empty", () => {
    expect(() => createUser({ email: "" })).toThrow();
  });
  ```
  Avoid:
  ```typescript
  it("test1", () => {
    expect(() => createUser({ email: "" })).toThrow();
  });
  ```
- **Rationale**: the test name is the failure message; a behavior-phrased name documents intent and pinpoints the broken behavior on failure.

### One behavior per test; mock at boundaries

- **Applies to**: every test case.
- **Rule**: assert one behavior per test. Mock only at system boundaries (network, filesystem, clock, third-party APIs), never internal pure functions.
- **Example**:
  Correct:
  ```typescript
  it("should return the cached user when the fetch succeeds", async () => {
    const fetchUser = vi.fn().mockResolvedValue({ id: "1" });
    const result = await loadUser("1", { fetchUser });
    expect(result).toEqual({ id: "1" });
  });
  ```
  Avoid:
  ```typescript
  it("should fetch, cache, and log", async () => {
    // asserts three behaviors; failure is ambiguous
  });
  ```
- **Rationale**: one behavior per test gives a precise failure signal; mocking at boundaries keeps tests fast and faithful while leaving pure logic unmocked and trustworthy.

## Security

### Never hardcode secrets; read them from environment variables

- **Applies to**: all source and configuration.
- **Rule**: pull API keys, tokens, passwords, and connection strings from environment variables (or a secrets manager). Never commit literal secrets.
- **Example**:
  Correct:
  ```typescript
  const apiKey = process.env.API_KEY;
  if (!apiKey) throw new Error("API_KEY is not set");
  ```
  Avoid:
  ```typescript
  const apiKey = "FAKE-KEY-FOR-TESTING-NOT-REAL";
  ```
- **Rationale**: hardcoded secrets leak via the repo, logs, and bundles; environment variables keep secrets out of version control and rotate independently of code.

### Validate external input with a schema

- **Applies to**: request bodies, query params, env vars, and any data crossing a trust boundary.
- **Rule**: parse and validate external input against a schema (e.g. Zod) before use; reject early on failure.
- **Example**:
  Correct:
  ```typescript
  const UserInput = z.object({
    email: z.string().email(),
    age: z.number().int().min(0),
  });

  function handler(raw: unknown) {
    const input = UserInput.parse(raw); // throws on invalid
    // ...
  }
  ```
  Avoid:
  ```typescript
  function handler(raw: any) {
    sendEmail(raw.email); // no validation; trusts the caller
  }
  ```
- **Rationale**: unvalidated input is the root of injection and crash bugs; a schema validates, narrows the type, and centralizes the contract at the boundary.

### Never expose internal errors to clients

- **Applies to**: API responses and user-facing error messages.
- **Rule**: catch internal errors, log the detail server-side, and return a generic message to the client. Never forward stack traces, SQL, or internal paths.
- **Example**:
  Correct:
  ```typescript
  try {
    await db.query(sql);
  } catch (err) {
    logger.error({ err }, "query failed");
    throw new HttpError(500, "Internal server error");
  }
  ```
  Avoid:
  ```typescript
  try {
    await db.query(sql);
  } catch (err) {
    res.status(500).send(String(err)); // leaks internals
  }
  ```
- **Rationale**: internal error detail aids attackers (stack paths, query structure) and confuses users; log full detail where only you can see it and return a safe generic error otherwise.

## See also

- [`.opencode/rules/rule-format.md`](../.opencode/rules/rule-format.md) — the rule schema every entry above follows.
- [docs/memory-system.md](memory-system.md) — the full memory and rules architecture this file supports.
