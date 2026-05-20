# Flutter State Management Standards

- Use **Cubit** from the Bloc ecosystem for simpler state. 
- Use full **Bloc** with events when the flow is more complex, async-heavy, or has many user/system actions. 
- Avoid using Bloc for tiny UI state like “is this dropdown open?” unless that state matters outside the widget.

For most serious Flutter apps, Bloc is a solid and mature choice. If you are starting a new app and want less boilerplate, also look at Riverpod, but Bloc is still a very safe professional option.