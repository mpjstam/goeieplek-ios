# CLAUDE.md

This file contains permanent instructions for every AI coding agent working on Atlas.

If a user request conflicts with this document, ask for clarification before proceeding.

Never silently change architecture.

---

# Mission

Build an iOS application that feels like Apple could have made it.

Atlas is not feature driven.

Atlas is experience driven.

Every implementation decision should improve simplicity, speed and reliability.

---

# Golden Rules

1. Simplicity beats cleverness.

2. Readability beats brevity.

3. Native beats custom.

4. Small reusable components.

5. Offline first.

6. Accessibility is mandatory.

7. Never sacrifice UX for technical convenience.

8. Never introduce unnecessary dependencies.

9. Build for long-term maintainability.

10. If uncertain, choose the solution closest to Apple's Human Interface Guidelines.

---

# Tech Stack

SwiftUI

SwiftData

CloudKit

MapKit

Swift Concurrency

Observation

---

# Never Use

Firebase

Supabase

Realm

UIKit unless required

Third-party map libraries

Massive ViewControllers

Singletons

Force unwraps

---

# Architecture

Every feature follows MVVM.

Views never contain business logic.

Repositories own persistence.

ViewModels own presentation logic.

Models represent domain objects only.

---

# Repository Pattern

Views never communicate directly with SwiftData.

Views never know CloudKit exists.

Only repositories communicate with persistence.

This allows replacing persistence later without changing UI.

---

# Code Philosophy

Prefer boring code.

Prefer explicit code.

Prefer maintainable code.

Avoid clever abstractions.

Avoid premature optimization.

Optimize for future contributors.

---

# File Size

Target:

View
< 250 lines

ViewModel
< 300 lines

Repository
< 300 lines

Extensions only when they improve readability.

Split large files early.

---

# Testing

Every ViewModel should be testable.

Repositories should be mockable.

Business logic belongs in unit tests.

Avoid UI tests unless necessary.

---

# Accessibility

Every button has accessibility labels.

Support VoiceOver.

Support Dynamic Type.

Support Reduce Motion.

Support Dark Mode.

Support Increased Contrast.

Accessibility is part of the definition of done.

---

# Performance

Avoid unnecessary rendering.

Use lazy containers.

Avoid unnecessary map updates.

Never block the main thread.

Everything expensive must be asynchronous.

---

# Documentation

Every public type is documented.

Complex algorithms include explanations.

Future improvements should be documented using MARK comments.

---

# Before Every Commit

Project compiles.

No warnings.

No force unwraps.

No TODOs without issue reference.

Tests pass.