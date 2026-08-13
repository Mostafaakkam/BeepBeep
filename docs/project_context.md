# Beep Beep - Project Context

## 1. Project Overview

Beep Beep is a mobile marketplace application designed for local commerce, starting with an initial launch in Aleppo, Syria. The application serves as a platform connecting local stores with customers, focusing initially on clothing stores with a scalable architecture designed to support future categories such as shoes, cosmetics, games, electronics, and more.

**Current Launch Location:** Aleppo, Syria  
**Initial Marketplace Scope:** Clothing stores  
**Long-term Expansion Direction:** Multi-category marketplace with potential for multi-city support  
**MVP Philosophy:** Feature-by-feature development approach with end-to-end implementation of each feature before moving to the next  
**Main Purpose:** Provide a fast, friendly, modern, and trustworthy mobile marketplace for local shopping in Syria

## 2. Product Scope

### Currently Supports
- Backend infrastructure with Node.js + Express + MySQL
- User authentication system (registration and login)
- JWT-based authentication with middleware
- Health check endpoint for API monitoring
- Flutter design system with reusable components
- Flutter Register screen with MVVM architecture
- Flutter Login screen with MVVM architecture
- Flutter Splash screen with animation
- Authentication state management
- Startup routing based on JWT token
- Centralized branding widget for logo replacement
- Flutter Home screen with MVVM architecture
- Bottom navigation structure for marketplace
- Professional marketplace UI with design system
- Complete authentication lifecycle with logout functionality
- Profile screen with logout action
- Stores API endpoint with active stores retrieval
- Flutter Stores screen with MVVM architecture
- Real store data integration in Home screen
- Products API endpoint with filtering and details
- Flutter Products screen with MVVM architecture
- Product Details screen with variants and images
- Store → Products navigation flow
- Shopping Cart API with authentication and variant support
- Flutter Cart screen with MVVM architecture
- Add to Cart functionality in Product Details
- Cart badge showing item count
- Cart persistence for authenticated users
- Orders API with transaction support and stock management
- Flutter Orders screen with MVVM architecture
- Checkout screen with delivery information and Cash on Delivery
- Order success screen with order confirmation
- Order details screen with full order information
- Order cancellation for pending orders
- Profile integration with My Orders access
- Search API with products and stores search
- Flutter Search screen with MVVM architecture
- Home screen search field integration
- Debounced search behavior
- Favorites API with user-specific product bookmarking
- Flutter Favorites screen with MVVM architecture
- Favorite button in Product Details with authentication check
- Profile integration with My Favorites access

### Planned (Not Yet Implemented)
- Order management dashboard for store owners
- Admin dashboard
- Advanced delivery pricing
- Payment gateway integration (Stripe, PayPal, etc.)
- User profile management beyond logout
- Address management
- Category browsing
- Store owner accounts
- Delivery driver integration
- Multi-city expansion

### Explicitly NOT Implemented Yet
- Product display screens
- Cart functionality
- Order management
- Profile management
- Admin features
- Any business features beyond authentication infrastructure

## 3. Technology Stack

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **MySQL** - Database (database name: `beep_beep`)
- **mysql2** - MySQL driver with promise support
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing
- **dotenv** - Environment variable management
- **cors** - Cross-Origin Resource Sharing
- **CommonJS** - Module system (require/module.exports)
- **Layered Architecture** - Route → Controller → Service → Repository → Database

### Flutter
- **Flutter** - Mobile UI framework
- **Dart** - Programming language
- **MVVM** - Architecture pattern (implemented for authentication)
- **google_fonts** - Typography (Poppins font family)
- **http** - HTTP client for API requests
- **shared_preferences** - Local data persistence
- **Material 3** - UI design system
- **cupertino_icons** - iOS-style icons

### Current State Management Solution
- ChangeNotifier with ChangeNotifierBuilder for reactive UI updates

### Current Networking Solution
- Custom API service layer with http package
- Centralized API configuration
- Exception handling for network, server, and API errors

## 4. Architecture

### Backend
The backend follows a strict layered architecture:

**Route Layer** (`backend/src/routes/`)
- Handles HTTP routing and endpoint definitions
- Currently implemented: health routes, auth routes

