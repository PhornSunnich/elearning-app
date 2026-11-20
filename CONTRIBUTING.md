# Contributing Guide

Team: sunnich, thearong, visal, saran

## 1. First-time setup (every teammate)

1. Accept the GitHub invitation (check your email or github.com/notifications).
2. Install Flutter (stable) and Android Studio. Run `flutter doctor`.
3. Clone and start from `dev`:

```powershell
cd C:\dev
git clone https://github.com/PhornSunnich/elearning-app.git
cd elearning-app
git switch dev
flutter pub get
flutter analyze
flutter run -d chrome
```

`flutter analyze` must print `No issues found!`. Do NOT run `flutter create`.

Set your Git identity once:

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## 2. Branches

| Branch | Purpose | Who pushes |
|---|---|---|
| `main` | Stable, demo-ready. Updated at the end of each phase | PR from `dev` only |
| `dev` | Integration and testing | PRs from `feature/*` only |
| `feature/<name>` | One piece of work | The owner |

Never push directly to `main` or `dev` (the rulesets block it).

Naming: `feature/login-screen`, `fix/token-refresh`, `refactor/router`, `docs/readme`.

## 3. Daily workflow

```powershell
# 1. Start from the latest dev
git switch dev
git pull

# 2. New branch for ONE task
git switch -c feature/course-list

# 3. Work, check, commit often
flutter analyze
git add <files>
git status
git commit -m "Add course list screen"

# 4. Push and open a Pull Request
git push -u origin feature/course-list
```

On GitHub: **Compare & pull request**, then CHECK `base: dev`, then Create.
A teammate reviews and approves, then merge, then **Delete branch**.

After the merge (in this order):

```powershell
git switch dev
git pull
git fetch --prune
git branch -d feature/course-list
```

## 4. Keep your branch up to date

```powershell
git switch dev
git pull
git switch feature/course-list
git merge dev
```

If there is a conflict, open the file, keep the right lines, delete the
`<<<<<<<`, `=======`, `>>>>>>>` markers, then:

```powershell
git add .
git commit
```

## 5. Common mistakes

| Mistake | Fix |
|---|---|
| `git commit` says "nothing added to commit" | Run `git add <files>` first |
| PR base is `main` | Change base to `dev` before creating |
| Deleted local branch before merge | Safe. Work is on GitHub. Merge the PR first, then pull |
| Pushed to the wrong branch | Tell the team. Do not force push |
| Committed `build/` or secrets | Never commit `.env`, keys, or `build/` |

## 6. Code rules

1. Feature-first Clean Architecture: `data`, `domain`, `presentation` per feature.
2. No API calls inside widgets. Use repositories and Riverpod ViewModels.
3. Reuse widgets from `lib/core/widgets` (button, text field, loading, empty, error).
4. Import UI from `package:material_ui/material_ui.dart`, not `flutter/material.dart`.
5. Handle loading, empty, error, and success states on every screen.
6. Validate all user input.
7. `flutter analyze` must be clean before every PR.
8. Small PRs (one feature, under about 400 changed lines).

## 7. Shared files: be careful

Only change these in small, quick PRs and tell the team first:

- `pubspec.yaml`
- `lib/core/router/app_router.dart`
- `lib/core/router/app_routes.dart`
- `lib/core/theme/*`

Adding a route? Add only your own lines and merge quickly.

## 8. Review checklist (reviewer)

- [ ] Base branch is `dev`
- [ ] `flutter analyze` is clean
- [ ] No business logic or API calls in widgets
- [ ] Loading, empty, and error states handled
- [ ] No secrets, no `build/`, no unrelated files
- [ ] App runs (`flutter run -d chrome`)

## 9. Releasing to main

At the end of each phase:

1. Everyone merges finished work into `dev`.
2. On `dev`: `flutter pub get`, `flutter analyze`, `flutter test`, run the app.
3. Open a PR from `dev` to `main`, review, merge.
4. Tag it:

```powershell
git switch main
git pull
git tag phase-2
git push --tags
```