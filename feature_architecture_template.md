# Feature-Driven Architecture Template

This template describes the structure and organization of a feature-driven architecture in Flutter.

## Project Structure

```
lib/
  ├── core/
  │   ├── constants/
  │   ├── errors/
  │   ├── network/
  │   ├── usecases/
  │   └── utils/
  ├── features/
  │   └── [feature_name]/
  │       ├── data/
  │       │   ├── datasources/
  │       │   ├── models/
  │       │   └── repositories/
  │       ├── domain/
  │       │   ├── entities/
  │       │   ├── repositories/
  │       │   └── usecases/
  │       └── presentation/
  │           ├── bloc/
  │           ├── pages/
  │           └── widgets/
  └── injection_container.dart
```

## Core Layer
The core layer contains shared functionality and utilities used across the application:
- Constants: Application-wide constants
- Errors: Custom error handling
- Network: Network-related utilities
- Usecases: Base usecase implementations
- Utils: Helper functions and utilities

## Feature Layer
Each feature is self-contained and follows clean architecture principles:

### Data Layer
- Datasources: Local and remote data sources
- Models: Data models
- Repositories: Implementation of repository interfaces

### Domain Layer
- Entities: Business objects
- Repositories: Repository interfaces
- Usecases: Business logic

### Presentation Layer
- Bloc: State management
- Pages: Screen implementations
- Widgets: Reusable UI components

## Usage
To create a new feature:
```bash
clean_structure feature --name your_feature_name
```

This will generate the complete feature structure with all necessary files and folders. 