# AGENTS.md

## Overview

This document outlines the architectural principles, code style, and testing conventions used across this codebase. All contributors should follow these guidelines to ensure consistency, readability, and maintainability.

---

## 📦 Package Structure

We structure packages using a modular, domain-first approach:

```
Source/
├── Data/         # Networking, DTOs, descriptors
├── UseCases/     # Core business logic and interactors
└── Views/        # SwiftUI views and ViewModels
```

Each layer has a clearly defined responsibility and no unnecessary cross-contamination.

---

## 🖼 SwiftUI Views

Views follow a strict separation of concerns and naming conventions:

- All views must use the `View` suffix (e.g., `VerticalVenueCardView`)
- Views must take a `ViewState` struct in their initializer and render directly from it
- Views should never create or mutate state internally unless absolutely necessary
- ViewState types are `public`, but the internal `viewState` property in the view remains `private`

### Composition

Keep view bodies minimal and composed of private helpers:
```swift
var body: some View {
  VStack {
    header
    content
    footer
  }
}

private var header: some View { ... }
private var content: some View { ... }
private var footer: some View { ... }
```

Split larger views early into self-contained subviews.

---

## ⚙️ ViewModels

ViewModels follow these rules:

- Must **not** be marked with `@Observable`
- Vend `LoadingState<Nothing, ViewState>`
- Drive all state transitions explicitly and immutably
- Expose async `submit(...)` style methods that the view `await`s directly
- View handles error reporting locally — do not leak error logic into the ViewModel

---

## 🌐 Networking

All network interactions use **descriptors** to encapsulate request/response logic.  
Each request descriptor should follow the pattern:

```swift
struct GetVenueDetailsDescriptor: NetworkRequestDescriptor {
  ...
}
```

- DTOs are defined in `Data/DTOs` and are purely representational
- ViewState mapping is done in separate mapper objects (e.g., `VenueDetailsViewStateMapper`)

---

## ✅ Testing

All unit tests follow the `import Testing` framework conventions:

### Test Style

- Use `@Test` and `#expect` consistently
- Tests must go in **separate files** — never inline test diffs with implementation files
- Always assert on **exact invocations**, not just call counts or presence

### Mocks

Mocks are pre-generated with support for:

```swift
mockDependency._method.implementation = .returns(value) // or .throws(error)
mockDependency._method.lastInvocation // to inspect inputs
```

Use `.invocations` for multiple call assertions and verify inputs deeply.

### Parameterized Testing

Use parameterized testing with `@Test(arguments:)` to ensure broad and expressive coverage across input ranges:

```swift
@Test(arguments: [
  (input: 1, expected: "One"),
  (input: 2, expected: "Two")
])
func testMapping(input: Int, expected: String) throws {
  #expect(map(input)) == expected
}
```

---

## ⚡️ Swift Concurrency & Compatibility

This codebase targets the Swift 6 concurrent compiler and adheres to modern concurrency rules:

- Use `@MainActor` for view models and UI-affecting logic
- Explicitly conform to `Sendable` where appropriate
- Avoid shared mutable state across concurrency domains

---

## 🧠 Design Philosophy

- Small, focused, testable units
- Clear ownership and boundaries
- Prefer composition over inheritance or feature bloat
- Readability > Cleverness
- Ship maintainable code, not just working code

---

## 📬 Questions or Changes?

If you’re introducing new patterns or proposing architectural changes, create a draft proposal and get buy-in before merging. Consistency is key.
