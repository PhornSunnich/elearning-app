# Team Plan: E-Learning App

Members: sunnich, thearong, visal, saran
(Fill in each person's GitHub username next to their name.)

## Status

| Phase | Item | State |
|---|---|---|
| 1 | Project setup, theme, router | Done (main) |
| 2.1 | Core widgets | Done (dev) |
| 2.2 | Splash and onboarding | Done (dev) |
| 2.3 | Login, Register | Next |

## Ownership (avoids merge conflicts)

| Member | Owns | Branches |
|---|---|---|
| sunnich | `features/auth`, `core/` | `feature/auth-screens`, `feature/main-navigation` |
| thearong | `features/home`, `features/courses` | `feature/home-dashboard`, `feature/course-discovery`, `feature/course-details` |
| visal | `features/lesson_player`, `features/my_learning` | `feature/my-learning`, `feature/lesson-player` |
| saran | `features/quizzes`, `features/certificates`, `features/profile`, `features/notifications` | `feature/quizzes`, `feature/profile`, `feature/certificates` |

## Order of work

1. sunnich: `feature/auth-screens` and `feature/main-navigation` (bottom nav shell, 5 tabs).
   Others wait for the navigation shell to merge before wiring their screens into tabs.
2. In parallel, using mock data and a fake repository per feature:
   - thearong: Home, Course Discovery, Course Details
   - visal: My Learning, Lesson Player UI
   - saran: Quiz screens, Profile
3. Everyone: merge into `dev`, test together, then PR `dev` to `main`.

## Pattern every feature follows

```
features/<feature>/
  domain/entities/        pure Dart classes
  domain/repositories/    abstract interface
  data/repositories/      Fake*Repository now, real API in Phase 3
  presentation/viewmodels/  Riverpod notifier + state
  presentation/screens/   UI using core widgets
```

Use a fake repository returning hard-coded data now. Phase 3 swaps it for Dio
without changing the UI.

## Definition of done

- [ ] `flutter analyze` clean
- [ ] Loading, empty, error, success states
- [ ] Uses `core/widgets`
- [ ] PR approved by a teammate and merged into `dev`

## Weekly rhythm

- Monday: pick tasks, create branches
- Midweek: merge small PRs into `dev`, pull daily
- Friday: test `dev` together, fix issues, PR to `main` if stable