**Controller Layer** (`backend/src/controllers/`)
- Handles HTTP requests and responses
- Validates request data
- Calls service layer for business logic
- Currently implemented: health controller, auth controller

**Service Layer** (`backend/src/services/`)
- Contains business logic
- Validates business rules
- Coordinates between repositories
- Currently implemented: auth service

**Repository Layer** (`backend/src/repositories/`)
- Handles database access
- Executes SQL queries
- Returns data to service layer
- Currently implemented: user repository

**Database Layer** (`backend/src/config/`)
- MySQL connection pool configuration
- Database connection management
- Currently implemented: database configuration

**Middleware Layer** (`backend/src/middlewares/`)
- Request/response processing
- Authentication verification
- Currently implemented: JWT authentication middleware

**Configuration Layer** (`backend/src/config/`)
- Environment configuration
- Database configuration
- Currently implemented: database config

### Flutter
The Flutter app follows MVVM architecture:

**View Layer** (implemented for authentication)
- UI components and screens using design system
- User interaction handling
- Reactive UI updates with ChangeNotifierBuilder
- Currently implemented: Register screen

**ViewModel Layer** (implemented for authentication)
- Business logic for UI
- State management with ChangeNotifier
- Form validation
- Currently implemented: Register ViewModel

**Repository Layer** (implemented for authentication)
- Data access abstraction
- API service coordination
- Currently implemented: Auth Repository

**API Service Layer** (implemented)
- HTTP client configuration with http package
- API endpoint calls
- Response parsing and error handling
- Centralized configuration in ApiConfig

**Data Models** (implemented for authentication)
- Request/response models
- JSON serialization
- Currently implemented: RegisterRequest, RegisterResponse, UserData

## 5. Database

**Database Name:** `beep_beep`

### Current Tables

**users**
- Columns: id, name, phone, email, password, role, created_at, updated_at
- Primary Key: id
- Relationships: One user can have multiple addresses, one shopping cart, many orders, many favorite products
- Currently used by: authentication system

**stores**
- Columns: id, name, description, phone, address, logo, cover_image, status, created_at, updated_at
- Primary Key: id
- Relationships: One store contains many products
- Status: Schema defined, not yet used

**categories**
- Purpose: Store product categories with parent-child support
- Relationships: One category contains many products, can have child categories
- Status: Schema defined, not yet used

**products**
- Columns: id, name, description, store_id, category_id, created_at, updated_at
- Primary Key: id
- Foreign Keys: store_id, category_id
- Relationships: Belongs to one store, one category; has many images, many variants
- Status: Schema defined, not yet used

**product_images**
- Purpose: Store product image paths
- Relationships: Belongs to one product
- Status: Schema defined, not yet used

**product_variants**
- Purpose: Store product variations (color, size, price, stock)
- Relationships: Belongs to one product
- Status: Schema defined, not yet used

**carts**
- Purpose: Store user shopping carts
- Relationships: Belongs to one user, contains many cart items
- Status: Schema defined, not yet used

**cart_items**
- Purpose: Store products in shopping cart
- Relationships: Belongs to one cart, one product variant
- Status: Schema defined, not yet used

**orders**
- Columns: id, user_id, status, total_price, created_at, updated_at
- Primary Key: id
- Foreign Key: user_id
- Status values: pending, confirmed, shipping, delivered, cancelled
- Relationships: Belongs to one user, contains many order items
- Status: Schema defined, not yet used

**order_items**
- Purpose: Store snapshot of purchased products
- Relationships: Belongs to one order
- Status: Schema defined, not yet used

**addresses**
- Purpose: Store customer delivery addresses
- Relationships: Belongs to one user
- Status: Schema defined, not yet used

**favorites**
- Purpose: Store favorite products for users
- Relationships: Belongs to one user, one product
- Status: Schema defined, not yet used

### Important Constraints
- Integer primary keys
- Foreign keys maintain data integrity
- Image paths stored instead of image files
- Order history preserved even if products change

### Detailed Documentation
Complete database schema documentation is available in: `docs/database.md`

## 6. Backend API

### Implemented Endpoints

**GET /api/health**
- Purpose: Health check endpoint to verify API and database status
- Authentication: None required
- Request Body: None
- Response Structure:
  ```json
  {
    "success": true,
    "message": "Beep Beep API is running",
    "database": "connected"
  }
  ```
