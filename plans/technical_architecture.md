# Technical Architecture Documentation

## Overview

This document provides detailed technical architecture for the enhanced gestion_budgetaire Flutter application, including system design, data flow, component interactions, and architectural patterns.

---

## Current Architecture

### Layer Structure

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[Views/Pages]
        B[Widgets]
    end
    
    subgraph "State Management"
        C[Providers]
    end
    
    subgraph "Business Logic"
        D[Services]
    end
    
    subgraph "Data Layer"
        E[Models]
        F[In-Memory Storage]
    end
    
    A --> C
    B --> C
    C --> D
    D --> E
    D --> F
```

### Current Limitations
- No data persistence
- Direct service-to-storage coupling
- Limited separation of concerns
- No repository pattern
- Mock authentication only

---

## Proposed Architecture

### Enhanced Layer Structure

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[Views/Pages]
        B[Widgets]
        C[View Models]
    end
    
    subgraph "State Management Layer"
        D[Providers/BLoC]
        E[State Objects]
    end
    
    subgraph "Business Logic Layer"
        F[Services]
        G[Use Cases]
        H[Validators]
    end
    
    subgraph "Data Layer"
        I[Repositories]
        J[Data Sources]
        K[Models/Entities]
    end
    
    subgraph "Infrastructure Layer"
        L[SQLite Database]
        M[Shared Preferences]
        N[Secure Storage]
        O[External APIs]
    end
    
    A --> D
    B --> D
    C --> D
    D --> F
    D --> G
    F --> I
    G --> I
    I --> J
    J --> L
    J --> M
    J --> N
    J --> O
    I --> K
```

---

## Detailed Component Architecture

### 1. Data Layer Architecture

```mermaid
graph LR
    subgraph "Repository Layer"
        A[UserRepository]
        B[TransactionRepository]
        C[BudgetRepository]
        D[CategoryRepository]
        E[RecurringTransactionRepository]
    end
    
    subgraph "Data Sources"
        F[Local Data Source]
        G[Remote Data Source]
        H[Cache Data Source]
    end
    
    subgraph "Storage"
        I[SQLite DB]
        J[Shared Prefs]
        K[Secure Storage]
        L[API Client]
    end
    
    A --> F
    A --> G
    B --> F
    B --> H
    C --> F
    D --> F
    E --> F
    
    F --> I
    F --> J
    G --> L
    H --> J
```

#### Repository Pattern Implementation

**Base Repository Interface**
```dart
abstract class Repository<T> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id);
}
```

**Transaction Repository Example**
```dart
class TransactionRepository implements Repository<Transaction> {
  final LocalDataSource _localDataSource;
  final CacheDataSource _cacheDataSource;
  
  TransactionRepository(this._localDataSource, this._cacheDataSource);
  
  @override
  Future<Transaction?> getById(String id) async {
    // Check cache first
    final cached = await _cacheDataSource.getTransaction(id);
    if (cached != null) return cached;
    
    // Fetch from database
    final transaction = await _localDataSource.getTransaction(id);
    
    // Update cache
    if (transaction != null) {
      await _cacheDataSource.cacheTransaction(transaction);
    }
    
    return transaction;
  }
  
  // Additional methods...
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getByCategory(String categoryId);
  Future<Map<String, double>> getExpensesByCategory();
}
```

---

### 2. Database Architecture

#### Schema Design

