# ADR 0001: Use Bloc for State Management

## Status

✅ ACCEPTED

## Context

We needed to choose a state management solution for this Flutter framework project. The main contenders were:
1. **Provider** — Popular, simple, good for small apps
2. **GetX** — Feature-rich, lots of functionality, opinionated
3. **Bloc** — Mature, testable, event-driven, community support
4. **Riverpod** — Modern, functional, flexible

Key requirements:
- **Testability** — Automated testing was a primary goal
- **Scalability** — Support both simple and complex state
- **Learning Curve** — Clear patterns for team adoption
- **Community** — Active maintenance and support
- **Enterprise-Ready** — Used in production at scale

## Decision

**We chose the Bloc ecosystem** (Bloc for complex state, Cubit for simple state) for several reasons:

### Why Bloc?

1. **Built for Testing** — `bloc_test` makes unit testing straightforward
   - Bloc naturally separates concerns (events, state, business logic)
   - Easy to write deterministic tests
   - Can verify state transitions without side effects

2. **Clear Patterns** — Event-driven architecture is intuitive
   - Events represent user actions/system triggers
   - States represent distinct UI states
   - Business logic in event handlers

3. **Incremental Adoption** — Cubit for simple cases, Bloc for complex
   - Counter, Timer → Cubit
   - Todo CRUD, HTTP requests → Bloc
   - Flexibility for different scenarios

4. **Enterprise Support** — Proven at scale
   - Used in production at large companies
   - Stable APIs, good backwards compatibility
   - Active maintenance and community

5. **Ecosystem** — Rich tooling and extensions
   - `bloc_test` for testing
   - Devtools for debugging
   - Good Flutter/Dart integration

### Alternative Analysis

**Provider**
- ❌ Less structured (no event pattern)
- ❌ Testing requires more boilerplate
- ✅ Simpler for trivial state

**GetX**
- ❌ Too opinionated, bloated with features
- ❌ Mixing concerns (routing, state, service locator)
- ❌ Less testable

**Riverpod**
- ✅ Modern, functional approach
- ✅ Good testability
- ❌ Steeper learning curve
- ❌ Less industry adoption than Bloc
- ❌ Would lock us into functional patterns

## Consequences

### Positive

1. ✅ Strong test coverage is achievable and encouraged
2. ✅ Clear architectural patterns for new developers
3. ✅ Easy to debug state transitions with devtools
4. ✅ Scales from simple to complex use cases
5. ✅ Good community resources and Stack Overflow help

### Negative

1. ❌ More boilerplate than some alternatives (events, states)
2. ❌ Learning curve for new team members
3. ❌ Larger bundle size compared to Provider
4. ❌ Can be overkill for very simple apps

### Neutral

1. ⚪ Committed to Bloc ecosystem for consistency
2. ⚪ Must follow event-driven patterns everywhere

## Implementation Guidelines

1. **Use Cubit** for simple, isolated state (no event handling)
   - Counters, toggles, simple forms
   - See: `lib/cubits/counter_cubit.dart`

2. **Use Bloc** for complex async operations and multiple events
   - CRUD operations, API calls
   - Cross-feature state coordination
   - See: `lib/blocs/todo_bloc.dart`

3. **Write Tests First** — Leverage `bloc_test`
   - See: `test/blocs/todo_bloc_test.dart`
   - See: `test/error_handling_test.dart`

4. **Keep Business Logic in Bloc**
   - Not in widgets
   - Not in UI layer
   - Single responsibility

## Related Decisions

- [ADR 0002](0002-testing-strategy.md) — Testing strategy with bloc_test
- [STANDARDS.md](../STANDARDS.md) — When to use Cubit vs Bloc

## References

- [Bloc Library Documentation](https://bloclibrary.dev)
- [Bloc in Production](https://bloclibrary.dev/bloc-examples/)
- [Testing Blocs](https://bloclibrary.dev/#bloc-test)
- [Why Bloc?](https://medium.com/flutter-community/why-i-use-the-bloc-pattern-5f8d4f9c6e20)