- Status Codes: 200 (success), 500 (database connection failed)

**POST /api/auth/register**
- Purpose: User registration
- Authentication: None required
- Request Body:
  ```json
  {
    "name": "John Doe",
    "phone": "+963900000000",
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- Response Structure (201):
  ```json
  {
    "success": true,
    "message": "User registered successfully",
    "data": {
      "id": 2,
      "name": "John Doe",
      "phone": "+963900000000",
      "email": "john@example.com",
      "role": "customer",
      "created_at": "2026-08-09T03:01:08.000Z"
    }
  }
  ```
- Status Codes: 201 (success), 400 (validation failed), 409 (duplicate email/phone), 500 (server error)

**POST /api/auth/login**
- Purpose: User login with JWT token generation
- Authentication: None required
- Request Body:
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```
- Response Structure (200):
  ```json
  {
    "success": true,
    "message": "Login successful",
    "data": {
      "user": {
        "id": 2,
        "name": "John Doe",
        "phone": "+963900000000",
        "email": "john@example.com",
        "role": "customer",
        "created_at": "2026-08-09T03:01:08.000Z"
      },
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
  ```
- Status Codes: 200 (success), 400 (validation failed), 401 (invalid credentials), 500 (server error)

**GET /api/auth/me**
- Purpose: Retrieve authenticated user information
- Authentication: Required (JWT Bearer token)
- Request Headers: `Authorization: Bearer <token>`
- Request Body: None
- Response Structure (200):
  ```json
  {
    "success": true,
    "message": "Authenticated user retrieved",
    "data": {
      "userId": 2,
      "role": "customer"
    }
  }
  ```
- Status Codes: 200 (success), 401 (authentication failed/invalid token/expired token), 500 (server error)

## 7. Authentication & Security

### Implemented

**Registration System**
- Endpoint: POST /api/auth/register
- Validation: Name (min 2 chars), phone (valid format), email (valid format), password (min 6 chars)
- Duplicate checking: Email and phone uniqueness validation
- Password hashing: bcrypt with salt rounds of 10
- Default role: 'customer'
- Password storage: Hashed only, never plain text

**Login System**
- Endpoint: POST /api/auth/login
- Email/password validation
- Generic error messages to prevent user enumeration
- Password verification: bcrypt.compare()
- JWT generation upon successful authentication

**JWT Authentication**
- Secret: From environment variable (JWT_SECRET)
- Algorithm: HS256
- Token expiration: 7 days
- Payload: Contains userId and role only (non-sensitive data)
- Verification: JWT authentication middleware
- Middleware: `authenticate` in `backend/src/middlewares/authMiddleware.js`

**JWT Authentication Middleware**
- Checks for Authorization header
- Requires "Bearer <token>" format
- Verifies JWT signature
- Validates token expiration
- Rejects invalid/tampered tokens
- Attaches authenticated user info to req.user
- Generic error messages for security

**Environment Variables**
- PORT: Server port (default: 3000)
- DB_HOST: Database host (default: localhost)
- DB_PORT: Database port (default: 3306)
- DB_USER: Database user (default: root)
- DB_PASSWORD: Database password
- DB_NAME: Database name (beep_beep)
- JWT_SECRET: JWT signing secret

**Security Considerations**
- Parameterized SQL queries prevent SQL injection
- bcrypt for secure password hashing
- JWT tokens contain minimal non-sensitive data
- Generic error messages prevent information leakage
- .env files protected by .gitignore
- No password/hash exposure in API responses
- Centralized error handling

**Known Limitations**
- No refresh token implementation
- No token revocation mechanism
- No rate limiting on authentication endpoints
- No account lockout after failed attempts
- No email/phone verification
- No password reset functionality

### Planned (Not Yet Implemented)
- Refresh tokens
- Token revocation
- Password reset
- Email verification
- Phone verification
- Rate limiting
- Account lockout
- Multi-factor authentication

## 8. Flutter Features

