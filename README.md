# Web3 Wallet Dashboard

A Flutter application that displays cryptocurrency wallet balances from the Ethereum Sepolia testnet using the Alchemy API. This project demonstrates clean architecture, state management with BLoC, local caching, and comprehensive testing.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the App](#running-the-app)
- [Running Tests](#running-tests)

## ✨ Features

- Display wallet address in shortened format (e.g., 0x86bB...5088)
- Fetch and display ETH balance from Sepolia testnet
- Fetch and display all ERC-20 token balances
- Show token symbol, name, and balance for each token
- Display total portfolio value in USD
- Loading and error state handling
- Local caching for offline support
- Pull-to-refresh functionality
- Comprehensive unit and widget tests

## 🏗 Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

### Layers

```text
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  - Screens (e.g. BalancesScreen)    │
│  - BLoC (State Management)          │
└─────────────────────────────────────┘
                ↓
┌─────────────────────────────────────┐
│       Domain Layer (Business)       │
│  - Repository Interfaces            │
│  - Models                           │
│  - Use Cases (optional/implicit)    │
└─────────────────────────────────────┘
                ↓
┌─────────────────────────────────────┐
│        Data Layer (Sources)         │
│  - Repository Implementation        │
│  - Remote API (Alchemy)             │
│  - Local Storage (SharedPreferences)│
└─────────────────────────────────────┘
```
### Key Architectural Decisions

#### 1. **BLoC Pattern for State Management**
- **Why**: Provides clear separation between business logic and UI, making the code testable and maintainable
- **Implementation**: `BalancesBloc` manages wallet state with events (`FetchBalances`) and states (`Loading`, `Loaded`, `Error`)

#### 2. **Repository Pattern**
- **Why**: Abstracts data sources (API and cache) from business logic
- **Implementation**: `TokenRepo` interface with `TokenRepoImpl` that coordinates between API and local storage
- **Cache Strategy**:
    - Try cache first for faster loading
    - Fetch from API if cache is empty or `forceRefresh: true`
    - Save API response to cache for future use
    - Fallback to cache if API fails (offline support)

#### 3. **Dependency Injection with GetIt**
- **Why**: Makes the app modular and testable by managing dependencies centrally
- **Implementation**: Service locator pattern in `service_locator.dart` registers all dependencies

#### 4. **Local Caching with SharedPreferences**
- **Why**: Simple, reliable, and sufficient for storing JSON data
- **Alternative Considered**: `flutter_local_db` was initially used but had compatibility issues on Android
- **Implementation**: `LocalStorageManager` wraps SharedPreferences with type-safe methods

#### 5. **Retrofit for API Calls**
- **Why**: Type-safe HTTP client with automatic JSON serialization
- **Implementation**: `TokenApi` interface with generated implementation

#### 6. **Utility Class for Conversions**
- **Why**: Centralizes complex logic like hex-to-decimal conversion and USD calculations
- **Implementation**: `WalletUtils` with static methods for reusability and testability

## 📦 Prerequisites

- Flutter SDK: `>=3.0.0`
- Dart SDK: `>=3.0.0`
- An Alchemy API key (free tier is sufficient)

## 🔧 Setup

### 1. Clone the Repository
```bash
git clone https://github.com/karansnarula/web3_wallet_dashboard
cd web3_wallet_dashboard
```
### 2. Install Dependencies
```bash
flutter pub get
```
### 3. API Key Setup
Get Alchemy API Key:

1) Go to Alchemy
2) Sign up for a free account
3) create .env file in the root of project
4) Copy your API Key and paste inside the .env file

### 4. Generate Code (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
## 🚀 Run the App
```bash
flutter run
```
## 🧪 Running Tests
```bash
flutter test
```

Run Tests with Coverage
```bash
flutter test --coverage
```

View coverage report:
```bash
# Install lcov (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

## 📝 License
This project is created for assignment purposes.

## 👤 Author
Karan Singh Narula

## 🙏 Acknowledgments
- [Alchemy](https://www.alchemy.com) API for blockchain data  
- [Flutter](https://flutter.dev/) for the amazing framework  
- [BLoC](https://bloclibrary.dev/) Pattern for state management guidance  