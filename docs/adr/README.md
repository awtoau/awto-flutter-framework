# Architecture Decision Records (ADRs)

This directory contains Architecture Decision Records (ADRs) documenting important architectural decisions, trade-offs considered, and consequences.

## What is an ADR?

An Architecture Decision Record (ADR) is a document that captures an important architectural decision made during the project, including:
- **Context** — Why the decision was needed
- **Decision** — What was chosen and why
- **Consequences** — Benefits and drawbacks
- **Alternatives** — Other options considered

## Why ADRs?

1. **Knowledge Preservation** — Capture reasoning for future team members
2. **Context Sharing** — Document trade-offs considered
3. **Consistency** — Team alignment on architectural choices
4. **Onboarding** — New developers understand design philosophy
5. **Reversibility** — Understand when/how to change decisions

## Current Decisions

| # | Title | Status |
|---|-------|--------|
| [0001](0001-use-bloc-for-state-management.md) | Use Bloc for State Management | ✅ ACCEPTED |
| [0002](0002-comprehensive-testing-strategy.md) | Comprehensive Testing Strategy | ✅ ACCEPTED |

## Creating a New ADR

### File Naming

Use format: `NNNN-kebab-case-title.md`

Examples:
- `0003-use-riverpod-for-dependency-injection.md`
- `0004-api-error-handling-pattern.md`

### Template

```markdown
# ADR NNNN: [Title]

## Status

[PROPOSED / ACCEPTED / DEPRECATED / SUPERSEDED]

## Context

[Describe the issue or problem that this decision addresses.]

## Decision

[Describe what was decided and why.]

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Drawback 1]
- [Drawback 2]

## Related Decisions

- [ADR 0001](0001-*.md) — Related topic

## References

- [Link 1](https://example.com)
- [Link 2](https://example.com)
```

### Status Values

- **PROPOSED** — Under discussion, not yet decided
- **ACCEPTED** — Decision made and implemented
- **DEPRECATED** — Obsolete, replaced by new approach
- **SUPERSEDED** — Replaced by another ADR

### Process

1. **Create ADR file** with template
2. **Submit for team discussion** — Get feedback
3. **Finalize decision** — Update to ACCEPTED
4. **Implementation** — Code reflects decision
5. **Update this README** — Add entry to list

## Guidelines

1. **Focused** — Address one decision per ADR
2. **Concise** — Keep under 2 pages when possible
3. **Timeless** — Avoid dates, references to current date
4. **Rationale** — Explain WHY not just WHAT
5. **Reversible** — Document how to undo if needed

## When to Create ADR

Create ADRs for:
- ✅ Major architectural choices
- ✅ Technology selections
- ✅ Design patterns
- ✅ Trade-offs between options
- ✅ Decisions affecting multiple teams/features

Don't create ADRs for:
- ❌ Minor implementation details
- ❌ Feature-specific decisions
- ❌ Bug fixes
- ❌ Routine refactoring

## References

- [ADR GitHub Page](https://adr.github.io/)
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR Examples](https://github.com/joelparkerhenderson/architecture_decision_record)