### Authentication
- **Status**: ✅ Completed (Register, Login, Splash screens implemented)
- **Related Files**: 
  - `mobail/lib/features/auth/presentation/pages/register_page.dart`
  - `mobail/lib/features/auth/presentation/pages/login_page.dart`
  - `mobail/lib/features/auth/presentation/pages/splash_page.dart`
  - `mobail/lib/features/auth/presentation/pages/authenticated_placeholder_page.dart`
  - `mobail/lib/features/auth/presentation/viewmodels/register_viewmodel.dart`
  - `mobail/lib/features/auth/presentation/viewmodels/login_viewmodel.dart`
  - `mobail/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`
  - `mobail/lib/data/repositories/auth_repository.dart`
  - `mobail/lib/data/services/api_service.dart`
  - `mobail/lib/data/services/token_storage.dart`
  - `mobail/lib/data/models/register_request.dart`
  - `mobail/lib/data/models/register_response.dart`
  - `mobail/lib/data/models/login_models.dart`
  - `mobail/lib/core/utils/validators.dart`
  - `mobail/lib/config/api_config.dart`
- **Implementation Notes**: Complete authentication flow with MVVM architecture, client-side validation, API integration, error handling, JWT token storage, splash screen with animation, authentication state management, startup routing

### Home
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Categories
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Stores
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Products
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Cart
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Orders
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Profile
- **Status**: Planned
- **Related Files**: None yet
- **Implementation Notes**: Not started

### Design System
- **Status**: Completed
- **Related Files**: 
  - `mobail/lib/core/constants/app_colors.dart`
  - `mobail/lib/core/constants/app_spacing.dart`
  - `mobail/lib/core/constants/app_border_radius.dart`
  - `mobail/lib/core/theme/app_text_theme.dart`
  - `mobail/lib/core/theme/app_theme.dart`
  - `mobail/lib/core/widgets/app_button.dart`
  - `mobail/lib/core/widgets/app_text_field.dart`
  - `mobail/lib/core/widgets/app_card.dart`
- **Implementation Notes**: Complete design system with reusable components ready for feature implementation

## 9. Design System

### Brand Colors
- **Primary Blue**: #2E54D9 (main action color)
- **Light Blue**: #6FC1E4 (secondary blue)
- **Accent Orange**: #FF9F3D (highlight/accent, not dominant)
- **Dark Navy**: #0F172A (primary dark)
- **Secondary Dark**: #334155 (secondary dark)
- **Gray**: #64748B (text gray)
- **Light Gray**: #E2E8F0 (border gray)
- **Background**: #F7FAFC (app background)
- **Success**: #10B981
- **Error**: #EF4444
- **Warning**: #F59E0B

### Typography
- **Font Family**: Poppins (via Google Fonts)
- **Display Sizes**: 32px, 28px, 24px (bold)
- **Headline Sizes**: 20px, 18px, 16px (semibold)
- **Body Sizes**: 16px, 14px, 12px (normal)
- **Label Sizes**: 14px, 12px, 10px (medium)
- **Hierarchy**: Consistent sizing and weights throughout

### Spacing System
- **Base Unit**: 8dp grid
- **Sizes**: 4px, 8px, 16px, 24px, 32px, 48px
- **Specific Spacing**: Button padding (16px), Card padding (16px), Input padding (12px), Screen padding (20px)

### Border Radius
- **Small**: 8px
- **Medium**: 12px (default for most components)
- **Large**: 16px
- **Extra Large**: 24px
- **Full**: 999px (circular)

### Elevation
- **Cards**: Subtle shadow (blur: 10, offset: 0,2)
- **Buttons**: Elevation 2
- **Consistent shadow implementation**

### Buttons
- **Primary**: Blue background, white text
- **Secondary**: Light blue background, white text
- **Outline**: Blue border, blue text
- **Text**: Blue text only
- **Features**: Loading state, full width option, icon support

### Input Fields
- **Style**: Filled white background with border
- **States**: Default, focused, error, disabled
- **Features**: Labels, hints, validation, icons, multi-line support

### Cards
- **Style**: White background with subtle elevation
- **Features**: Custom padding/margin, optional tap handling, custom colors, custom border radius

### Bottom Navigation
- **Planned Sections**: Home, Categories, Cart, Orders, Profile
- **Status**: Not yet implemented

### General UI Principles
- Clean white/light backgrounds
- Blue as main action color
- Orange as accent/highlight only
- Rounded cards and controls
- Moderate corner radius and subtle elevation
- Clear spacing based on 8dp grid
- No visual clutter
- Consistent icons
- Practical and easy navigation

