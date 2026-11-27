# E-Learning Mobile App

A Flutter e-learning app: discover courses, enroll, watch video lessons,
track progress, write reviews.

**Team:** Sunnich, Thearong, Visal, Saran

## Features
- Register, login, session kept across restarts (JWT, secure storage)
- Browse courses with search, categories and paging
- Course details: curriculum, ratings and reviews
- Enrollment and My Learning with progress
- Lesson player (video, mark complete, next/previous)
- Profile: edit, change password, light/dark theme

## Tech
Flutter, Dart, Material 3, Riverpod, GoRouter, Dio, Chewie/video_player,
Flutter Secure Storage, Hive. Clean Architecture, feature-first.

Backend: Spring Boot REST API with JWT and PostgreSQL, hosted on Render
(Swagger: https://student-management-system-eg8t.onrender.com/swagger-ui/index.html).

## Run
```bash
flutter pub get
flutter run -d chrome
```
The first request can take about a minute: the free Render server sleeps
when idle.

## Team workflow
See [CONTRIBUTING.md](CONTRIBUTING.md) and [TEAM_PLAN.md](TEAM_PLAN.md).
