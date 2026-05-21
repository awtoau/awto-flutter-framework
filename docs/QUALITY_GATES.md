# Code Quality Gates

Automated code quality checks that run on every push and pull request.

## Overview

Quality gates are automated checks that enforce code standards:
- **Coverage Threshold** — Minimum test coverage (80%)
- **Code Format** — `dart format` compliance
- **Code Analysis** — `dart analyze` with strict rules
- **Performance** — Build time thresholds
- **Security** — Hardcoded secrets detection, dependency vulnerabilities
- **Dependencies** — Dependency analysis and auditing

## Quality Gates Workflow

See `.github/workflows/quality-gates.yml`

### Checks Performed

#### 1. Coverage Check
- Runs test with coverage reporting
- Verifies coverage ≥ 80%
- Uploads to Codecov
- Blocks PR if below threshold

**Bypass Condition:** None (must improve code)

#### 2. Lint Check
- Checks code formatting
- Runs analysis with strict rules
- Fails on:
  - Format violations
  - Analysis errors
  - Type warnings

**Bypass Condition:** None (must fix)

#### 3. Performance Check
- Measures build time
- Warns if exceeds 60s (doesn't fail)
- Tracks regression trends

**Bypass Condition:** Manual review if justified

#### 4. Security Check
- Scans for hardcoded secrets
- Checks for vulnerable packages
- Fails on hardcoded credentials

**Bypass Condition:** None (must remove secrets)

#### 5. Dependency Check
- Lists all dependencies
- Checks for outdated packages
- Analyzes dependency tree
- Warns on unused imports

**Bypass Condition:** Manual review

#### 6. Status Check
- Verifies all checks passed
- Blocks merge if any fails
- Provides clear status

## Coverage Threshold

### Target: 80%

Why 80%?
- **High Enough** — Catches major gaps
- **Achievable** — Reasonable for all features
- **Practical** — Last 20% often has diminishing returns

### Measuring Coverage

```bash
# Generate coverage report
cd apps/cli
dart test --coverage=coverage

# View report (Mac)
genhtml -o coverage coverage/coverage.lcov
open coverage/index.html
```

### Improving Coverage

1. **Identify gaps:** Look at coverage report
2. **Add tests:** Write tests for uncovered code
3. **Focus on logic:** Test business logic thoroughly
4. **Accept limits:** Some code is hard to test (UI, mocks, stubs)

**Example:** If coverage is 75%, add tests until ≥80%

```dart
// Before: No test coverage
class Calculator {
  int add(int a, int b) => a + b;
}

// After: Full coverage
test('add returns sum', () {
  final calc = Calculator();
  expect(calc.add(2, 3), equals(5));
  expect(calc.add(-1, 1), equals(0));
  expect(calc.add(0, 0), equals(0));
});
```

## Code Format

### Standard: Dart Format

```bash
# Auto-format all code
dart format -i lib/ test/

# Check without changing
dart format --set-exit-if-changed lib/ test/
```

**Key Rules:**
- 2-space indentation
- 80-character line limit
- No trailing whitespace
- Organized imports

### Enforcing in CI

Fails PR if code not formatted:
```
❌ Code formatting issues found. Run: dart format -i lib/ test/
```

**Fix:** Run formatter locally and re-commit:
```bash
dart format -i apps/cli/lib apps/cli/test apps/gui/lib apps/gui/test
git add .
git commit --amend
git push --force-with-lease
```

## Code Analysis

### Strict Rules

Enabled in `analysis_options.yaml`:
- No unused imports
- Type annotations required
- Error severity: error (not warning)
- Exclude: generated code, build artifacts

### Common Issues

| Issue | Fix |
|-------|-----|
| Unused import | Remove or use |
| Missing type | Add type annotation |
| Type mismatch | Fix types |
| Deprecated API | Use replacement |

### Running Locally

```bash
# Analyze code
dart analyze

# With fatal info flags
dart analyze --fatal-infos

# Analyze specific file
dart analyze lib/cubits/counter_cubit.dart
```

## Performance Monitoring

### Build Time Threshold

- **Target:** < 30 seconds
- **Warning:** 30-60 seconds
- **Failure:** > 60 seconds (manual review needed)

### Measuring Build Time

```bash
time ./scripts/build-deploy.sh --app cli

# Or check CI logs for timing
```

### Optimizing Build Time

1. **Parallel builds:** Enable in gradle
2. **Incremental compilation:** Use hot reload
3. **Cache dependencies:** Pre-downloaded
4. **Skip unnecessary:** Only build what changed

## Security Gates

### Hardcoded Secrets Detection

Scans for patterns:
```
password=
API_KEY=
secret=
token=
```

**Prevention:**
- Use environment variables
- Use secure storage
- Use `.env` files (gitignored)

### Dependency Vulnerabilities

Checks for known vulnerabilities in packages.

**How to fix:**
```bash
# Update packages
flutter pub upgrade

# Or lock specific version
dependency: ^2.0.0
```

## Performance Dashboard

View quality trends:

1. **Codecov:** Coverage over time
2. **GitHub Actions:** Build times, duration
3. **Logs:** See detailed performance metrics

## Failure Recovery

### If Quality Gate Fails

1. **Identify failure:** Check GitHub Actions output
2. **Fix locally:** Reproduce and fix
3. **Re-run checks:** Commit fix, wait for re-run
4. **Merge:** Once all green

### Common Failures

**Coverage Below 80%**
```bash
# Add tests
cd apps/cli
dart test --coverage=coverage
# View coverage/index.html
# Add tests for red lines
```

**Format Issues**
```bash
dart format -i lib/ test/
git add .
git commit -m "fix: code formatting"
```

**Analysis Errors**
```bash
dart analyze
# Fix each reported issue
git add .
git commit -m "fix: analysis issues"
```

**Security Alert**
```bash
# Remove hardcoded values
# Move to config or secure storage
git add .
git commit -m "fix: remove hardcoded secrets"
```

## Disabling Gates (Not Recommended)

To skip quality gates (dangerous):

❌ **Not allowed for security checks**
- Hardcoded secrets

⚠️ **Requires approval for:**
- Coverage threshold
- Performance threshold
- Lint failures (rarely)

### Request Exception

1. Explain why gate cannot be met
2. Provide plan to fix
3. Request code review approval
4. Document in ADR

## Continuous Improvement

### Monthly Review

1. **Coverage trends:** Is it improving?
2. **Build times:** Getting faster?
3. **Issues:** Most common failures?
4. **Improvements:** Can we raise standards?

### Adjusting Thresholds

When ready to improve:

1. **Raise coverage:** 80% → 85%
2. **Tighten build time:** 60s → 45s
3. **Enable new checks:** Add security scan
4. **Update analysis rules:** Stricter linting

## References

- [Codecov Documentation](https://docs.codecov.io/)
- [Dart Analysis Guide](https://dart.dev/guides/language/analysis-options)
- [GitHub Actions Status Checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-the-fork-and-branch-workflow/about-pull-requests#about-statuses)
- [Security Best Practices](SECURITY.md)