### Visual Reference
Primary visual reference: `docs/design/beep_beep_design_system.png`

## 10. Project Structure

### Backend Structure
```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # MySQL connection pool configuration
│   ├── controllers/
│   │   ├── authController.js    # Authentication request handling
│   │   ├── healthController.js  # Health check endpoint
│   │   ├── storeController.js   # Store request handling
│   │   ├── productController.js # Product request handling
│   │   ├── cartController.js    # Cart request handling
│   │   ├── orderController.js   # Order request handling
│   │   ├── searchController.js  # Search request handling
│   │   └── favoriteController.js # Favorite request handling
│   ├── middlewares/
│   │   └── authMiddleware.js    # JWT authentication middleware
│   ├── repositories/
│   │   ├── userRepository.js     # User data access layer
│   │   ├── storeRepository.js   # Store data access layer
│   │   ├── productRepository.js # Product data access layer
│   │   ├── cartRepository.js    # Cart data access layer
│   │   ├── orderRepository.js   # Order data access layer
│   │   ├── searchRepository.js  # Search data access layer
│   │   └── favoriteRepository.js # Favorite data access layer
│   ├── routes/
│   │   ├── authRoutes.js        # Authentication routes
│   │   ├── healthRoutes.js      # Health check routes
│   │   ├── storeRoutes.js       # Store routes
│   │   ├── productRoutes.js     # Product routes
│   │   ├── cartRoutes.js        # Cart routes
│   │   ├── orderRoutes.js       # Order routes
│   │   ├── searchRoutes.js      # Search routes
│   │   └── favoriteRoutes.js    # Favorite routes
│   ├── services/
│   │   ├── authService.js       # Authentication business logic
│   │   ├── storeService.js      # Store business logic
│   │   ├── productService.js    # Product business logic
│   │   ├── cartService.js       # Cart business logic
│   │   ├── orderService.js      # Order business logic
│   │   ├── searchService.js     # Search business logic
│   │   └── favoriteService.js   # Favorite business logic
│   │   └── orderService.js      # Order business logic
│   ├── utils/                   # Utility functions (empty, ready for use)
│   ├── validators/              # Input validators (empty, ready for use)
│   ├── app.js                   # Express app configuration
│   └── server.js                # Server entry point
├── .env                         # Environment variables (not in Git)
├── .env.example                 # Environment variables template
├── package.json                 # Node.js dependencies
└── package-lock.json            # Dependency lock file
```