```mermaid
erDiagram
    USERS ||--o{ TRANSACTIONS : creates
    USERS ||--o{ BUDGET_GOALS : sets
    USERS ||--o{ RECURRING_TRANSACTIONS : creates
    USERS ||--o{ CATEGORIES : customizes
    
    CATEGORIES ||--o{ TRANSACTIONS : categorizes
    CATEGORIES ||--o{ BUDGET_GOALS : tracks
    CATEGORIES ||--o{ RECURRING_TRANSACTIONS : categorizes
    
    TRANSACTIONS ||--o{ TRANSACTION_TAGS : has
    TAGS ||--o{ TRANSACTION_TAGS : applied_to
    
    USERS {
        string id PK
        string full_name
        string email UK
        string currency
        string avatar_url
        datetime created_at
        datetime updated_at
    }
    
    TRANSACTIONS {
        string id PK
        string user_id FK
        string title
        real amount
        string currency_code
        real exchange_rate
        datetime date
        string category_id FK
        string type
        string description
        datetime created_at
    }
    
    BUDGET_GOALS {
        string id PK
        string user_id FK
        string name
        string category_id FK
        real target_amount
        real current_amount
        datetime month
        integer is_active
        datetime created_at
    }
    
    RECURRING_TRANSACTIONS {
        string id PK
        string user_id FK
        string title
        real amount
        string category_id FK
        string type
        string description
        string pattern
        datetime start_date
        datetime end_date
        datetime next_occurrence
        integer is_active
        datetime created_at
    }
    
    CATEGORIES {
        string id PK
        string user_id FK
        string name
        integer icon_code_point
        integer color_value
        string type
        real budget
        integer is_custom
        datetime created_at
    }
    
    TAGS {
        string id PK
        string user_id FK
        string name
        integer color_value
        datetime created_at
    }
    
    TRANSACTION_TAGS {
        string transaction_id FK
        string tag_id FK
    }
```

#### Database Helper Implementation

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget_app.db');
    return _database!;
  }
  
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }
  
  Future<void> _createDB(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        currency TEXT DEFAULT 'TND',
        avatar_url TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        currency_code TEXT DEFAULT 'TND',
        exchange_rate REAL DEFAULT 1.0,
        date TEXT NOT NULL,
        category_id TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Create indexes
    await db.execute('CREATE INDEX idx_transactions_user_id ON transactions(user_id)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transactions_category_id ON transactions(category_id)');
    
    // Additional tables...
  }
  
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    if (oldVersion < 2) {
      // Migration to version 2
    }
  }
}
```

---

### 3. Service Layer Architecture

```mermaid
graph TB
    subgraph "Service Layer"
        A[AuthService]
        B[TransactionService]
        C[BudgetService]
        D[AnalyticsService]
        E[NotificationService]
        F[ExportService]
        G[BackupService]
        H[CurrencyService]
        I[RecurringTransactionService]
    end
    
    subgraph "Repositories"
        J[UserRepository]
        K[TransactionRepository]
        L[BudgetRepository]
        M[CategoryRepository]
    end
    
    A --> J
    B --> K
    B --> M
    C --> L
    C --> M
    D --> K
    D --> L
    E --> K
    E --> L
    F --> K
    F --> L
    G --> J
    G --> K
    G --> L
    H --> K
    I --> K
```

#### Service Implementation Pattern

```dart
class TransactionService {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final NotificationService _notificationService;
  
  TransactionService(
    this._transactionRepository,
    this._categoryRepository,
    this._notificationService,
  );
  
  Future<Transaction> addTransaction({
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
    required CategoryType type,
    String? description,
  }) async {
    // Validate
    if (amount <= 0) throw ValidationException('Amount must be positive');
    
    // Create transaction
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
      type: type,
      description: description,
    );
    
    // Save to repository
    final saved = await _transactionRepository.create(transaction);
    
    // Check budget alerts
    await _checkBudgetAlerts(categoryId);
    
    return saved;
  }
  
  Future<void> _checkBudgetAlerts(String categoryId) async {
    // Logic to check if budget exceeded and send notification
  }
  
  // Additional methods...
}
```

---

### 4. State Management Architecture

```mermaid
graph TB
    subgraph "UI Layer"
        A[Widget]
    end
    
    subgraph "Provider Layer"
        B[TransactionProvider]
        C[State Object]
    end
    
    subgraph "Service Layer"
        D[TransactionService]
    end
    
    A -->|Reads State| B
    A -->|Dispatches Action| B
    B -->|Updates State| C
    B -->|Calls Service| D
    D -->|Returns Result| B
    B -->|Notifies| A
```

#### Provider Implementation

```dart
class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService;
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  TransactionProvider(this._transactionService);
  
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _transactions = await _transactionService.getAllTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addTra