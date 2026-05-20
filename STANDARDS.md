# Development Standards

## State Management

### Choosing Between Cubit and Bloc

**Use Cubit** from the Bloc ecosystem for simpler state management:
- Straightforward state changes without complex event handling
- Less boilerplate than full Bloc
- Ideal for isolated feature state

**Use full Bloc** when the flow is more complex, async-heavy, or has many user/system actions:
- Multiple events triggering different state transitions
- Complex async operations and side effects
- Orchestrating multiple operations in sequence
- Rich event history or debugging requirements

### What to Avoid

Avoid using Bloc for tiny UI state like "is this dropdown open?" unless that state matters outside the widget. Keep local UI state in `StatefulWidget` or simple widget state variables.

### Alternatives

For new apps, also consider **Riverpod** if you want less boilerplate. However, Bloc remains a solid and mature choice for serious Flutter applications and is the recommended default for this project.

### Summary

- **Cubit**: Simple state, fewer dependencies
- **Bloc**: Complex flows, async-heavy, many actions
- **Keep local**: Widget-scoped UI state (dropdown, toggle, form focus)
- **Bloc ecosystem**: Safe, professional, well-documented for serious apps