### Flutter Structure
```
mobail/
├── lib/
│   ├── core/
│   │   ├── branding/
│   │   │   ├── brand_logo.dart            # Centralized branding widget
│   │   │   └── branding.dart             # Barrel export
│   │   ├── constants/
│   │   │   ├── app_colors.dart           # Color palette
│   │   │   ├── app_spacing.dart          # Spacing constants
│   │   │   ├── app_border_radius.dart    # Border radius constants
│   │   │   └── app_constants.dart        # Barrel export
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # Complete ThemeData
│   │   │   └── app_text_theme.dart       # Typography system
│   │   ├── widgets/
│   │   │   ├── app_button.dart           # Reusable button component
│   │   │   ├── app_text_field.dart       # Reusable text field component
│   │   │   ├── app_card.dart             # Reusable card component
│   │   │   └── app_widgets.dart          # Barrel export
│   │   └── utils/
│   │       └── validators.dart            # Input validation utilities
│   ├── data/
│   │   ├── models/
│   │   │   ├── register_request.dart     # Registration request model
│   │   │   ├── register_response.dart    # Registration response model
│   │   │   ├── login_models.dart         # Login request/response models
│   │   │   ├── store_model.dart          # Store model
│   │   │   ├── product_model.dart       # Product model
│   │   │   ├── product_image_model.dart # Product image model
│   │   │   ├── product_variant_model.dart # Product variant model
│   │   │   ├── cart_model.dart            # Cart model
│   │   │   ├── cart_item_model.dart       # Cart item model
│   │   │   ├── cart_product_model.dart    # Cart product model
│   │   │   ├── order_model.dart           # Order model
│   │   │   ├── order_item_model.dart      # Order item model
│   │   │   └── models.dart               # Barrel export
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart      # Authentication repository
│   │   │   ├── store_repository.dart      # Store repository
│   │   │   ├── product_repository.dart    # Product repository
│   │   │   ├── cart_repository.dart       # Cart repository
│   │   │   ├── order_repository.dart      # Order repository
│   │   │   └── favorite_repository.dart   # Favorite repository
│   │   └── services/
│   │       ├── api_service.dart           # HTTP API service
│   │       └── token_storage.dart         # JWT token storage
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── register_page.dart # Register screen
│   │   │       │   ├── login_page.dart    # Login screen
│   │   │       │   └── splash_page.dart  # Splash screen
│   │   │       └── viewmodels/
│   │   │           ├── register_viewmodel.dart # Register ViewModel
│   │   │           ├── login_viewmodel.dart    # Login ViewModel
│   │   │           └── auth_viewmodel.dart    # Auth state ViewModel
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── home_page.dart    # Home screen
│   │   │       │   └── profile_page.dart # Profile screen with logout
│   │   │       └── viewmodels/
│   │   │           └── home_viewmodel.dart # Home ViewModel
│   │   └── stores/
│   │       └── presentation/
│   │           ├── pages/
│   │           │   └── stores_page.dart   # Stores screen
│   │           └── viewmodels/
│   │               └── store_viewmodel.dart # Store ViewModel
│   └── products/
│       └── presentation/
│           ├── pages/
│           │   ├── products_page.dart     # Products screen
│           │   └── product_details_page.dart # Product details screen
│           └── viewmodels/
│               ├── product_viewmodel.dart   # Product ViewModel
│               └── product_detail_viewmodel.dart # Product detail ViewModel
│   └── cart/
│       └── presentation/
│           ├── pages/
│           │   └── cart_page.dart           # Cart screen
│           └── viewmodels/
│               └── cart_viewmodel.dart       # Cart ViewModel
│   └── orders/
│       └── presentation/
│           ├── pages/
│           │   ├── checkout_page.dart       # Checkout screen
│           │   ├── order_success_page.dart  # Order success screen
│           │   ├── orders_page.dart          # Orders list screen
│           │   └── order_details_page.dart  # Order details screen
│           └── viewmodels/
│               └── order_viewmodel.dart      # Order ViewModel
│   └── search/
│       └── presentation/
│           ├── pages/
│           │   └── search_page.dart          # Search screen
│           └── viewmodels/
│               └── search_viewmodel.dart      # Search ViewModel
│   └── favorites/
│       └── presentation/
│           ├── pages/
│           │   └── favorites_page.dart        # Favorites screen
│           └── viewmodels/
│               └── favorite_viewmodel.dart     # Favorite ViewModel
│   ├── config/
│   │   └── api_config.dart               # API configuration
│   ├── design_system_demo.dart           # Design system demo (for reference)
│   └── main.dart                         # App entry point
├── test/
│   └── widget_test.dart                 # Widget tests
├── pubspec.yaml                          # Flutter dependencies
└── analysis_options.yaml                # Dart analysis options
```

### Documentation Structure
```
docs/
├── database.md                    # Complete database schema documentation
├── design/
│   ├── beep_beep_design.png       # Original design reference
│   └── beep_beep_design_system.png # Design system reference
└── project_context.md             # This file - project context
```

## 11. Git History / Milestones

