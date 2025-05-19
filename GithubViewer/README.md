# GitHub Viewer

A modern iOS application that allows users to browse GitHub users and their repositories. Built with SwiftUI and following MVVM architecture.

## Features

- Browse GitHub users with infinite scrolling
- View detailed user profiles
- Explore user repositories
- Offline support with caching
- Error handling with retry mechanism
- Analytics tracking
- Accessibility support

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- SwiftUI
- Combine

## Architecture

The project follows MVVM (Model-View-ViewModel) architecture with Coordinator pattern for navigation:

### Components

- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Models**: Data models and entities
- **Services**: Network, Analytics, and Cache services
- **Coordinators**: Navigation and flow management
- **Configuration**: App configuration and environment settings

### Key Features

- **Dependency Injection**: Using `DependencyContainer` for service management
- **Protocol-Oriented Design**: Clear interfaces and abstractions
- **Reactive Programming**: Using Combine for data flow
- **Error Handling**: Comprehensive error handling with retry mechanism
- **Caching**: Local storage for offline support
- **Analytics**: Event tracking and error reporting

## Testing

To run tests:
1. Open the project in Xcode
2. Press ⌘U to run all tests
3. Or use the Test Navigator to run specific test cases

## Configuration

The app supports different environments:
- Development
- Staging
- Production

Configuration can be modified in `AppConfiguration.swift`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
