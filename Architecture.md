# Architecture

## Atlas

Version: 1.0  
Status: Draft

---

# Purpose

This document describes the technical architecture of Atlas.

Its goal is to ensure every contributor—including AI coding agents—implements features consistently and makes architectural decisions that align with the long-term vision of the application.

The architecture prioritizes simplicity, maintainability, testability, and Apple's native frameworks.

---

# Guiding Principles

## Native First

Atlas is a native Apple application.

Whenever Apple provides a framework that solves a problem well, use it.

Avoid introducing third-party dependencies unless they provide significant and measurable value.

---

## Offline First

Atlas must function without an internet connection.

Users should always be able to:

- browse their library
- search their library
- edit places
- organize places
- create new places

CloudKit synchronizes changes opportunistically in the background.

Internet connectivity should never be required for normal use.

---

## Local Data Ownership

SwiftData is the source of truth.

CloudKit is synchronization.

CloudKit is **not** considered the primary database.

This allows Atlas to remain responsive, reliable and private.

---

## Small Components

Large files are difficult to understand.

Favor many small reusable components over large monolithic classes.

Recommended maximum sizes:

| Type | Target |
|-------|--------|
| View | <250 lines |
| ViewModel | <300 lines |
| Repository | <300 lines |

Split files early instead of late.

---

# Technology Stack

| Layer | Technology |
|--------|------------|
| UI | SwiftUI |
| Navigation | NavigationStack |
| Persistence | SwiftData |
| Synchronization | CloudKit |
| Maps | MapKit |
| Location | CoreLocation |
| Search | MKLocalSearch |
| Concurrency | async/await |
| Logging | OSLog |
| Testing | XCTest |

---

# High Level Architecture

```
┌─────────────────────────────┐
│         SwiftUI Views        │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         ViewModels          │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│        Repositories         │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         SwiftData           │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         CloudKit            │
└─────────────────────────────┘
```

Views never access persistence directly.

Repositories are the only objects allowed to communicate with SwiftData.

---

# Architectural Style

Atlas follows **MVVM + Repository Pattern**.

## View

Responsible for:

- Rendering UI
- User interaction
- Binding state
- Navigation

Views never:

- Query SwiftData
- Perform business logic
- Perform networking

---

## ViewModel

Responsible for:

- Presentation logic
- Input validation
- Loading data
- User actions
- Error handling

ViewModels expose observable state.

ViewModels never know how persistence works.

---

## Repository

Repositories abstract persistence.

Example:

```
LocationRepository

CategoryRepository

CollectionRepository

TagRepository
```

Repositories may internally use:

- SwiftData
- CloudKit
- Local cache

The rest of the application must never depend on those implementation details.

---

# Dependency Injection

Never use global singletons.

Dependencies should be injected.

Preferred approaches:

- Environment
- Initializer injection

Example:

```
LibraryView
      ↓
LibraryViewModel
      ↓
LocationRepository
```

This makes testing significantly easier.

---

# Folder Structure

```
Atlas

├── App
│   ├── AtlasApp.swift
│   └── AppCoordinator.swift
│
├── Features
│   ├── Library
│   ├── Map
│   ├── Search
│   ├── Collections
│   ├── Categories
│   ├── Tags
│   ├── Settings
│   └── Shared
│
├── Core
│   ├── Models
│   ├── Repositories
│   ├── Services
│   ├── Utilities
│   ├── Extensions
│   └── DesignSystem
│
├── Resources
│
└── Tests
```

Features own their Views and ViewModels.

Shared logic belongs in Core.

---

# Persistence

SwiftData stores all user data locally.

Persistence must be abstracted behind repositories.

Views must never use:

- ModelContext
- FetchDescriptor
- SwiftData queries

directly.

---

# CloudKit

CloudKit provides synchronization only.

Responsibilities:

- Device synchronization
- Conflict resolution
- Background sync

Non-responsibilities:

- Business logic
- Authentication
- Search
- Validation

Atlas must continue functioning when CloudKit is unavailable.

---

# Domain Model

Core entities:

- Place
- Category
- Collection
- Tag

Relationships:

```
Place

├── many Categories
├── many Collections
└── many Tags
```

Future entities:

- Photo
- Attachment
- Visit
- SharedCollection

---

# Maps

Atlas uses MapKit exclusively.

Features:

- Apple Maps
- User location
- Dropped pins
- Search
- Clustering
- Annotation selection

Google Maps is not supported.

---

# Search

Atlas contains two independent search systems.

## External Search

Uses MKLocalSearch.

Purpose:

Find places that are not yet saved.

---

## Internal Search

Searches the local library.

Indexes:

- title
- notes
- categories
- collections
- tags

Future versions may introduce full-text indexing.

---

# Sharing

Version 1:

Share exported Atlas data using ShareLink.

Possible formats:

- JSON
- Custom file type

Future versions:

- Universal Links
- Shared CloudKit collections

---

# Logging

Use Apple's Logger API.

Never leave print() statements in production.

Errors should be logged with meaningful context.

---

# Error Handling

Never use:

```
try!
```

Never use:

```
fatalError()
```

Recover gracefully whenever possible.

Present user-friendly error messages.

---

# Concurrency

Use Swift Concurrency.

Preferred:

- async/await
- Task
- TaskGroup

Avoid callback-based APIs when modern alternatives exist.

Never block the main thread.

---

# Testing

Minimum requirements:

- ViewModels
- Repository implementations
- Business rules
- Validation

UI tests are reserved for critical user flows.

Repositories should always be mockable.

---

# Accessibility

Accessibility is mandatory.

Support:

- VoiceOver
- Dynamic Type
- Dark Mode
- Increased Contrast
- Reduce Motion

Every interactive control must expose accessibility labels.

---

# Performance

Optimize for responsiveness.

Guidelines:

- Lazy containers where appropriate
- Avoid unnecessary map refreshes
- Avoid unnecessary redraws
- Avoid excessive SwiftData fetches
- Load data asynchronously

---

# Future Platform Support

Architecture should support future expansion to:

- iPad
- macOS
- visionOS

Business logic must remain platform-independent.

UI should be implemented entirely in SwiftUI whenever possible.

---

# Non Goals

Atlas deliberately avoids:

- Firebase
- Supabase
- Custom backend
- UIKit (unless unavoidable)
- Third-party persistence libraries
- Third-party map SDKs
- Analytics SDKs
- Advertising SDKs

---

# Definition of Done

A feature is complete only when:

- It compiles without warnings.
- It has no force unwraps.
- Business logic is tested.
- Accessibility has been verified.
- Dark Mode works.
- Dynamic Type works.
- Offline behaviour has been verified.
- The implementation follows MVVM.
- Persistence goes through repositories.
- Public APIs are documented.