### Development Milestones
- **Project Initialized**: Git repository created, basic project structure established
- **Database Schema Created**: Complete database schema designed and documented in `docs/database.md`
- **Backend Infrastructure Created**: Express server, MySQL connection, layered architecture structure
- **Health Check Implemented**: GET /api/health endpoint for API monitoring
- **Registration Implemented**: POST /api/auth/register with validation, password hashing, duplicate checking
- **Login Implemented**: POST /api/auth/login with JWT generation
- **JWT Middleware Implemented**: Authentication middleware for protected routes
- **Protected Endpoint Implemented**: GET /api/auth/me for testing authentication
- **Flutter Project Created**: Flutter mobile app project initialized
- **Design System Implemented**: Complete visual design system with reusable components
- **MVVM Architecture Implemented**: Complete MVVM structure with API service layer
- **Flutter Register Implemented**: Register screen with validation, API integration, error handling
- **Flutter Login Implemented**: Login screen with validation, API integration, JWT token storage
- **Flutter Splash Screen Implemented**: Splash screen with animation and authentication state checking
- **Authentication State Management Implemented**: AuthViewModel for managing authentication state
- **Startup Routing Implemented**: Navigation based on JWT token presence
- **Centralized Branding Structure Implemented**: BrandLogo widget for easy logo replacement
- **Flutter Home Screen Implemented**: Professional marketplace Home screen with MVVM architecture
- **Bottom Navigation Structure Implemented**: Navigation structure for marketplace features
- **Home UI Implemented**: Professional marketplace UI with design system components
- **Profile Screen Implemented**: Basic profile screen with logout functionality
- **Logout Functionality Implemented**: Complete authentication lifecycle with token clearing
- **Authentication Lifecycle Complete**: Register → Login → Home → Logout → Login
- **Stores API Implemented**: Backend endpoints for retrieving active stores
- **Stores Feature Implemented**: Flutter Stores screen with real data integration
- **Home Stores Integration**: Featured Stores section displays real store data
- **Products API Implemented**: Backend endpoints for product catalog with filtering
- **Products Feature Implemented**: Flutter Products screen with MVVM architecture
- **Product Details Implemented**: Product details screen with variants and images
- **Store → Products Flow**: Navigation from stores to their products
- **Cart API Implemented**: Backend endpoints for shopping cart with authentication
- **Cart Feature Implemented**: Flutter Cart screen with MVVM architecture
- **Add to Cart Implemented**: Functional Add to Cart in Product Details
- **Cart Badge Implemented**: Item count badge in navigation

## 12. Current Status

### Backend
- **Infrastructure**: ✅ Completed
- **Authentication**: ✅ Completed (register, login, JWT middleware)
- **Product API**: ❌ Not started
- **Store API**: ❌ Not started
- **Cart API**: ❌ Not started
- **Order API**: ❌ Not started
- **Admin Features**: ❌ Not started

### Flutter
- **Design System**: ✅ Completed
- **Authentication UI**: ✅ Completed (Register and Login screens)
- **Home Screen**: ❌ Not started
- **Categories Screen**: ❌ Not started
- **Product Screens**: ❌ Not started
- **Cart Screen**: ❌ Not started
- **Order Screens**: ❌ Not started
- **Profile Screen**: ❌ Not started
- **MVVM Architecture**: ✅ Completed (implemented for authentication)
- **API Service Layer**: ✅ Completed
- **State Management**: ✅ Completed (ChangeNotifier pattern)
- **JWT Token Storage**: ✅ Completed (SharedPreferences)

### Database
- **Initial Schema**: ✅ Completed
- **Migration System**: ❌ Not implemented
- **Seed Data**: ❌ Not implemented

### Security
- **Password Hashing**: ✅ Completed (bcrypt)
- **JWT Authentication**: ✅ Completed
- **SQL Injection Protection**: ✅ Completed (parameterized queries)
- **Input Validation**: ✅ Completed (authentication endpoints)
- **Rate Limiting**: ❌ Not implemented
- **HTTPS**: ❌ Not configured

## 13. Pending Work

### Immediate Next Steps
- Implement Order processing and management
- Create Checkout flow
- Add payment processing integration
- Implement authenticated API requests using stored JWT token for order operations

### Later Features
- Product catalog and browsing
- Store management
- Shopping cart functionality
- Order processing and management
- User profile management
- Favorites/wishlist functionality
- Category browsing
- Search functionality

### Long-Term Features
- Admin dashboard
- Store owner accounts
- Delivery driver integration
- Payment processing
- Multi-city expansion
- Advanced search and filtering
- Product reviews and ratings
- Notifications system
- Coupon/discount system

## 14. Important Technical Decisions

### Architecture Decisions
- **MVVM for Flutter**: Selected for clear separation of concerns and testability
- **Layered Architecture for Backend**: Selected for maintainability and scalability (Route → Controller → Service → Repository → Database)
- **MySQL for Database**: Selected for relational data requirements and transaction support
- **Feature-by-Feature Development**: Selected to ensure each feature is complete and tested before moving to the next
- **Start in Aleppo**: Strategic decision to focus on one city initially for MVP
- **Marketplace Category Expansion**: Database designed to support future categories without major restructuring

