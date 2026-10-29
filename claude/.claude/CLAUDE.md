# Personal preferences

Follow the existing conventions of the project you're in (code style, commit format, structure). Use the rules below where it has none.

## Working style

- Keep responses brief by default. Go into detail only when I ask why or how.
- If a request is ambiguous, ask before starting rather than guessing.
- Only change what was asked. If you notice other issues, mention them and ask before fixing.
- Run the relevant tests and linters before finishing. If something wasn't run, say so.

## Code

- Prefer editing existing files over creating new ones.
- Ask before adding new dependencies.
- Comment sparingly: only non-obvious logic, and explain why rather than what.
- When changing behaviour in a project that has a test suite, add or update tests. Cover edge cases and failure paths, not just the happy path.
- Follow clean architecture and separation of concerns: keep business logic apart from I/O, UI and framework code, and keep modules focused on one responsibility. Don't introduce layers or abstractions into small scripts or one-off code.
- Program defensively: validate input at system boundaries, handle errors explicitly, and fail loudly with useful messages rather than swallowing exceptions. Don't add checks for states that can't happen, and never hardcode secrets or credentials.

## Git

- Write commit messages in Conventional Commits format (`feat:`, `fix:`, `chore:`, ...).