### Technology Decisions
- **Node.js + Express**: Chosen for backend due to ecosystem maturity and rapid development
- **Flutter for Mobile**: Selected for cross-platform mobile development with native performance
- **JWT for Authentication**: Stateless authentication suitable for mobile apps
- **bcrypt for Password Hashing**: Industry standard for secure password storage
- **Google Fonts for Typography**: Easy integration and performance for Poppins font
- **Material 3 Design System**: Modern, consistent UI components

### Security Decisions
- **Generic Error Messages**: Prevent user enumeration attacks
- **JWT Expiration (7 days)**: Balance between security and user experience
- **Parameterized Queries**: Prevent SQL injection attacks
- **Environment Variables**: Protect sensitive configuration data
- **.gitignore Protection**: Prevent committing secrets to version control

### Design Decisions
- **8dp Grid System**: Consistent spacing and alignment
- **Poppins Font Family**: Modern, friendly typography matching brand identity
- **Blue Primary Color**: Trustworthy and professional appearance
- **Orange Accent Color**: Friendly and energetic highlights
- **Reusable Components**: Maintain consistency and reduce code duplication

## 15. Known Issues / Technical Debt

### Known Issues
- None currently identified

### Technical Debt
- **Test Coverage**: Backend has no automated tests yet
- **API Documentation**: No Swagger/OpenAPI documentation yet
- **Error Logging**: Basic console.error logging, should be enhanced with proper logging system
- **Database Migrations**: No migration system implemented for schema changes

### Security Improvements Needed
- **Rate Limiting**: Not implemented on authentication endpoints
- **Account Lockout**: No protection against brute force attacks
- **Token Revocation**: No mechanism to revoke JWT tokens
- **Refresh Tokens**: No refresh token implementation
- **HTTPS**: Not configured (should be implemented for production)

### Items to Revisit Later
- **Database Connection Pool**: Current settings may need tuning based on production load
- **JWT Secret**: Should use stronger secret in production
- **Password Requirements**: Current minimum 6 characters, should consider stronger requirements
- **Input Validation**: Could be enhanced with more sophisticated validation library

## 16. Development Rules

### Architecture Rules
- **Backend**: Follow layered architecture (Route → Controller → Service → Repository → Database)
- **Flutter**: Follow MVVM architecture (View → ViewModel → Repository → API Service)
- **Separation of Concerns**: Each layer has specific responsibilities
- **Single Responsibility**: Each function/class should have one clear purpose

### Code Quality Rules
- **No SQL in Controllers**: All database access must go through repositories
- **No HTTP in Views**: All API calls must go through services/repositories
- **Business Logic in Services**: Controllers should handle HTTP, services handle business logic
- **Database Access in Repositories**: Only repositories should interact with the database
- **Reuse Design System**: Always use design system components instead of custom styling
- **No Hard-coded Secrets**: Use environment variables for all sensitive data
- **Git Protection**: Keep .env files out of Git using .gitignore

### Development Process Rules
- **Feature-by-Feature**: Complete one feature end-to-end before starting the next
- **Update Documentation**: Update `docs/project_context.md` after each completed feature
- **Test Before Commit**: Verify implementation before committing to Git
- **No Unrelated Changes**: Don't modify unrelated features without a clear reason
- **Security First**: Always consider security implications of changes

### Communication Rules
- **Clear Context**: This document serves as the primary context for development sessions
- **Accuracy Matters**: If documentation conflicts with actual code, trust the code and fix the documentation
- **No Assumptions**: Verify actual implementation rather than assuming based on documentation

### Maintenance Rules
- **Update Project Context**: After every completed feature, architectural change, database change, backend change, Flutter change, or important technical decision
- **Preserve History**: Don't delete useful historical information from this document
- **Be Specific**: Don't write vague summaries - be accurate and detailed
- **Truthful Reporting**: Never claim something was implemented unless it actually exists and was verified

---

**Document Maintenance**: This file must be updated after every significant project change to maintain its accuracy as the primary context document for future development sessions.

**Last Updated**: 2026-08-10 (Initial creation based on current project state)
