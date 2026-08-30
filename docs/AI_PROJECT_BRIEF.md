# Beep Beep - AI Project Brief

## Project Identity and Business Concept

**Beep Beep** is a mobile marketplace application designed for local commerce in Syria, starting with an initial launch in Aleppo. The application serves as a platform connecting local stores with customers, focusing initially on clothing stores with a scalable architecture designed to support future categories (shoes, cosmetics, games, electronics, etc.).

**Brand Identity:** Fast, friendly, modern, trustworthy, clean, and easy to use
**Mascot:** Fast, cartoon-style bird character
**Target Market:** Local marketplace for Aleppo, Syria
**Long-term Vision:** Multi-category marketplace with potential for multi-city support

## Current MVP Scope

**Implemented:**
- Backend infrastructure with complete authentication system
- Flutter design system with reusable components
- Flutter Register screen with MVVM architecture
- Flutter Login screen with MVVM architecture
- Flutter Splash screen with animation
- Authentication state management
- Startup routing based on JWT token
- JWT token storage with SharedPreferences
- Centralized branding widget for easy logo replacement
- User registration and login API endpoints
- JWT-based authentication with middleware
- Flutter Home screen with MVVM architecture
- Professional marketplace Home UI with design system
- Bottom navigation structure for marketplace features
- Profile screen with logout functionality
- Complete authentication lifecycle with logout
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
- Cart badge showing item count in navigation
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
- Address API with user-specific delivery address management
- Flutter Addresses screen with MVVM architecture
- Address form for adding/editing addresses
- Default address management with atomic transactions
- Checkout integration with saved address selection
- Profile integration with My Addresses access
- Categories API with product category browsing
- Flutter Categories screen with MVVM architecture
- Home screen categories integration with real data
- Products filtering by category
- Category → Products navigation flow
- Product Filtering & Sorting API (price range, in-stock, category/store, whitelisted sort options)
- Flutter product filter UI with bottom sheet, filter summary chips, and combined filters
- App-wide English/Arabic localization (RTL/LTR support, persisted language selector under Profile)
- Product Reviews & Ratings API with purchase-verified eligibility and ownership enforcement
- Flutter review submission/edit UI, rating summary, and review list on Product Details

**Not Yet Implemented:**
- Order management dashboard for store owners
- Admin dashboard
- Advanced delivery pricing
- Payment gateway integration (Stripe, PayPal, etc.)
- User profile management beyond logout and addresses
- Store management for store owners
- Any business features beyond authentication, Home, Stores, Products, Cart, Orders, Search, Favorites, Addresses, and Categories

## Technology Stack

### Backend
- **Node.js** + **Express** - Web framework and runtime
- **MySQL** - Database (database name: `beep_beep`)
- **mysql2** - MySQL driver with promise support
- **JWT** - JSON Web Tokens for authentication
- **bcrypt** - Password hashing (salt rounds: 10)
- **dotenv** - Environment variable management
- **cors** - Cross-Origin Resource Sharing
- **CommonJS** - Module system (require/module.exports)

### Flutter
- **Flutter** - Mobile UI framework
- **Dart** - Programming language
- **google_fonts** - Typography (Poppins font family)
- **http** - HTTP client for API requests
- **shared_preferences** - Local data persistence
- **Material 3** - UI design system
- **cupertino_icons** - iOS-style icons

### State Management
- **ChangeNotifier** pattern with ChangeNotifierBuilder for reactive UI updates

### Networking
- **Custom API service layer** with http package
- Centralized API configuration
- Exception handling for network, server, and API errors

## Flutter MVVM Architecture

**Architecture Pattern:** View → ViewModel → Repository → API Service → Backend

**View Layer** (`mobail/lib/features/auth/presentation/pages/`)
- UI components using design system
- User interaction handling
- Reactive UI updates with ChangeNotifierBuilder
- Currently implemented: Register screen

**ViewModel Layer** (`mobail/lib/features/auth/presentation/viewmodels/`)
- Business logic for UI
- State management with ChangeNotifier
- Form validation
- Currently implemented: Register ViewModel

**Repository Layer** (`mobail/lib/data/repositories/`)
- Data access abstraction
- API service coordination
- Currently implemented: Auth Repository

**API Service Layer** (`mobail/lib/data/services/`)
- HTTP client configuration with http package
- API endpoint calls
- Response parsing and error handling
- Centralized configuration in ApiConfig

**Data Models** (`mobail/lib/data/models/`)
- Request/response models
- JSON serialization
- Currently implemented: RegisterRequest, RegisterResponse, UserData

## Backend Layered Architecture

**Architecture Pattern:** Route → Controller → Service → Repository → Database

**Route Layer** (`backend/src/routes/`)
- HTTP routing and endpoint definitions
- Currently implemented: health routes, auth routes

**Controller Layer** (`backend/src/controllers/`)
- HTTP request/response handling
- Request data validation
- Service layer coordination
- Currently implemented: health controller, auth controller

**Service Layer** (`backend/src/services/`)
- Business logic
- Business rule validation
- Repository coordination
- Currently implemented: auth service

**Repository Layer** (`backend/src/repositories/`)
- Database access
- SQL query execution
- Data return to service layer
- Currently implemented: user repository

**Middleware Layer** (`backend/src/middlewares/`)
- Request/response processing
- Authentication verification
- Currently implemented: JWT authentication middleware

**Configuration Layer** (`backend/src/config/`)
- Environment configuration
- Database connection pool
- Currently implemented: database config

## Database Overview

**Database Name:** `beep_beep`

**Key Tables:**
- **users** - User accounts (id, name, phone, email, password, `role`: customer/store_owner/admin, created_at, updated_at) — role always re-verified server-side, never trusted from the JWT alone
- **stores** - Shop information (`owner_id`, nullable, at most one owner per store — added by migration 002)
- **categories** - Product categories with parent-child support
- **products** - Main product information
- **product_images** - Product image paths
- **product_variants** - Product variations (color, size, price, stock)
- **carts** - User shopping carts (`store_id`, nullable — set from the first item added; a cart holds items from one store at a time, added by migration 002)
- **cart_items** - Products in shopping carts
- **orders** - Customer orders (`store_id`, nullable on legacy rows — an order belongs to exactly one store, derived server-side, added by migration 002)
- **order_items** - Order history snapshots
- **addresses** - Customer delivery addresses
- **favorites** - User favorite products
- **reviews** - Product ratings/reviews (see `## Reviews & Ratings Implementation` below)

**Database Principles:**
- Integer primary keys
- Foreign keys for data integrity
- Image paths stored (not files)
- Order history preserved even if products change

**Detailed Documentation:** `docs/database.md`

## Authentication System

### Backend Authentication
**Registration:** POST /api/auth/register
- bcrypt password hashing (10 salt rounds)
- Email and phone uniqueness validation
- Default role: 'customer'
- Generic error messages prevent user enumeration

**Login:** POST /api/auth/login
- bcrypt.compare() for password verification
- JWT generation on success
- 7-day token expiration
- JWT payload: userId and role only (non-sensitive)

**JWT Middleware:** GET /api/auth/me
- Authorization header: "Bearer <token>"
- Token signature verification
- Expiration validation
- Attaches user info to req.user
- Generic error messages for security

### Flutter Authentication
**Register Screen:** Fully implemented
- MVVM architecture
- Client-side validation
- API integration
- Error handling
- Design system components
- Loading states
- Success/error feedback

**Login Screen:** Fully implemented
- MVVM architecture
- Client-side validation
- API integration
- JWT token storage
- Error handling
- Design system components
- Loading states
- Success/error feedback
- Navigation to Register screen

**Splash Screen:** Fully implemented
- Animation (logo slides from left to right)
- Authentication state checking
- Startup routing based on JWT token
- Design system compliance
- Clean startup experience

**Authentication State Management:** Fully implemented
- AuthViewModel for state management
- JWT token checking
- User info retrieval
- Logout preparation
- Error-safe token storage access

## Implemented API Endpoints

**GET /api/health**
- Purpose: Health check for API and database status
- Authentication: None required
- Response: API status and database connection status

**POST /api/auth/register**
- Purpose: User registration
- Authentication: None required
- Request: name, phone, email, password
- Response: User data (without password)
- Status codes: 201 (success), 400 (validation), 409 (duplicate), 500 (error)

**POST /api/auth/login**
- Purpose: User login with JWT
- Authentication: None required
- Request: email, password
- Response: User data and JWT token
- Status codes: 200 (success), 400 (validation), 401 (invalid credentials), 500 (error)

**GET /api/auth/me**
- Purpose: Retrieve authenticated user info
- Authentication: Required (JWT Bearer token)
- Response: userId and role
- Status codes: 200 (success), 401 (auth failed), 500 (error)

## Flutter Design System

**Brand Colors:**
- Primary Blue: #2E54D9 (main action color)
- Light Blue: #6FC1E4 (secondary blue)
- Accent Orange: #FF9F3D (highlight/accent)
- Dark Navy: #0F172A (primary dark)
- Secondary Dark: #334155 (secondary dark)
- Gray: #64748B (text gray)
- Light Gray: #E2E8F0 (border gray)
- Background: #F7FAFC (app background)

**Typography:**
- Font Family: Poppins (via Google Fonts)
- Display sizes: 32px, 28px, 24px (bold)
- Headline sizes: 20px, 18px, 16px (semibold)
- Body sizes: 16px, 14px, 12px (normal)
- Label sizes: 14px, 12px, 10px (medium)

**Spacing System:**
- Base unit: 8dp grid
- Sizes: 4px, 8px, 16px, 24px, 32px, 48px

**Border Radius:**
- Small: 8px, Medium: 12px (default), Large: 16px, Extra Large: 24px

**Reusable Components:**
- **AppButton**: Primary, secondary, outline, text variants with loading state
- **AppTextField**: Labels, hints, validation, icons, multi-line support
- **AppCard**: Custom padding/margin, optional tap handling, custom colors

**Visual Reference:** `docs/design/beep_beep_design_system.png`

## Register Feature Implementation

**Architecture:** Complete MVVM implementation
- View: RegisterPage with design system components
- ViewModel: RegisterViewModel with state management
- Repository: AuthRepository for data access
- API Service: ApiService for HTTP requests
- Models: RegisterRequest, RegisterResponse, UserData

**UI Features:**
- Beep Beep branding with logo/icon
- Name, phone, email, password, confirm password fields
- Password visibility toggles
- Register button with loading state
- Login link (navigates to Login screen)
- Success dialog on registration
- Error snackbar for failures
- Clean, mobile-friendly layout

**Validation:**
- Name: Required, minimum 2 characters
- Phone: Required, valid phone format (10+ digits, optional +)
- Email: Required, valid email format
- Password: Required, minimum 6 characters
- Confirm password: Required, must match password
- Real-time validation as user types

**Error Handling:**
- Network errors (connection issues)
- Server errors (500 status)
- Validation errors (400 status)
- Duplicate email/phone (409 status)
- Timeout errors
- User-friendly error messages

**Files:**
- `mobail/lib/features/auth/presentation/pages/register_page.dart`
- `mobail/lib/features/auth/presentation/viewmodels/register_viewmodel.dart`
- `mobail/lib/data/repositories/auth_repository.dart`
- `mobail/lib/data/services/api_service.dart`
- `mobail/lib/data/models/register_request.dart`
- `mobail/lib/data/models/register_response.dart`
- `mobail/lib/core/utils/validators.dart`
- `mobail/lib/config/api_config.dart`

## Login Feature Implementation

**Architecture:** Complete MVVM implementation
- View: LoginPage with design system components
- ViewModel: LoginViewModel with state management
- Repository: AuthRepository extended with login method
- API Service: ApiService for HTTP requests
- Models: LoginRequest, LoginResponse, LoginData
- Token Storage: TokenStorage with SharedPreferences

**UI Features:**
- Beep Beep branding with logo/icon
- Email field with validation
- Password field with visibility toggle
- Login button with loading state
- Register link ("Don't have an account? Register")
- Success dialog on login
- Error snackbar for failures
- Clean, mobile-friendly layout
- Navigation to Register screen

**Validation:**
- Email: Required, valid email format
- Password: Required, minimum 6 characters
- Real-time validation as user types
- Prevents API calls if validation fails

**Error Handling:**
- Invalid email format
- Missing password
- Invalid credentials (401) - generic message
- Network errors (connection issues)
- Server errors (500 status)
- Timeout errors
- User-friendly error messages

**JWT Token Storage:**
- Token stored using SharedPreferences
- User info stored (userId, role, name)
- Token retrievable for authenticated requests
- Support for future logout functionality
- Password never stored

**Files:**
- `mobail/lib/features/auth/presentation/pages/login_page.dart`
- `mobail/lib/features/auth/presentation/viewmodels/login_viewmodel.dart`
- `mobail/lib/data/repositories/auth_repository.dart` (extended)
- `mobail/lib/data/services/token_storage.dart` (new)
- `mobail/lib/data/models/login_models.dart` (new)
- `mobail/lib/core/utils/validators.dart` (reused)
- `mobail/lib/config/api_config.dart` (reused)

## Splash Screen and Authentication State Implementation

**Architecture:** Complete state management and startup routing
- View: SplashPage with animation
- ViewModel: AuthViewModel for authentication state
- Token Storage: TokenStorage for JWT persistence
- Navigation: Route replacement based on auth state

**Splash Screen Features:**
- Beep Beep branding with shopping bag icon (120x120, primary blue background)
- Logo animation: slides from left to right (1.5 seconds, easeInOut curve)
- App name and tagline display
- Background: Beep Beep background color
- Shadow effects on logo
- Smooth, lightweight animation using Flutter built-in APIs
- Auto-navigation after animation completion
- Removed from navigation stack after routing

**Authentication State Management:**
- AuthViewModel with three states: checking, authenticated, unauthenticated
- JWT token checking using existing TokenStorage
- User info retrieval (userId, role, name)
- Error-safe token storage access (treats errors as unauthenticated)
- Logout preparation method
- State exposed via ChangeNotifier pattern
- Reuses existing TokenStorage without modification

**Startup Routing:**
- App starts with SplashPage
- Animation plays while checking authentication
- If JWT exists → navigates to authenticated destination
- If no JWT → navigates to LoginPage
- Uses pushReplacement to remove Splash from navigation stack
- Clean navigation structure
- No return to Splash on back button

**Design System Compliance:**
- Uses AppColors for brand colors
- Uses AppSpacing for consistent spacing
- Uses AppTheme for typography
- Matches existing visual identity
- No new design system elements added

**Files:**
- `mobail/lib/features/auth/presentation/pages/splash_page.dart`
- `mobail/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart`
- `mobail/lib/data/services/token_storage.dart` (reused)
- `mobail/lib/main.dart` (updated to start with SplashPage)

## Current Project Status

### Backend
- **Infrastructure:** ✅ Completed
- **Authentication:** ✅ Completed (register, login, JWT middleware, protected endpoint)
- **Product API:** ❌ Not started
- **Store API:** ❌ Not started
- **Cart API:** ❌ Not started
- **Order API:** ❌ Not started
- **Admin Features:** ❌ Not started

### Flutter
- **Design System:** ✅ Completed
- **Authentication UI:** ✅ Completed (Register, Login, and Splash screens)
- **Authentication State:** ✅ Completed (AuthViewModel)
- **Startup Routing:** ✅ Completed (based on JWT token)
- **Home Screen:** ❌ Not started
- **Categories Screen:** ❌ Not started
- **Product Screens:** ❌ Not started
- **Cart Screen:** ❌ Not started
- **Order Screens:** ❌ Not started
- **Profile Screen:** ❌ Not started
- **MVVM Architecture:** ✅ Completed (implemented for authentication)
- **API Service Layer:** ✅ Completed
- **State Management:** ✅ Completed (ChangeNotifier pattern)
- **JWT Token Storage:** ✅ Completed (SharedPreferences)
- **Localization (English/Arabic):** ✅ Implemented across all screens (see "Localization Implementation" section below); statically verified, on-device `flutter analyze`/build not run this session

Note: the "Home Screen" through "Profile Screen" rows above predate this update and are stale — those screens are in fact implemented (see `docs/project_context.md` §12 for current status). This section is left otherwise unchanged per task scope; only the Localization row was added.

### Database
- **Initial Schema:** ✅ Completed
- **Migration System:** ❌ Not implemented
- **Seed Data:** ❌ Not implemented

### Security
- **Password Hashing:** ✅ Completed (bcrypt)
- **JWT Authentication:** ✅ Completed
- **SQL Injection Protection:** ✅ Completed (parameterized queries)
- **Input Validation:** ✅ Completed (authentication endpoints)
- **Rate Limiting:** ❌ Not implemented
- **HTTPS:** ❌ Not configured

## Branding Structure

**Centralized Branding Widget:**
- `BrandLogo` widget in `mobail/lib/core/branding/brand_logo.dart`
- Used across all authentication screens (Splash, Login, Register, AuthenticatedPlaceholder)
- Currently uses neutral placeholder icon (Icons.blur_circular)
- Structured to support future ostrich logo replacement
- Configurable size, background color, and visibility
- Single point of change for logo updates

**Future Logo Replacement:**
- When ostrich assets are provided, only `BrandLogo._buildLogoContent()` needs modification
- Can support SVG assets, custom illustrations, or animated mascots
- `BrandConfig` class includes placeholder asset paths for future use
- No changes required to UI screens using the widget

**Current Usage:**
- SplashPage: BrandLogo (size: 120)
- LoginPage: BrandLogo (size: 80)
- RegisterPage: BrandLogo (size: 80)
- AuthenticatedPlaceholderPage: BrandLogo (size: 100)

**Design Compliance:**
- Maintains consistent brand presence across screens
- Follows existing design system colors and spacing
- Placeholder is neutral (not store/shopping icon)
- Ready for ostrich character integration

## Home Screen Implementation

**Architecture:**
- MVVM pattern with HomeViewModel
- Reuses existing AuthViewModel for user data
- Follows existing design system components
- Professional marketplace UI structure

**Features:**
- User greeting with stored name from TokenStorage
- Search field UI for future search functionality
- Categories section with horizontal scrolling
- Featured stores section (placeholder for future content)
- Bottom navigation with Home, Search, Cart, and Profile tabs
- Uses BrandLogo widget for consistent branding
- Responsive design with proper spacing and colors

**Navigation:**
- Splash → Home (for authenticated users)
- Login → Home (after successful authentication)
- Bottom navigation tabs (functional structure for future features)

**Temporary Elements:**
- Mock category data (Clothing, Shoes, Cosmetics, Games, Electronics, More)
- Placeholder "Coming Soon" content for featured stores
- Non-functional bottom navigation tabs (ready for future implementation)

**Design System Compliance:**
- Uses AppColors, AppSpacing, AppBorderRadius
- Reuses AppTextField, AppCard, BrandLogo
- Maintains visual consistency with authentication screens
- Follows Material 3 design principles

## Logout Implementation

**Architecture:**
- Reuses existing AuthViewModel.logout() method
- TokenStorage.clearAuth() removes all authentication data
- Profile screen exposes logout action
- Navigation uses pushAndRemoveUntil to clear back stack

**Token Clearing Behavior:**
- Removes JWT token from SharedPreferences
- Removes user ID, role, and name from storage
- Updates AuthViewModel state to unauthenticated
- Safely handles storage errors with fallback state update

**Navigation Flow:**
- Profile → Logout → LoginPage (with stack clearing)
- After logout, back button cannot return to authenticated screens
- App restart after logout → Splash → LoginPage

**UI Implementation:**
- Profile tab in bottom navigation leads to ProfilePage
- ProfilePage displays user name and role from TokenStorage
- Logout button with loading state and error handling
- Generic error message on logout failure
- Placeholder for future profile features

**Security:**
- JWT completely removed from local storage
- User information cleared from TokenStorage
- AuthViewModel state updated to unauthenticated
- No JWT exposure in logs or UI
- Server-side token revocation not implemented yet

**Error Handling:**
- Graceful handling of TokenStorage errors
- Generic user-friendly error messages
- No technical exception exposure
- State updates even if storage operations fail

## Stores Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for store data
- Service: Business logic for store operations
- Controller: HTTP request/response handling
- Routes: Public endpoints for store browsing

**API Endpoint:**
- GET /api/stores - Returns all active stores
- GET /api/stores/:id - Returns specific store by ID
- No authentication required for public browsing
- Returns customer-facing data only (no sensitive fields)

**Database Schema Usage:**
- Reuses existing stores table
- Filters by status = 'active'
- Returns: id, name, description, logo, cover_image, address, phone, timestamps
- Customer-safe data exposure

**Flutter Architecture:**
- Store model matching backend response structure
- StoreRepository for API communication
- StoreViewModel with ChangeNotifier state management
- StoresPage with proper loading/error/empty states
- MVVM pattern maintained throughout

**Home Integration:**
- Featured Stores section uses real store data
- Displays up to 3 featured stores horizontally
- "See all" link navigates to complete Stores screen
- Bottom navigation: Home → Stores tab
- Replaces temporary "Coming Soon" content

**UI Implementation:**
- Stores list with store cards
- Store cards display logo, name, address, description
- Loading state with progress indicator
- Empty state with "No stores available" message
- Error state with retry button
- Responsive design with proper spacing

**Error Handling:**
- Network failure handling
- Timeout handling
- Server error handling
- Malformed response handling
- Empty store list handling
- User-friendly error messages

## Products Catalog Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for product data with joins
- Service: Business logic for product operations
- Controller: HTTP request/response handling
- Routes: Public endpoints for product browsing

**API Endpoints:**
- GET /api/products - Returns all products from active stores
- GET /api/products?store_id=:id - Returns products filtered by store
- GET /api/products/:id - Returns single product with images and variants
- No authentication required for public browsing
- Returns customer-facing data only

**Database Relationships Used:**
- products → belongs to store
- product_images → belongs to product
- product_variants → belongs to product
- JOIN with stores to get store information
- Filters by active store status

**Flutter Architecture:**
- Product, ProductImage, ProductVariant models matching backend response
- ProductRepository for API communication
- ProductViewModel with ChangeNotifier for product list
- ProductDetailViewModel for single product details
- ProductsPage with proper loading/error/empty states
- ProductDetailsPage with variants and images
- MVVM pattern maintained throughout

**Store → Products Flow:**
- Stores → Product cards navigate to ProductsPage with store filter
- Home → Featured stores navigate to ProductsPage with store filter
- Products tab → Shows all products from all stores
- Product cards navigate to ProductDetailsPage

**UI Implementation:**
- Products grid with product cards
- Product cards display image, name, store, price
- Product details with image gallery
- Product information and store details
- Available variants with color, size, price, stock
- Loading state with progress indicator
- Empty state with "No products available" message
- Error state with retry button
- Disabled "Add to Cart" button for future implementation

**Error Handling:**
- Network failure handling
- Timeout handling
- Server error handling
- Malformed response handling
- Empty product list handling
- Image loading failures with fallback
- User-friendly error messages

## Shopping Cart Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for cart data with user ownership verification
- Service: Business logic for cart operations with validation and stock checks
- Controller: HTTP request/response handling with authentication requirements
- Routes: Protected cart endpoints requiring JWT authentication

**API Endpoints:**
- GET /api/cart - Returns authenticated user's cart with items and totals
- POST /api/cart/items - Adds item to authenticated user's cart
- PATCH /api/cart/items/:id - Updates item quantity
- DELETE /api/cart/items/:id - Removes cart item
- DELETE /api/cart - Clears authenticated user's cart
- All endpoints require JWT authentication via middleware

**Database Relationships Used:**
- carts → belongs to user
- cart_items → belongs to cart and product variant
- product_variants → belongs to product
- products → belongs to store
- User ownership verification at database level
- No cross-user cart access possible

**Cart Business Rules:**
- Product must exist and be available
- Variant must exist and belong to selected product
- Variant must have sufficient stock
- Quantity must be positive integer
- Adding same product+variant updates quantity instead of duplicating
- Quantity cannot exceed available stock
- User can only access their own cart
- Backend determines prices from database (not from client)
- Cart totals calculated on backend

**Flutter Architecture:**
- Cart, CartItem, CartProduct models matching backend response
- CartRepository for API communication with JWT authentication
- CartViewModel with ChangeNotifier for cart state management
- CartPage with proper loading/error/empty states
- Integration with Product Details for Add to Cart
- Cart badge in navigation showing item count
- MVVM pattern maintained throughout

**Authentication & Security:**
- All cart API requests require JWT authentication
- Backend uses req.user.userId from JWT middleware
- Repository verifies user ownership of cart items
- Users cannot access or modify other users' carts
- Prices calculated on backend, cannot be manipulated by client
- Stock validation prevents overselling

**Product Details Integration:**
- Variant selection required for products with variants
- Stock availability checked before adding
- Loading state during add to cart operation
- Success/error messages shown to user
- Cart state refreshed after successful addition
- Disabled "Add to Cart" for out-of-stock variants

**Cart UI Implementation:**
- Cart item list with product images and variant info
- Quantity controls (+/-) for each item
- Remove button for each item
- Cart subtotal and total calculation
- Empty cart state with navigation to products
- Loading state with progress indicator
- Error state with retry button
- Clear cart functionality
- Disabled "Checkout" button for future implementation

**Navigation Flow:**
- Home → Products → Product Details → Add to Cart → Cart
- Home → Cart (via navigation)
- Cart badge shows item count in navigation
- Cart persists for authenticated user across sessions

**Error Handling:**
- Unauthenticated user access rejection
- Expired JWT handling
- Network failure handling
- Timeout handling
- Server error handling
- Invalid product/variant rejection
- Insufficient stock rejection
- Invalid quantity rejection
- User-friendly error messages without technical details

## Orders Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries with MySQL transactions for atomicity
- Service: Business logic for order operations with validation and stock management
- Controller: HTTP request/response handling with authentication requirements
- Routes: Protected order endpoints requiring JWT authentication

**API Endpoints:**
- POST /api/orders - Creates order from authenticated user's cart
- GET /api/orders - Returns authenticated user's orders
- GET /api/orders/:id - Returns complete order details
- PATCH /api/orders/:id/cancel - Cancels pending order
- All endpoints require JWT authentication via middleware

**MVP Payment Method:**
- Payment method: cash_on_delivery only
- Payment status: pending (for future online payment support)
- No payment gateway integration in MVP
- Architecture designed to support future payment methods

**Database Relationships Used:**
- orders → belongs to user
- order_items → belongs to order
- order_items → belongs to product variant
- products → belongs to store
- User ownership verification at database level
- Transaction support for atomic order creation

**Order Business Rules:**
- Order creation requires non-empty cart
- Product and variant validation from database
- Stock availability verification
- Quantity validation
- Prices calculated from database (not from client)
- Delivery fee: 5.00 (configurable for future enhancement)
- Total = subtotal + delivery_fee
- Order snapshot: product name, variant info, prices preserved at order time
- Transaction rollback on any failure
- Stock decreased only on successful order creation
- Cart cleared only on successful order creation

**Transaction Strategy:**
- MySQL transaction ensures atomicity
- Steps: Verify user → Read cart → Validate stock → Calculate prices → Create order → Create order items → Decrease stock → Clear cart → Commit
- Rollback on any step failure
- Prevents partial orders, stock inconsistencies, or cart sync issues

**Order Status System:**
- pending: Initial status after customer places order
- confirmed: Order confirmed by store/admin
- preparing: Order being prepared
- shipped: Order shipped for delivery
- delivered: Order delivered successfully
- cancelled: Order cancelled by customer (only for pending orders)
- Customers can only cancel pending orders
- Stock restored on cancellation

**Flutter Architecture:**
- Order, OrderItem models matching backend response
- OrderRepository for API communication with JWT authentication
- OrderViewModel with ChangeNotifier for order state management
- CheckoutPage with delivery information form and order summary
- OrderSuccessPage with order confirmation and navigation
- OrdersPage with order list and status chips
- OrderDetailsPage with complete order information
- MVVM pattern maintained throughout

**Checkout Implementation:**
- Delivery information form (name, phone, address)
- Validation: name length, phone format, address length
- Order summary with items, subtotal, delivery fee, total
- Payment method display: Cash on Delivery only
- Clear payment timing information (pay on delivery)
- Loading state during order placement
- Navigation to success screen on completion

**Order Success Screen:**
- Success message and icon
- Order number display
- Payment method: Cash on Delivery
- Total amount
- "View Order" action
- "Continue Shopping" action

**My Orders Implementation:**
- Order list with status chips
- Status color coding (pending=warning, confirmed/preparing=primary, shipped=primary, delivered=success, cancelled=error)
- Order cards with order number, date, status, payment method, total
- Navigation to order details
- Loading, empty, error, and retry states

**Order Details Implementation:**
- Complete order information display
- Order number, status, date
- Customer information (name, phone, address)
- Payment information (method, status)
- Order items with preserved snapshot data
- Order totals (subtotal, delivery fee, total)
- Cancel button for pending orders
- Confirmation dialog for cancellation
- Stock restoration on cancellation

**Cart Integration:**
- Cart page "Checkout" button navigates to CheckoutPage
- Checkout only allowed when cart is not empty
- Cart automatically cleared after successful order creation
- Cart badge updates after order creation

**Profile Integration:**
- "My Orders" button in Profile page
- Navigation to OrdersPage
- Access to order history

**Security & Price Protection:**
- All order API requests require JWT authentication
- Backend uses req.user.userId from JWT middleware
- Repository verifies user ownership of orders
- Users cannot access or modify other users' orders
- Prices calculated from database, cannot be manipulated by client
- Stock validation prevents overselling
- Transaction rollback prevents partial order creation
- SQL queries are parameterized

**Error Handling:**
- Unauthenticated user access rejection
- Empty cart rejection
- Invalid delivery information rejection
- Insufficient stock rejection
- Invalid phone number format rejection
- Address length validation
- Transaction failure with rollback
- User-friendly error messages without technical details

**Future Payment Architecture:**
- payment_status field designed for future online payments
- Can support: paid, failed, refunded
- payment_method field can support multiple methods
- Delivery fee structure ready for store-specific or distance-based pricing
- No payment gateway integration in MVP (intentionally deferred)

## Search Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for search
- Service: Business logic for search validation
- Controller: HTTP request/response handling
- Routes: Public search endpoint (no authentication required for marketplace browsing)

**API Endpoint:**
- GET /api/search?q=<query> - Unified search for products and stores
- Public access (no JWT required for marketplace browsing)
- Response format: { "success": true, "data": { "products": [...], "stores": [...] } }
- Search fields: product name, product description, store name, store description
- Only returns active stores and their products
- Limited to 20 results per category for performance

**Database Queries Used:**
- Products search: JOIN with stores table, filter by active status, search in name and description
- Stores search: Filter by active status, search in name and description
- Parameterized queries to prevent SQL injection
- No GROUP BY on products to avoid compatibility issues
- Uses existing database structure without schema changes

**Search Behavior:**
- Minimum query length: 2 characters
- Empty/short queries return empty results
- Search is case-insensitive (LIKE with % wildcards)
- Results limited to 20 items per category
- Sorted by creation date (newest first)

**Flutter Architecture:**
- SearchViewModel with ChangeNotifier for search state management
- SearchRepository for API communication
- SearchPage with proper UI states
- MVVM pattern maintained throughout
- No dedicated models needed (uses dynamic response data)

**Debounce Implementation:**
- 500ms debounce timer to prevent API calls on every keystroke
- Cancels previous timer when user continues typing
- Performs search only after typing stops
- Clears results when query is cleared
- Prevents duplicate API requests

**Search UI Implementation:**
- Search input field at top with search icon
- Clear button when text exists
- Loading state with "Searching..." message
- Product results section with product cards
- Store results section with store cards
- Empty state when no query entered
- No results state when search returns empty
- Error state with retry button
- Clean responsive layout using existing Design System

**Search Result Navigation:**
- Product result → ProductDetailsPage
- Store result → ProductsPage filtered by store
- Reuses existing navigation logic
- No duplicate pages created

**Home Screen Integration:**
- Search field in HomePage is now functional
- Tapping search field navigates to SearchPage
- Search field shows as clickable with proper styling
- No redesign of HomePage needed

**Error Handling:**
- Network failure handling
- Server error handling
- User-friendly error messages
- Retry action for failed searches
- No sensitive database errors exposed

**Security:**
- Public access (no JWT required for marketplace browsing)
- Parameterized SQL queries prevent SQL injection
- No sensitive user information exposed
- Only returns active/available products and stores
- No raw SQL concatenation

**Performance:**
- Debounce prevents unnecessary API calls
- Result limits prevent large result sets
- Efficient database queries
- Proper disposal of controllers and timers
- No unnecessary rebuilds

**Testing:**
- flutter analyze: No issues found
- Backend starts successfully
- GET /api/search?q=t returns empty results (query too short)
- GET /api/search?q=test returns empty results (no matching data)
- Search with invalid input handled gracefully
- Database queries compatible with existing schema
- Navigation from Home to Search works
- Navigation from Search results works
- Empty/short query handling works
- Debounce behavior works
- All existing features still functional

**Database Changes:**
- No schema changes required
- Uses existing tables: products, stores
- Uses existing status fields
- No new tables or columns added

## Favorites Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for favorites
- Service: Business logic for favorite validation and user ownership
- Controller: HTTP request/response handling
- Routes: Authenticated favorite endpoints (JWT required)

**API Endpoints:**
- GET /api/favorites - Returns authenticated user's favorite products
- POST /api/favorites - Adds a product to favorites (requires product_id)
- DELETE /api/favorites/:productId - Removes a product from favorites
- GET /api/favorites/check/:productId - Checks if product is favorited
- All endpoints require JWT authentication
- User identity extracted from req.user.userId (never from client)

**Database Schema Used:**
- favorites table (existing) with user_id, product_id, created_at
- Products must exist and be from active stores
- User can favorite a product only once (enforced by database logic)
- User can only remove their own favorites
- Foreign key relationships: favorites → users, favorites → products

**Favorite Business Rules:**
- User must be authenticated (JWT required)
- Product must exist
- Product must be from active store
- Duplicate favorites prevented (checked before insertion)
- A user can favorite the same product only once
- User can remove only their own favorites
- Deleting non-existing favorite handled gracefully
- SQL queries parameterized to prevent injection
- No sensitive database errors exposed to users

**Database Queries Used:**
- findByUserId: JOIN favorites with products and stores, filter by active stores
- findByUserAndProduct: Check if favorite exists for user and product
- addFavorite: Insert new favorite with current timestamp
- removeFavorite: Delete favorite by user_id and product_id
- checkFavorite: Simple existence check
- All queries use parameterized placeholders
- No raw SQL concatenation

**Flutter Architecture:**
- FavoriteViewModel with ChangeNotifier for favorite state management
- FavoriteRepository for API communication with JWT authentication
- FavoritesPage with proper UI states
- MVVM pattern maintained throughout
- Uses existing authentication check via AuthViewModel
- No dedicated models needed (uses dynamic response data)

**Favorite State Management:**
- States: initial, loading, success, error
- Operations: loading favorites, adding favorite, removing favorite, checking favorite state
- Prevents duplicate operations with isOperationInProgress flag
- Favorite product IDs cached locally for efficient checking
- Proper disposal of ViewModels and resources

**Product Details Integration:**
- Favorite button added to ProductDetailsPage header
- Heart icon: outline = not favorite, filled = favorite
- Authentication check before allowing favorite action
- Shows login prompt if user not authenticated
- Toggles favorite state with visual feedback
- Error handling with user-friendly SnackBar messages
- mounted check before showing SnackBar to prevent async errors

**Favorites Page Implementation:**
- Accessible from Profile page with "My Favorites" button
- Login required state with prompt to LoginPage
- Loading state with progress indicator
- Empty state with "No favorites yet" message
- Error state with retry button
- Favorite list with product cards showing:
  - Product image (store logo placeholder)
  - Product name
  - Store name
  - Lowest price from variants
  - Remove favorite button
- Tap on product navigates to ProductDetailsPage
- Clean responsive layout using existing Design System

**Authentication Behavior:**
- Unauthenticated users see login prompt in FavoritesPage
- Favorite action in ProductDetails checks authentication
- Shows "Please login to add favorites" message
- Navigates to LoginPage if user chooses to login
- After login, favorite functionality works normally
- Uses existing AuthViewModel for authentication state

**Profile/Navigation Integration:**
- "My Favorites" button added to Profile page
- Located under "Account" section alongside "My Orders"
- Uses AppButton with secondary type
- Navigates to FavoritesPage
- No redesign of Profile page needed
- Clean integration with existing navigation structure

**Error Handling:**
- Network failure handling
- Server error handling
- Authentication failure handling
- User-friendly error messages
- Retry action for failed operations
- No sensitive database errors exposed
- Graceful handling of non-existent favorites

**Security:**
- JWT required for all favorite operations
- User ID extracted from JWT (req.user.userId)
- Never trusts user ID from client
- Ownership enforced in all operations
- SQL injection prevented with parameterized queries
- Duplicate favorites prevented by database logic
- Inactive/nonexistent products handled safely
- Database errors not exposed to users
- No sensitive user information returned

**Performance:**
- Favorite product IDs cached locally for efficient checking
- Prevents duplicate operations with in-progress flag
- Result limits prevent large result sets
- Efficient database queries with proper JOINs
- Proper disposal of ViewModels and resources
- No unnecessary API calls
- checkFavorite returns false on error (graceful degradation)

**Testing:**
- flutter analyze: No issues found
- Backend starts successfully
- GET /api/favorites without JWT returns authentication error
- Authenticated operations work correctly
- Authentication checks work in Flutter
- Navigation from Profile to Favorites works
- Navigation from Favorites to ProductDetails works
- Empty favorites state works
- Add favorite works
- Remove favorite works
- Favorite button in ProductDetails works
- Login prompt shows for unauthenticated users
- All existing features still functional

**Database Changes:**
- No schema changes required
- Uses existing favorites table
- Uses existing users, products, stores tables
- Uses existing status fields
- No new tables or columns added
- Existing favorites table structure was already suitable

## Address Implementation

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for addresses
- Service: Business logic for address validation and user ownership
- Controller: HTTP request/response handling
- Routes: Authenticated address endpoints (JWT required)

**API Endpoints:**
- GET /api/addresses - Returns authenticated user's addresses
- GET /api/addresses/default - Returns user's default address
- GET /api/addresses/:id - Returns specific address
- POST /api/addresses - Creates a new address
- PATCH /api/addresses/:id - Updates an existing address
- DELETE /api/addresses/:id - Deletes an address
- PATCH /api/addresses/:id/default - Sets address as default
- All endpoints require JWT authentication
- User identity extracted from req.user.userId (never from client)

**Database Schema Used:**
- addresses table (existing) with user_id, label, recipient_name, phone, address, is_default, created_at, updated_at
- Foreign key relationships: addresses → users
- Addresses must belong to authenticated user
- User can have multiple addresses
- User can have at most one default address

**Address Business Rules:**
- User must be authenticated (JWT required)
- All fields required: label, recipient_name, phone, address
- First address automatically becomes default
- Setting default address unsets previous default
- Deleting default address assigns default to remaining address
- User can only access/modify their own addresses
- SQL queries parameterized to prevent injection
- Atomic transactions for default address changes
- No sensitive database errors exposed to users

**Database Queries Used:**
- getAll: Fetches all user addresses, sorted by default first
- findById: Fetches specific address with user ownership check
- create: Inserts new address with transaction for default handling
- update: Updates address with transaction for default handling
- remove: Deletes address with ownership check, handles default assignment
- setDefault: Uses transaction to ensure only one default per user
- getDefault: Fetches user's default address
- All queries use parameterized placeholders
- Database transactions for atomic default address operations

**Flutter Architecture:**
- AddressViewModel with ChangeNotifier for address state management
- AddressRepository for API communication with JWT authentication
- AddressesPage with proper UI states
- AddressFormPage for add/edit operations
- AddressModel for data representation
- MVVM pattern maintained throughout
- Uses existing authentication check via AuthViewModel

**Address State Management:**
- States: initial, loading, success, error
- Operations: loading addresses, adding address, updating address, deleting address, setting default
- Prevents duplicate operations with isOperationInProgress flag
- Default address tracking and caching
- Proper disposal of ViewModels and resources

**Address Form Implementation:**
- Single form for both add and edit modes
- Fields: Label, Recipient Name, Phone, Delivery Address, Default Toggle
- Form validation for all required fields
- Uses standard Flutter TextFormField for validation
- Saves address and returns to list
- Reuses existing design system components

**Addresses Page Implementation:**
- Accessible from Profile page with "My Addresses" button
- Login required state with prompt to LoginPage
- Loading state with progress indicator
- Empty state with "No addresses yet" message and Add button
- Error state with retry button
- Address list with cards showing:
  - Address label
  - Default badge
  - Recipient name
  - Phone
  - Address
  - Edit button
  - Set Default button (for non-default addresses)
  - Delete button with confirmation
- Add new address button at bottom
- Clean responsive layout using existing Design System

**Authentication Behavior:**
- Unauthenticated users see login prompt in AddressesPage
- All address operations require authentication
- Shows "Login to View Addresses" message
- Navigates to LoginPage if user chooses to login
- After login, address functionality works normally
- Uses existing AuthViewModel for authentication state

**Profile/Navigation Integration:**
- "My Addresses" button in Profile page
- Located under "Account" section alongside "My Orders" and "My Favorites"
- Uses AppButton with secondary type
- Navigates to AddressesPage
- No redesign of Profile page needed
- Clean integration with existing navigation structure

**Checkout Integration:**
- CheckoutPage loads user's addresses
- If default address exists, auto-selects it
- Checkbox to enable/disable saved address usage
- Address selector dropdown when multiple addresses exist
- "Add new address" button in checkout
- Selected address populates delivery form
- Manual address entry still available
- Preserves existing checkout flow
- Address snapshot copied to order (not dependent on mutable address record)

**Order Snapshot Behavior:**
- Order creation copies delivery information to order record
- Orders preserve address snapshot at creation time
- Historical orders not affected by address changes/deletions
- Current order schema already supports delivery information snapshot
- No schema changes required for order address snapshot
- User can change/delete addresses without affecting old orders

**Error Handling:**
- Network failure handling
- Server error handling
- Authentication failure handling
- Validation error handling
- User-friendly error messages
- Retry action for failed operations
- Confirmation dialogs for destructive operations
- No sensitive database errors exposed
- Graceful handling of non-existent addresses

**Security:**
- JWT required for all address operations
- User ID extracted from JWT (req.user.userId)
- Never trusts user ID from client
- Ownership enforced in all operations
- SQL injection prevented with parameterized queries
- Prevents address access across users
- Database transactions for atomic operations
- No sensitive user information returned
- Address data isolated by user

**Performance:**
- Address list loaded once, not per rebuild
- Default address caching for efficiency
- Prevents duplicate operations with in-progress flag
- Proper disposal of ViewModels and resources
- No unnecessary API calls
- Efficient database queries with proper indexes
- Atomic transactions prevent race conditions

**Testing:**
- flutter analyze: No issues found
- Backend starts successfully
- GET /api/addresses without JWT returns authentication error
- Authenticated operations work correctly
- Authentication checks work in Flutter
- Navigation from Profile to Addresses works
- Empty addresses state works
- Add address works
- Edit address works
- Delete address works
- Set default address works
- Default address uniqueness enforced
- Deleting default address reassigns correctly
- Checkout address selection works
- Manual address entry still works
- Order creation with saved address works
- All existing features still functional

**Database Changes:**
- No schema changes required
- Uses existing addresses table
- Uses existing users table
- No new tables or columns added
- Existing addresses table structure was already suitable

## Categories Implementation

**Database Findings:**
- Categories table already exists in the database
- Products table already has category_id foreign key
- Categories table structure: id, name, created_at
- Parent-child categories supported in design but not implemented in current schema
- No schema changes required for basic category browsing
- Existing schema sufficient for category filtering

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes
- Repository: Parameterized SQL queries for categories
- Service: Business logic for category validation and product filtering
- Controller: HTTP request/response handling
- Routes: Public category endpoints (no authentication required for browsing)

**API Endpoints:**
- GET /api/categories - Returns all categories
- GET /api/categories/:id - Returns specific category
- GET /api/categories/:id/products - Returns products in a category
- Public access (no JWT required for marketplace browsing)
- Category validation in product filtering
- Only returns products from active stores

**Database Queries Used:**
- getAll: Fetches all categories sorted by name
- findById: Fetches specific category by ID
- getProductsByCategory: Fetches products in category with active store filter
- All queries use parameterized placeholders
- Joins products with stores to ensure active store filtering
- No raw SQL concatenation

**Flutter Architecture:**
- CategoryViewModel with ChangeNotifier for category state management
- CategoryRepository for API communication
- CategoriesPage with proper UI states
- CategoryModel for data representation
- MVVM pattern maintained throughout
- No authentication required for category browsing

**Category State Management:**
- States: initial, loading, success, error
- Operations: loading categories
- Proper disposal of ViewModels and resources
- Handles empty category state gracefully

**Categories Page Implementation:**
- Grid layout for category display
- Category cards with icons and names
- Tap navigation to ProductsPage filtered by category
- Loading state with progress indicator
- Empty state with "No categories available" message
- Error state with retry button
- Clean responsive layout using existing Design System

**Home Page Integration:**
- Categories section replaced hardcoded data with real API data
- CategoryViewModel loads categories on init
- Horizontal scrollable category items
- Loading and error states for categories
- Empty state (no categories shown if none exist)
- Tap on category navigates to ProductsPage filtered by category
- "See All" button placeholder for future full categories page
- No redesign of HomePage required

**Products Filtering Implementation:**
- ProductsPage now accepts both storeId and categoryId
- ProductViewModel extended to support category filtering
- CategoryRepository integration for category-specific products
- Dynamic conversion from API response to Product models
- Header shows appropriate title based on filter (Store Products / Category Products / Products)
- Empty state messages adapted for different filter types
- Maintains existing store filtering functionality
- Category filtering works independently

**Navigation Flow:**
- Home → Category → Products → Product Details
- Home → Store → Products → Product Details
- Search → Product Details
- Product Details → Cart
- Cart → Checkout → Order
- Profile → Orders
- Profile → Favorites
- Profile → Addresses
- All existing navigation preserved

**UI/UX Implementation:**
- Uses existing Beep Beep Design System
- AppColors, AppSpacing, AppBorderRadius
- Loading, empty, error states with proper handling
- Responsive grid layout for categories
- Clean integration with existing visual language
- No new branding assets invented

**Testing:**
- flutter analyze: No issues found
- Backend starts successfully
- GET /api/categories returns empty array (no categories in database yet)
- Category API structure validated
- Home screen categories section works
- Category → Products navigation works
- Store → Products navigation still works
- Search still works
- Product Details still works
- Cart still works
- Orders still work
- Favorites still work
- Addresses and Checkout still work
- All existing features functional

**Database Changes:**
- No schema changes required
- Uses existing categories table
- Uses existing products table with category_id
- No new tables or columns added
- Existing categories table structure was already suitable

## Important Technical Decisions
- Uses existing users, products, stores tables
- Uses existing status fields
- No new tables or columns added
- Existing favorites table structure was already suitable

## Important Technical Decisions

### Architecture Decisions
- **MVVM for Flutter:** Clear separation of concerns and testability
- **Layered Architecture for Backend:** Maintainability and scalability
- **MySQL for Database:** Relational data requirements and transaction support
- **Feature-by-Feature Development:** Ensure each feature is complete before moving to next
- **Start in Aleppo:** Focus on one city initially for MVP
- **Marketplace Category Expansion:** Database designed for future categories without major restructuring

### Technology Decisions
- **Node.js + Express:** Ecosystem maturity and rapid development
- **Flutter for Mobile:** Cross-platform mobile development with native performance
- **JWT for Authentication:** Stateless authentication suitable for mobile apps
- **bcrypt for Password Hashing:** Industry standard for secure password storage
- **Google Fonts for Typography:** Easy integration and performance for Poppins
- **Material 3 Design System:** Modern, consistent UI components
- **ChangeNotifier for State Management:** Simple, effective for current needs
- **Custom API Service:** Maintains control over HTTP implementation

### Security Decisions
- **Generic Error Messages:** Prevent user enumeration attacks
- **JWT Expiration (7 days):** Balance between security and user experience
- **Parameterized Queries:** Prevent SQL injection attacks
- **Environment Variables:** Protect sensitive configuration data
- **.gitignore Protection:** Prevent committing secrets to version control

### Design Decisions
- **8dp Grid System:** Consistent spacing and alignment
- **Poppins Font Family:** Modern, friendly typography matching brand identity
- **Blue Primary Color:** Trustworthy and professional appearance
- **Orange Accent Color:** Friendly and energetic highlights
- **Reusable Components:** Maintain consistency and reduce code duplication

## Development Methodology

**Approach:** Feature-by-feature development with end-to-end implementation
- Complete one feature entirely before starting the next
- Test each feature thoroughly before moving forward
- Maintain code quality and architecture standards
- Update documentation after each completed feature

**Git Workflow:**
- Feature commits with descriptive messages
- Regular commits for completed functionality
- No unnecessary commits for incomplete work
- Clear commit history tracking progress

**Testing Approach:**
- Manual testing of each feature
- Integration testing with backend
- UI testing on available platforms
- Flutter analyze for code quality
- Backend API testing with actual requests

## Important Rules for Future AI Agents

### Architecture Rules
- **Backend:** Follow layered architecture (Route → Controller → Service → Repository → Database)
- **Flutter:** Follow MVVM architecture (View → ViewModel → Repository → API Service)
- **Separation of Concerns:** Each layer has specific responsibilities
- **Single Responsibility:** Each function/class should have one clear purpose

### Code Quality Rules
- **No SQL in Controllers:** All database access must go through repositories
- **No HTTP in Views:** All API calls must go through services/repositories
- **Business Logic in Services:** Controllers should handle HTTP, services handle business logic
- **Database Access in Repositories:** Only repositories should interact with the database
- **Reuse Design System:** Always use design system components instead of custom styling
- **No Hard-coded Secrets:** Use environment variables for all sensitive data
- **Git Protection:** Keep .env files out of Git using .gitignore

### Development Process Rules
- **Feature-by-Feature:** Complete one feature end-to-end before starting the next
- **Update Documentation:** Update `docs/project_context.md` after each completed feature
- **Test Before Commit:** Verify implementation before committing to Git
- **No Unrelated Changes:** Don't modify unrelated features without a clear reason
- **Security First:** Always consider security implications of changes

### Communication Rules
- **Context First:** Read project context and brief before starting work
- **Accuracy Matters:** If documentation conflicts with actual code, trust the code and fix the documentation
- **No Assumptions:** Verify actual implementation rather than assuming based on documentation

### Maintenance Rules
- **Update Project Context:** After every completed feature, architectural change, database change, backend change, Flutter change, or important technical decision
- **Preserve History:** Don't delete useful historical information from documentation
- **Be Specific:** Don't write vague summaries - be accurate and detailed
- **Truthful Reporting:** Never claim something was implemented unless it actually exists and was verified

## Documentation Map

**Primary Context Documents:**
- `docs/AI_PROJECT_BRIEF.md` - This file (portable high-level context)
- `docs/project_context.md` - Detailed project context (maintained after each feature)
- `docs/database.md` - Complete database schema documentation

**Design Reference:**
- `docs/design/beep_beep_design_system.png` - Primary visual reference for Flutter UI

**Configuration:**
- `backend/.env` - Environment variables (not in Git)
- `backend/.env.example` - Environment variables template
- `mobail/pubspec.yaml` - Flutter dependencies

## Major Completed Milestones

1. **Project Initialized** - Git repository created, basic project structure established
2. **Database Schema Created** - Complete database schema designed and documented
3. **Backend Infrastructure Created** - Express server, MySQL connection, layered architecture
4. **Health Check Implemented** - GET /api/health endpoint for API monitoring
5. **Registration Implemented** - POST /api/auth/register with validation, password hashing, duplicate checking
6. **Login Implemented** - POST /api/auth/login with JWT generation
7. **JWT Middleware Implemented** - Authentication middleware for protected routes
8. **Protected Endpoint Implemented** - GET /api/auth/me for testing authentication
9. **Flutter Project Created** - Flutter mobile app project initialized
10. **Design System Implemented** - Complete visual design system with reusable components
11. **MVVM Architecture Implemented** - Complete MVVM structure with API service layer
12. **Flutter Register Implemented** - Register screen with validation, API integration, error handling
13. **Flutter Login Implemented** - Login screen with validation, API integration, JWT token storage, navigation
14. **Flutter Splash Screen Implemented** - Splash screen with animation, authentication state checking, startup routing
15. **Authentication State Management Implemented** - AuthViewModel for JWT token checking and user info retrieval
16. **Authenticated Routing Implemented** - Navigation based on JWT token presence to appropriate screens
17. **Centralized Branding Structure Implemented** - BrandLogo widget for easy ostrich logo replacement
18. **Flutter Home Screen Implemented** - Professional marketplace Home screen with MVVM architecture
19. **Bottom Navigation Structure Implemented** - Navigation structure for marketplace features
20. **Home UI Implemented** - Professional marketplace UI with design system components
21. **Profile Screen Implemented** - Basic profile screen with logout functionality
22. **Logout Functionality Implemented** - Complete authentication lifecycle with token clearing
23. **Stores API Implemented** - Backend endpoints for retrieving active stores
24. **Stores Feature Implemented** - Flutter Stores screen with real data integration
25. **Home Stores Integration** - Featured Stores section displays real store data
26. **Localization Implemented** - App-wide English/Arabic localization via `flutter_localizations` + ARB/gen_l10n, RTL/LTR support, persisted language selector under Profile (see "Localization Implementation" section below)

## Immediate Next Step

*(Note: this section is a point-in-time snapshot from before the Role System and Store Owner Dashboard features — both are now complete; see "Role System, Store Ownership & Single-Store Order Rule Implementation" and "Store Owner Dashboard Implementation" below for current status. Left as historical record per the Maintenance Rules' "preserve history" guidance rather than deleted.)*

**Product Reviews & Ratings is now complete** (see "Reviews & Ratings Implementation" below). No specific next feature has been explicitly assigned yet as of this update. Candidates raised elsewhere in this document (not yet prioritized): Store Owner Dashboard (needed, among other things, so orders can actually reach `delivered` status through the app instead of via direct SQL), Product Recommendations, enhanced Search, and User Profile Management beyond logout/addresses.

**Do NOT implement without explicit instruction:**
- Admin features
- Delivery driver integration
- Payment gateways (beyond Cash on Delivery)
- Any other business features

**As of Store Owner Dashboard completion:** orders can now reach `delivered` through the app itself (a store owner progresses an order pending → confirmed → preparing → shipped → delivered from the dashboard), closing the gap noted above. Admin Dashboard remains the next unimplemented major feature.

## Product Filtering & Sorting Implementation

**Database Findings:**
- Products table does not contain direct price or stock columns
- Product variants table contains price and stock columns
- Price filtering must be based on product_variants.price
- Availability filtering must be based on product_variants.stock
- Products belong to stores and categories
- Store activity controlled by stores.status column
- No schema changes required for filtering functionality
- Existing schema sufficient for variant-based filtering

**Backend Architecture:**
- Extended existing productRepository.js to support advanced filtering
- Repository accepts filter object with storeId, categoryId, minPrice, maxPrice, inStock, sortBy
- Dynamic SQL query building with parameterized values
- Whitelisted sorting options to prevent SQL injection
- Product prices aggregated from variants using MIN(pv.price)
- In-stock filtering uses pv.stock > 0 condition
- GROUP BY p.id to handle one-to-many variant relationship
- Sorting placed after GROUP BY to avoid SQL syntax errors
- All filters are combinable (store + category + price + stock + sort)

**API Endpoints:**
- GET /api/products with optional query parameters:
  - store_id: Filter by store ID
  - category_id: Filter by category ID
  - min_price: Minimum variant price
  - max_price: Maximum variant price
  - in_stock: Filter for in-stock products only (true/false)
  - sort: Sort order (newest, price_asc, price_desc, name_asc, name_desc)
- Default behavior: Returns all products from active stores
- Invalid sort values fall back to 'newest'
- All parameters optional, can be combined freely
- Public access (no JWT required for marketplace browsing)

**Sorting Options:**
- newest: ORDER BY p.created_at DESC (default)
- price_asc: ORDER BY MIN(pv.price) ASC
- price_desc: ORDER BY MIN(pv.price) DESC
- name_asc: ORDER BY p.name ASC
- name_desc: ORDER BY p.name DESC

**Database Queries Used:**
- Joins products with stores to ensure active store filtering
- LEFT JOIN with product_variants for price/stock filtering
- Parameterized placeholders for all user input
- No raw SQL concatenation
- GROUP BY p.id for distinct products with variant aggregation
- Sorting whitelist enforced in repository layer

**Flutter Architecture:**
- ProductFilter model for combined filter state management
- Extended ProductRepository to serialize filter parameters
- Updated ProductViewModel to accept and manage ProductFilter
- ProductsPage updated with filter UI components
- ProductFilterSheet bottom sheet for filter configuration
- MVVM pattern maintained throughout
- Filter state preserved in ViewModel for re-apply operations

**ProductFilter Model:**
- Properties: storeId, storeName, categoryId, categoryName, minPrice, maxPrice, inStock, sortBy
- Computed properties: hasFilters, hasPriceFilter, priceRange, sortLabel
- Methods: copyWith() for immutable updates, clearFilters() for reset
- toQueryParams() for API parameter serialization
- Price range formatting with currency symbols
- Sort label mapping for UI display

**Filter UI Implementation:**
- Filter button in ProductsPage header
- ProductFilterSheet bottom sheet with form controls
- Min/max price input fields with number keyboards
- In-stock checkbox for availability filtering
- Sort dropdown with whitelisted options
- Apply button to submit all filters together
- Clear All button to reset all filters
- No API requests until Apply button pressed

**Filter Summary Chips:**
- Compact horizontal chip display above product grid
- Shows active filters: category, store, price range, in-stock, sort
- Individual chip removal by tapping X
- Clear All button for complete filter reset
- Only displayed when filters are active
- Uses Material 3 Chip components with Beep Beep styling

**Empty State Handling:**
- Differentiates between no products vs no matching filters
- "No products available" for unfiltered empty results
- "No products match your filters" for filtered empty results
- Clear Filters action button only shown for filtered empty states
- Maintains appropriate messaging for different contexts

**ProductsPage Updates:**
- Header now includes filter button (filter_list icon)
- Filter chips displayed below header when filters active
- Empty state logic adapted for filter context
- Filter state preserved during retry operations
- Maintains existing store/category navigation titles
- Product grid unchanged, only filter controls added

**Backend Testing:**
- Backend starts successfully with .env loaded
- GET /api/products returns HTTP 200 with empty data array
- GET /api/products?store_id=1 returns HTTP 200 (no products in database)
- GET /api/products?category_id=1 returns HTTP 200 (no products in database)
- GET /api/products?min_price=10&max_price=100 returns HTTP 200
- GET /api/products?sort=price_asc returns HTTP 200
- GET /api/products?sort=invalid returns HTTP 200 (falls back to newest)
- GET /api/products with combined filters returns HTTP 200
- All query parameters properly validated and parsed
- No SQL injection vulnerabilities with parameterized queries

**Flutter Testing:**
- flutter analyze: No issues found
- ProductFilter model compiles correctly
- ProductRepository accepts new filter parameters
- ProductViewModel manages filter state properly
- ProductFilterSheet UI renders without errors
- Filter summary chips display correctly
- Empty state logic works for both filtered and unfiltered contexts

**UI/UX Implementation:**
- Uses existing Beep Beep Design System
- AppColors, AppSpacing, AppBorderRadius
- Material 3 bottom sheet for filter controls
- Chip components for filter summary
- Consistent with existing marketplace UI
- No new branding assets invented
- Clean, intuitive filter interface

**Navigation Flow:**
- Home → Category → Products (with filter) → Product Details
- Home → Store → Products (with filter) → Product Details
- Products → Filter → Apply → Filtered Results
- Products → Filter → Clear All → All Products
- Search → Product Details
- Product Details → Cart
- Cart → Checkout → Order
- Profile → Orders, Favorites, Addresses
- All existing navigation preserved

**Compatibility Verification:**
- Home → Category → Products flow works
- Home → Store → Products flow works
- Search → Product Details flow works
- Products → Product Details flow works
- Product Details → Cart flow works
- Cart → Checkout → Order flow works
- Profile → Orders flow works
- Profile → Favorites flow works
- Profile → Addresses flow works
- Authentication and logout still functional

**Files Created:**
- mobail/lib/data/models/product_filter.dart - Product filter model
- mobail/lib/features/products/presentation/pages/product_filter_sheet.dart - Filter UI bottom sheet

**Files Modified:**
- backend/src/repositories/productRepository.js - Extended filtering logic
- backend/src/services/productService.js - Filter parameter passing
- backend/src/controllers/productController.js - Query parameter parsing
- mobail/lib/data/repositories/product_repository.dart - Filter serialization
- mobail/lib/features/products/presentation/viewmodels/product_viewmodel.dart - Filter state management
- mobail/lib/features/products/presentation/pages/products_page.dart - Filter UI integration
- docs/project_context.md - Updated documentation
- docs/AI_PROJECT_BRIEF.md - This documentation update

**Supported Filters:**
- Store filtering (by store_id)
- Category filtering (by category_id)
- Price range filtering (min_price, max_price)
- Availability filtering (in_stock only)
- Sorting (newest, price_asc, price_desc, name_asc, name_desc)
- All filters can be combined in any combination

**Database Considerations:**
- Price filtering based on variant prices, not product prices
- Availability filtering based on variant stock, not product stock
- Products with no variants handled by LEFT JOIN
- Active store filtering preserved
- Parameterized queries prevent SQL injection
- Whitelisted sorting prevents arbitrary ORDER BY injection

**Current Project Status:**
- Core marketplace features: ✅ Completed
- Authentication: ✅ Completed
- Products with filtering: ✅ Completed
- Cart and orders: ✅ Completed
- Search: ✅ Completed
- Favorites: ✅ Completed
- Addresses: ✅ Completed
- Categories: ✅ Completed
- Product filtering & sorting: ✅ Completed

**Recommended Next Feature:**
- Product reviews and ratings system
- Enhanced search with filter integration
- User profile management (beyond logout and addresses)
- Order tracking and delivery status updates
- Product recommendations based on browsing history

## Localization Implementation

**Goal:**
- Support English and Arabic app-wide, English as the default language, ahead of starting Product Reviews & Ratings
- Requested as an intentional infrastructure step; explicitly instructed not to start Reviews/Ratings until this was done

**Toolchain Decision:**
- Used Flutter's standard `flutter_localizations` + ARB/gen_l10n codegen toolchain (not a custom hand-rolled system)
- `intl: ^0.19.0` and `flutter_localizations` (from the Flutter SDK) added to `pubspec.yaml`; `flutter: generate: true` enabled
- `l10n.yaml` added at `mobail/` root: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-class: AppLocalizations`, `output-dir: lib/l10n/generated`, `synthetic-package: false`
- No other localization packages added — no unnecessary dependencies

**ARB Files:**
- `mobail/lib/l10n/app_en.arb` (English, default/template locale) and `mobail/lib/l10n/app_ar.arb` (Arabic) — 252 keys each, full key parity verified programmatically
- 9 keys use ICU placeholders with typed metadata (e.g. `quantity{quantity: int}`, `helloUser{name: String}`, `orderIdHeading{id: int}`) so gen_l10n generates typed methods (`l10n.quantity(3)`) rather than plain getters
- Existing English copy carried over verbatim into the `app_en` values — no wording changes, only extraction into keys

**MVVM-Compatible Access Pattern:**
- Views obtain the active `AppLocalizations` instance via `AppLocalizations.of(context)!` inside `build()` (and inside each `ListenableBuilder`/helper-method scope that needs it), since it requires a `BuildContext`
- ViewModels (`LoginViewModel`, `RegisterViewModel`) do not depend on `BuildContext` directly. Instead, a `setLocalizations(AppLocalizations l10n)` method caches the instance in a nullable field; the View calls it on every `build()`. `Validators` methods now take `AppLocalizations` as their first parameter so validation error text is localized without the ViewModel touching `BuildContext`
- This preserves the existing MVVM boundary (View → ViewModel → Repository → API Service) exactly

**Locale Persistence:**
- New `mobail/lib/core/locale/locale_provider.dart`: `LocaleProvider extends ChangeNotifier` (module-level singleton `localeProvider`, matching the app's existing no-DI/global-`ChangeNotifier` convention used elsewhere, e.g. `AuthViewModel`)
- Persists the selected language code (`'en'`/`'ar'`) via `SharedPreferences` (already a project dependency — no new package)
- Defaults to English (`Locale('en')`) when no preference is stored, or if `SharedPreferences` is unavailable for any reason
- `mobail/lib/main.dart`: `BeepBeepApp` converted from `StatelessWidget` to `StatefulWidget`; `initState` calls `localeProvider.loadSavedLocale()`; `build()` wraps `MaterialApp` in a `ListenableBuilder(listenable: localeProvider)` and sets `locale`, `supportedLocales: AppLocalizations.supportedLocales`, and `localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate]`

**Language Selector:**
- Added to `mobail/lib/features/home/presentation/pages/profile_page.dart` (Profile screen) as a new card with two tappable options (English / Arabic), wrapped in `ListenableBuilder(listenable: localeProvider)` so the selection updates immediately
- Calls `localeProvider.setLocale(const Locale('en'))` / `Locale('ar')` on tap

**RTL/LTR Handling:**
- Flutter derives `Directionality` automatically from the active `Locale` once wired into `MaterialApp` — no manual `Directionality` widget needed
- Manual fixes applied on top of that automatic behavior, where the original code hardcoded a visual direction:
  - `Icon(Icons.arrow_back, )` on every custom back-arrow icon (Flutter's built-in mechanism for auto-mirroring a directional glyph); applied to Categories, Products, Product Details, Search, Favorites, Cart, Checkout, Orders, Order Details, Addresses, Address Form headers. Also applied to `Icons.chevron_right` list-row indicators in Search.
  - `EdgeInsets.only(right: ...)` → `EdgeInsetsDirectional.only(end: ...)` for horizontal-list item spacing (Home categories/featured-store cards, Product Details image thumbnail carousel)
  - `Positioned(right: ..., top: ...)` → `PositionedDirectional(end: ..., top: ...)` for the Home bottom-nav cart badge
  - `TextAlign.right` → `TextAlign.end` for the Order Details info-row value alignment
- These are mechanical, visually-neutral-in-LTR changes; no UI redesign

**Screens Covered:**
- Auth (Login, Register), Splash, Home (incl. bottom navigation), Stores, Categories, Products (incl. filter sheet), Product Details, Search, Favorites, Cart, Checkout, Orders, Order Details, Order Success, Addresses, Address Form, Profile (incl. new language selector), and all loading/error/empty states across those screens
- `mobail/lib/design_system_demo.dart`'s `DesignSystemDemo` class intentionally left untranslated — it is unreferenced dead code (not navigated to from anywhere in the app) and outside the requested screen list

**Files Created:**
- `mobail/l10n.yaml`
- `mobail/lib/l10n/app_en.arb`
- `mobail/lib/l10n/app_ar.arb`
- `mobail/lib/core/locale/locale_provider.dart`
- `mobail/lib/l10n/generated/app_localizations.dart` (generated by `flutter gen-l10n`/`flutter pub get`, not committed as source)

**Files Modified:**
- `mobail/pubspec.yaml` — added `flutter_localizations`, `intl`, `generate: true`
- `mobail/lib/main.dart` — locale wiring
- `mobail/lib/core/utils/validators.dart` — localized validation messages
- `mobail/lib/features/auth/presentation/viewmodels/login_viewmodel.dart`, `register_viewmodel.dart` — `setLocalizations()` bridge, localized error messages
- Every page under `mobail/lib/features/*/presentation/pages/` (18 files: login, register, splash, home, profile, stores, categories, products, product_filter_sheet, product_details, search, favorites, cart, checkout, orders, order_details, order_success, addresses, address_form)
- `docs/project_context.md`, `docs/AI_PROJECT_BRIEF.md`, `development_status.md` — documentation updates

**Backend/Database:** No changes. This was explicitly out of scope and untouched.

**Testing Performed:**
- Programmatic ARB validation: both `.arb` files are valid JSON, `app_en`/`app_ar` have identical 252-key sets, all 9 ICU placeholder tokens match their declared metadata in both locales
- Cross-referenced every `l10n.<key>`/`AppLocalizations.of(context)!.<key>` call across all modified files against the ARB key set — no undefined keys referenced
- Grep sweep for leftover hardcoded user-facing strings and for any remnants of the old custom `context.l10n.get()` API — none found (only the out-of-scope `DesignSystemDemo` demo widget still has literal strings)
- Brace/paren/bracket balance check across all modified files
- Diffed the new pages against their true on-device originals (via the desktop bridge) for several representative files (`home_page.dart`, `profile_page.dart`, `checkout_page.dart`, `search_page.dart`, `product_filter_sheet.dart`) to confirm only localization/RTL-related lines changed and all original English copy was preserved verbatim
- **Not performed:** `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, and an actual on-device/emulator build/run. The cloud sandbox this session ran in could not download the Flutter/Dart SDK (network policy blocks `storage.googleapis.com`/`dl.google.com`/`pub.dev`), and no local-device shell was available this session to run Flutter on the developer's machine instead. **This should be run locally before treating localization as fully verified**: `flutter pub get && flutter gen-l10n && flutter analyze`, then a manual English → Arabic → English test on a device/emulator, checking RTL layout and that the language choice survives an app restart.

## Reviews & Ratings Implementation

**Goal:**
- Authenticated users who purchased a product (via a `delivered` order) can leave a 1-5 star rating with an optional text review, edit or delete their own review, and see the product's average rating and review count
- Enforce ownership and purchase-eligibility on the backend; reuse the existing Design System and localization system; do not redesign existing screens or touch unrelated features

**Database:**
- New table `reviews`: `id, product_id, user_id, rating (TINYINT), comment (TEXT, nullable), created_at, updated_at`
- `UNIQUE (user_id, product_id)` — one review per user per product, enforced at the database level (in addition to an application-level check in `reviewService.js`)
- `CHECK (rating BETWEEN 1 AND 5)` (MySQL 8.0.16+/MariaDB 10.2+; the service layer validates this regardless, so older MySQL versions where the CHECK is a silent no-op are still protected)
- Foreign keys to `products(id)` and `users(id)`, both `ON DELETE CASCADE`; indexes on `product_id` and `user_id`
- Migration file: `database/migrations/001_create_reviews_table.sql` — purely additive, no existing table altered, run manually (this project has no migration runner)
- No `average_rating`/`review_count` columns added anywhere — both are computed on read via `AVG(rating)`/`COUNT(*)` over `reviews`, avoiding a denormalized value that could drift out of sync

**Purchase-Eligibility Design Decision:**
- A review requires the reviewing user to have at least one order with `status = 'delivered'` that contains the product (`orders JOIN order_items`), checked live at write time in `reviewRepository.hasPurchased()` — not stored as an `order_id` column on the review itself
- Rationale: a user could purchase the same product across multiple orders, and tying the review to one specific order adds complexity without benefit; the schema stays minimal
- **Important finding carried over from investigation:** no code path anywhere in this backend currently transitions an order to `status = 'delivered'` (only `pending` → `cancelled` exists; there is no store/admin dashboard yet). This is a pre-existing gap unrelated to this feature, but it means the purchase-eligibility path could not be exercised through the app itself — verification set an order's status directly via SQL (see Testing below). Implementing a store/order-fulfillment dashboard would resolve this.

**Backend Architecture:**
- Layered architecture: Repository → Service → Controller → Routes (same convention as every other feature)
- `backend/src/repositories/reviewRepository.js` — parameterized queries: `findByProductId`, `findById`, `findByUserAndProduct`, `create`, `update`, `remove`, `getRatingSummary`, `hasPurchased`
- `backend/src/services/reviewService.js` — validation (rating integer 1-5, comment ≤1000 chars) and business rules (product must exist, no duplicate review, purchase required), all with `.code`-tagged errors following the existing convention (`PRODUCT_NOT_FOUND`, `INVALID_RATING`, `COMMENT_TOO_LONG`, `ALREADY_REVIEWED`, `PURCHASE_REQUIRED`, `REVIEW_NOT_FOUND`)
- `backend/src/controllers/reviewController.js` — HTTP handling, maps error codes to status codes, same response envelope (`{success, message, data}`) as every other controller
- `backend/src/routes/reviewRoutes.js` — mounted at `/api/reviews` in `app.js`
- `backend/src/repositories/productRepository.js` — `findById()` extended with a second query computing `review_count`/`average_rating` for the product, attached to the returned object (used by `GET /api/products/:id`)
- Ownership on edit/delete is enforced the same way as Addresses/Favorites: `WHERE id = ? AND user_id = ?` directly in the SQL, not checked only in application code

**API Endpoints:**
- `GET /api/reviews/product/:productId` — public; returns `{ reviews: [...], summary: { reviewCount, averageRating } }`
- `GET /api/reviews/product/:productId/eligibility` — authenticated; returns `{ hasPurchased, hasReviewed, canReview, existingReview }`
- `POST /api/reviews/product/:productId` — authenticated; body `{ rating, comment? }`; 201/400/403/404/409/500
- `PATCH /api/reviews/:id` — authenticated, ownership-enforced; body `{ rating, comment? }`; 200/400/404/500
- `DELETE /api/reviews/:id` — authenticated, ownership-enforced; 200/404/500
- (See `docs/project_context.md` §6 for full request/response examples)

**Flutter Architecture:**
- `mobail/lib/data/models/review_model.dart` — `Review`, `RatingSummary`
- `mobail/lib/data/repositories/review_repository.dart` — `ReviewRepository` (list/eligibility/create/update/delete), JWT injection via `TokenStorage`, same pattern as `FavoriteRepository`
- `mobail/lib/features/reviews/presentation/viewmodels/review_viewmodel.dart` — `ReviewViewModel extends ChangeNotifier`: review-list state (`initial/loading/success/error`), eligibility state, and submit/edit/delete state, all exposed as getters
- `mobail/lib/features/reviews/presentation/widgets/review_form_sheet.dart` — `ReviewFormSheet`, a shared bottom-sheet form (5-star `IconButton` picker + optional `AppTextField` comment, max 1000 chars) used for both create and edit, driven by an injected `onSubmit` callback so it has no direct API/ViewModel coupling
- `mobail/lib/features/products/presentation/pages/product_details_page.dart` — extended with: a rating-summary card, the review list (excluding the current user's own review, which is shown separately with edit/delete), and a context-appropriate action area (write-review button / own-review card / purchase-required message / login prompt)
- `mobail/lib/data/models/product_model.dart` — `averageRating`/`reviewCount` fields (default 0/0.0 for responses that don't include them, e.g. the products list)
- `mobail/lib/config/api_config.dart` — `reviews = '/reviews'` endpoint constant

**Bug Found & Fixed While Implementing This Feature:**
- `product_details_page.dart` was discovered to still contain hardcoded English strings and to never call `AuthViewModel.checkAuthStatus()` in `initState()` — meaning `isAuthenticated` was always `false` there, silently breaking both the favorite-button state and (would have broken) review eligibility. This page was not among the files spot-checked during the prior Localization pass (see that section's Testing notes). Both were fixed as part of this change: the page is now fully localized (reusing ARB keys that, notably, already existed for this exact purpose — `productDetailsTitle`, `addToCart`, etc. — suggesting the keys were added but the page was never wired up), and `initState` now awaits `checkAuthStatus()` before reading `isAuthenticated`.

**Authorization / Business Rules:**
- Must be authenticated (JWT) to check eligibility, create, edit, or delete a review
- Must have purchased the product via a `delivered` order to create a review
- One review per user per product (service-layer check + database `UNIQUE` constraint as defense in depth)
- Rating must be an integer 1-5; comment is optional, trimmed, max 1000 characters
- Only the review's owner can edit or delete it (`user_id` from the JWT, never trusted from the client; ownership enforced in the SQL `WHERE` clause)
- All queries parameterized; no raw SQL concatenation

**Testing Performed:**
- Assembled a complete copy of the backend (all existing + new files) in the cloud sandbox, ran `node -c` syntax checks on every backend file (all passed), then `npm install` (123 packages, no errors)
- MySQL/MariaDB *is* available in this cloud sandbox (unlike the Flutter SDK) — built a throwaway schema in a local MariaDB instance from the exact column lists confirmed in the repository code, applied `001_create_reviews_table.sql`, ran the project's own `backend/src/seeders/seed.js` unmodified (5 users, 15 products, etc. — succeeded), then started the real server (`node src/server.js`) and exercised it with real HTTP requests (`curl`) end-to-end:
  - Eligibility before any purchase → `canReview: false`; `POST` review before purchase → `403 PURCHASE_REQUIRED`; missing token → `401`
  - Inserted a `delivered` order + `order_items` row directly via SQL (see "Purchase-Eligibility Design Decision" above for why) → eligibility flipped to `canReview: true`
  - Invalid ratings (`0`, `6`, `3.7`) → `400 INVALID_RATING`; comment >1000 chars → `400 COMMENT_TOO_LONG`; review for a non-existent product → `404 PRODUCT_NOT_FOUND`
  - Valid review creation → `201`; duplicate review attempt by the same user → `409 ALREADY_REVIEWED`; a second user's duplicate insert attempted directly in SQL (bypassing the app) → correctly rejected by the database `UNIQUE` constraint
  - Second user reviews the same product (after their own `delivered` order) → `GET /api/products/:id` average recalculates correctly (5 and 3 → 4.0 average, count 2)
  - Cross-user ownership: user 2 attempting to `PATCH`/`DELETE` user 1's review → `404` (not `403`, matching the existing Address/Favorite ownership-check convention of not revealing the review exists)
  - Owner edits their own review → `200`, change reflected immediately in `GET /api/reviews/product/:id` and in the recalculated product average; owner deletes their review → `200`, average recalculates again (back down to just the remaining review); deleting again → `404`
  - `GET /api/products/:id` confirmed to expose `average_rating`/`review_count` correctly at every stage above
  - Regression check: `GET /api/products`, `GET /api/stores`, `GET /api/favorites`, `GET /api/orders` (authenticated) all still return successfully — no unrelated endpoint broken
- Flutter side: **not** run through `flutter analyze`/`flutter pub get`/an actual build — the cloud sandbox's network policy still blocks `pub.dev`/`storage.googleapis.com` this session (re-confirmed: both return a blocked `CONNECT` tunnel), and no local device shell was available. Verified statically instead: all new/modified `.dart` files reviewed line-by-line for import-path correctness (cross-checked against the existing, working imports in sibling files at the same directory depth), correct widget/method signatures against the actual Design System widget source (`AppButton`, `AppCard`, `AppTextField`, `AppColors`, `AppSpacing`, `AppBorderRadius`), and correct `l10n.<key>` usage against the ARB files; ARB key parity (270 keys, English/Arabic) verified programmatically. **Run `flutter pub get && flutter analyze` locally before treating the Flutter side as fully verified**, same caveat as the Localization feature.

**Files Created:**
- `database/migrations/001_create_reviews_table.sql`
- `backend/src/repositories/reviewRepository.js`
- `backend/src/services/reviewService.js`
- `backend/src/controllers/reviewController.js`
- `backend/src/routes/reviewRoutes.js`
- `mobail/lib/data/models/review_model.dart`
- `mobail/lib/data/repositories/review_repository.dart`
- `mobail/lib/features/reviews/presentation/viewmodels/review_viewmodel.dart`
- `mobail/lib/features/reviews/presentation/widgets/review_form_sheet.dart`

**Files Modified:**
- `backend/src/app.js` — mounted `/api/reviews`
- `backend/src/repositories/productRepository.js` — `findById()` now includes `average_rating`/`review_count`
- `mobail/lib/data/models/models.dart` — export `review_model.dart`
- `mobail/lib/data/models/product_model.dart` — `averageRating`/`reviewCount` fields
- `mobail/lib/config/api_config.dart` — `reviews` endpoint constant
- `mobail/lib/features/products/presentation/pages/product_details_page.dart` — review UI added; localization + auth-check bug fixed (see above)
- `mobail/lib/l10n/app_en.arb`, `mobail/lib/l10n/app_ar.arb` — 18 new keys added, full parity maintained
- `docs/project_context.md`, `docs/AI_PROJECT_BRIEF.md`, `development_status.md` — documentation updates

**Current Project Status:**
- Core marketplace features, Authentication, Products (with filtering), Cart, Orders, Search, Favorites, Addresses, Categories, Localization: ✅ Completed
- Product Reviews & Ratings — Backend: ✅ Completed, verified end-to-end against a real (sandbox) MySQL/MariaDB instance
- Product Reviews & Ratings — Flutter: ✅ Implemented, statically verified only (see Testing above)
- No admin dashboard, store owner dashboard, or payment gateway integration — unchanged, out of scope for this feature

## Role System, Store Ownership & Single-Store Order Rule Implementation

**Goal:**
- Implement the backend foundation (plus minimal, non-UI Flutter changes) for multi-role users, store ownership, and a governing business rule: **every order must contain products from exactly one store**, and a customer's cart must also contain products from only one store at a time (delivery is handled from a single store — multi-store orders are not supported)
- Explicitly scoped as backend-foundation-only: **no Store Owner Dashboard UI, Admin Dashboard, product-management UI, or payment gateway work** was done as part of this feature

**Database:**
- `database/migrations/002_add_roles_ownership_single_store.sql` — additive, nullable-first, run manually after `001_create_reviews_table.sql` (no migration runner in this project):
  - `stores.owner_id` (nullable) → `users(id)`, index `idx_stores_owner_id` — a store has at most one owner; may have none yet
  - `carts.store_id` (nullable) → `stores(id)`, index `idx_carts_store_id` — set to the store of the first item added to an otherwise-empty cart; reset to `NULL` whenever the cart becomes empty again
  - `orders.store_id` (nullable) → `stores(id)`, index `idx_orders_store_id` — `NULL` only on legacy pre-migration orders; always populated server-side on new orders
  - The migration file includes SQL-comment guidance for later tightening `orders.store_id` to `NOT NULL` (detect any pre-existing multi-store orders via `order_items`/`products`, backfill single-store orders, only then add the constraint) — **this tightening was deliberately not applied**, per the instruction to inspect existing data before making anything mandatory
  - Optional `CHECK (role IN ('customer','store_owner','admin'))` on `users.role` included, guarded for MySQL/MariaDB version differences the same way the Reviews feature's `CHECK` was
- `backend/src/seeders/seed.js` updated: two of the five demo users (`ahmad`, `sara`) are now `store_owner`s; `ahmad` owns two stores (demonstrates one owner/multiple stores), the electronics and gifts stores are deliberately left with no owner (demonstrates the "unowned store" case); one of the two seeded demo carts was corrected to no longer straddle two stores (it accidentally did before this change, which would have violated the new rule)

**Backend Architecture:**
- New `backend/src/middlewares/authorizationMiddleware.js`, layered on top of the existing `authenticate` middleware (unchanged):
  - `requireRole(...allowedRoles)` — re-fetches the user's role from `users` via `userRepository.findById()` on every call (never trusts the JWT's `role` claim alone), so a role change in the database takes effect immediately on the next request with an already-issued token, not after 7 days
  - `requireStoreOwnership(paramName)` / `requireProductOwnership(paramName)` — resolve ownership server-side via `storeRepository.findOwnerId()` / `productRepository.findStoreIdById()` (both new, and deliberately separate from the existing public-facing `findById()` methods so `owner_id` is never exposed on a public response); `admin` always bypasses the ownership check; a client-supplied owner/store/user id anywhere in the request body is never consulted
  - `requireProductOwnership` is implemented and ready but not mounted on any route yet — no product-management endpoints exist in this scope
- Single-Store Cart Rule, `backend/src/services/cartService.js` (`addItem`) + `backend/src/repositories/cartRepository.js`: compares the product's store against the cart's current `store_id`; throws a `.code = 'STORE_MISMATCH'` error (with `.data = {currentStore, requestedStore}`) on a cross-store add instead of mixing stores; new `switchStore()` repository function runs the clear-and-add as one DB transaction (`backend/src/routes/cartRoutes.js`: `POST /api/cart/switch-store`)
- Single-Store Order Rule, `backend/src/repositories/orderRepository.js` (`createOrder`): derives `store_id` from the cart's actual items (the source of truth, independent of `carts.store_id`) and throws `.code = 'MULTI_STORE_CART'` if more than one distinct store is found — a second, independent defensive check beyond the cart-level enforcement above
- New `GET /api/stores/:storeId/orders` (`backend/src/routes/storeRoutes.js`, `storeController.js`, `orderService.getOrdersForStore`, `orderRepository.findByStoreId`) — minimal store-owner order-visibility endpoint, added specifically to give `requireStoreOwnership` a real, testable mounting point (not a dashboard)

**Two Pre-Existing Bugs Found & Fixed While Implementing This Feature** (both distinct from the one bug this feature was explicitly asked to fix, and both would have blocked testing this feature):
1. `cartRepository.createCart()`'s post-insert `SELECT` was missing the `store_id` column, so a brand-new cart's `store_id` came back `undefined` instead of `null` — crashed the very first add-to-cart for any new cart once the single-store check was added. Fixed by adding the column to the `SELECT`.
2. `orderRepository.createOrder()`'s `order_items` INSERT declared 11 columns but its `VALUES` clause had only 10 placeholders (one `?` short) — every checkout (`POST /api/orders`) failed with `ER_WRONG_VALUE_COUNT_ON_ROW`, meaning checkout could not have worked in this codebase before this fix, entirely independent of the single-store feature. Fixed by adding the missing `?`. Diagnosed by calling `orderRepository.createOrder` directly from a standalone Node script (bypassing HTTP) to capture the raw MySQL driver error.

A third pre-existing bug was also found and fixed as a direct blocker to testing this feature (not a bug the user asked for, but leaving it would have made the cart/store feature above impossible to verify): `cartRepository.findByUserId()`'s cart-items query did a `LEFT JOIN product_images` with no `GROUP BY`/limiting — a one-to-many join — so a cart item for a product with more than one image (most seeded products have 2–3) fanned out into duplicate rows in the API response. Replaced with a correlated subquery that picks one representative image per product, matching the seed data's "first image is primary" convention; same response shape, no Flutter changes needed.

**The documented pre-existing bug this feature was explicitly asked to fix** (`orderRepository.findById()` selecting `products.address`, a column that doesn't exist) is now fixed by resolving the store once via the order's own new `store_id` (`SELECT name, address FROM stores WHERE id = ?`), instead of a per-item join to the wrong table — cheaper and correct. Legacy orders with `store_id IS NULL` get `store_name: null` gracefully rather than a SQL error. Response shape unchanged — no Flutter change required for this specific fix.

**Flutter Architecture** (deliberately minimal — no dashboard UI):
- `mobail/lib/data/services/api_service.dart` — `ApiException` extended with optional `code`/`data` fields, parsed from the response body, so a backend error's machine-readable `code` (e.g. `STORE_MISMATCH`) reaches the repository/viewmodel layer
- `mobail/lib/data/repositories/cart_repository.dart` — new `switchStore()` method calling `POST /api/cart/switch-store`
- `mobail/lib/features/cart/presentation/viewmodels/cart_viewmodel.dart` — new `StoreMismatchException` (carries `currentStore`/`requestedStore`); `addItem()` now rethrows it specifically on `ApiException.code == 'STORE_MISMATCH'` instead of folding it into the generic error message like every other failure; new `switchStore()` method mirroring `addItem()`'s loading/error handling
- `mobail/lib/features/products/presentation/pages/product_details_page.dart` — `_handleAddToCart()` catches `StoreMismatchException` and shows a confirmation `AlertDialog` ("Clear the cart and switch to this store?", same `showDialog<bool>`/`AlertDialog` pattern already used for order cancellation in `order_details_page.dart`); confirming calls `CartViewModel.switchStore()`, cancelling leaves the cart untouched (the backend never modified it on the original rejection)
- `mobail/lib/config/api_config.dart` — `cartSwitchStore` endpoint constant
- Localized (English/Arabic), RTL-safe (plain `AlertDialog`/`Text`, no custom layout — respects ambient `Directionality` the same way every other dialog in the app does)
- No Flutter routing, navigation, or UI redesign beyond this one dialog — no Store Owner Dashboard, no role-based navigation branching (the client already persists `role` via `TokenStorage`, unused for now, ready for a future dashboard)

**Authorization / Business Rules:**
- Role is never trusted from the client or from a JWT claim alone — `requireRole` re-verifies against the database on every call
- Store ownership is always resolved server-side from the route param, never from a client-supplied id in the body; `admin` bypasses ownership checks everywhere they're enforced
- A cart may contain items from only one store at a time, enforced at add-time (`STORE_MISMATCH`) and reset when the cart empties
- An order may contain items from only one store, enforced a second time at checkout independent of the cart-level check (`MULTI_STORE_CART`), and the order's `store_id` is always derived server-side
- Existing customer authentication behavior (register/login/JWT/`authenticate`) is unchanged

**Testing Performed:**
- Built a throwaway MariaDB 10.11 schema + a full copy of the backend in the cloud sandbox (same methodology as the Reviews feature), applied `002_add_roles_ownership_single_store.sql`, ran the project's own `seed.js` unmodified, started the real server, and exercised it end-to-end with real HTTP requests (`curl`)
- **47/47 checks passing**, covering: customer auth regression, role-based authorization (including DB-freshness — promoting/demoting a user's role mid-test and confirming the *same, already-issued* JWT reflects the change immediately in both directions, proving the JWT `role` claim alone is never trusted), store ownership (real owner succeeds; a different real store owner is rejected; a plain customer is rejected; unauthenticated is rejected; an unowned store rejects everyone including a legitimate store owner), admin ownership bypass (including on an unowned store), same-store cart adds, cross-store cart rejection with correct `STORE_MISMATCH` payload and an unchanged cart afterward, atomic switch-store, checkout single-store validation, a deliberate bypass simulation (inserting a second-store cart item directly via SQL, outside the API) confirming the checkout-time `MULTI_STORE_CART` defensive check independently catches what the add-time check didn't see, correct `orders.store_id` population, the `findById()` bug fix (correct real store name, not product name), existing order list/cancel regression, no client-supplied owner/user/store id bypasses any authorization check, parameterized-SQL sanity check, and a regression check that the unrelated Reviews feature still responds correctly
- Flutter side: **not** run through `flutter analyze`/`flutter pub get` — same cloud-sandbox network restriction as the Localization and Reviews features (Flutter SDK download blocked). Verified statically instead: brace/structure review of every edited file, `.arb` files validated as well-formed JSON, and the generated `app_localizations*.dart` files hand-updated to match (following the exact pattern of existing entries like `cancelOrderConfirm`/`yesCancelOrder`) since `flutter gen-l10n` cannot run here either. **Run `flutter pub get && flutter analyze` locally before treating the Flutter side as fully verified**, same caveat as every other Flutter change made in a cloud-sandbox session.

**Files Created:**
- `database/migrations/002_add_roles_ownership_single_store.sql`
- `backend/src/middlewares/authorizationMiddleware.js`

**Files Modified:**
- `backend/src/repositories/userRepository.js` — `findById()` added
- `backend/src/repositories/storeRepository.js` — `findOwnerId()` added
- `backend/src/repositories/productRepository.js` — `findStoreIdById()` added
- `backend/src/repositories/cartRepository.js` — `store_id` added to cart selects; `createCart()` bug fix; `resetStoreIdIfEmpty()`, `setCartStoreId()`, `switchStore()` added; cart-items fan-out bug fixed
- `backend/src/services/cartService.js` — `addItem()` single-store check; `switchStore()` added
- `backend/src/controllers/cartController.js` — `STORE_MISMATCH` → 409 handling; `switchStore` controller added
- `backend/src/routes/cartRoutes.js` — `POST /cart/switch-store` route added
- `backend/src/repositories/orderRepository.js` — `findById()` bug fix (store resolution); `createOrder()` single-store derivation/validation + `order_items` INSERT bug fix; `findByStoreId()` added
- `backend/src/controllers/orderController.js` — `MULTI_STORE_CART` → 400 handling
- `backend/src/services/orderService.js` — `getOrdersForStore()` added
- `backend/src/controllers/storeController.js` — `getStoreOrders` added
- `backend/src/routes/storeRoutes.js` — `GET /:storeId/orders` route added
- `backend/src/seeders/seed.js` — roles, store ownership, single-store cart fix
- `mobail/lib/data/services/api_service.dart` — `ApiException.code`/`.data`
- `mobail/lib/data/repositories/cart_repository.dart` — `switchStore()` added
- `mobail/lib/features/cart/presentation/viewmodels/cart_viewmodel.dart` — `StoreMismatchException`, `addItem()` change, `switchStore()` added
- `mobail/lib/features/products/presentation/pages/product_details_page.dart` — `STORE_MISMATCH` confirmation dialog
- `mobail/lib/config/api_config.dart` — `cartSwitchStore` endpoint constant
- `mobail/lib/l10n/app_en.arb`, `mobail/lib/l10n/app_ar.arb`, and the generated `app_localizations*.dart` files — 4 new keys added (hand-updated in the generated files since `gen-l10n` cannot run in this sandbox)
- `docs/project_context.md`, `docs/AI_PROJECT_BRIEF.md`, `development_status.md` — documentation updates

**Current Project Status:**
- Core marketplace features, Authentication, Products (with filtering), Cart, Orders, Search, Favorites, Addresses, Categories, Localization, Product Reviews & Ratings: ✅ Completed
- Role System, Store Ownership & Single-Store Order Rule — Backend: ✅ Completed, verified end-to-end (47/47 checks) against a real (sandbox) MariaDB instance
- Role System, Store Ownership & Single-Store Order Rule — Flutter (minimal STORE_MISMATCH handling only): ✅ Implemented, statically verified only (see Testing above)
- **Still not implemented, unchanged by this feature:** Store Owner Dashboard UI, Admin Dashboard, product-management UI, payment gateway integration

## Store Owner Dashboard Implementation

**Goal:**
- Give `store_owner` users an actual place to use the Role System/Store Ownership backend foundation from the prior feature: a dashboard, integrated into the existing Flutter app (not a separate app), for managing their own store(s), products, and orders
- Governing constraints carried over unchanged from the marketplace's core design and explicitly reaffirmed for this feature: single-store-per-order marketplace (every cart/order belongs to exactly one store); a store owner may manage only their own store(s); admin bypasses ownership restrictions everywhere; multi-store orders are not, and must not become, a thing
- Explicitly scoped as v1: list/switch stores only (no store-creation UI or endpoint — none existed before this feature and none was added); product add/edit/deactivate (soft-delete only, images set at creation only, no image upload); order status advancement one step at a time along a fixed forward path; **no Admin Dashboard work**

**Database:**
- `database/migrations/003_add_product_is_active.sql` — additive, `products.is_active TINYINT(1) NOT NULL DEFAULT 1` + `idx_products_is_active` index; every existing row stays visible with zero behavior change
- Chosen over a hard `DELETE` because a product row is referenced by `order_items`/`cart_items`/`reviews`/`favorites` — deleting it would either cascade-destroy real order history or require nullable FKs everywhere; soft-delete (`is_active = 0`) preserves everything and is reversible
- No other schema changes: `orders.status` already supports the `pending/confirmed/preparing/shipped/delivered/cancelled` set needed for this feature (confirmed from the existing, unmodified `Order.formattedStatus` getter in the Flutter model — no DB `ENUM`/`CHECK` constrains this column, so no migration was needed to "add" these statuses, only to enforce the transition order at the application layer); `product_variants` already has exactly the columns needed (`color, size, price, stock`) — nothing invented

**Backend Architecture:**
- No authorization middleware was modified. `requireRole`, `requireStoreOwnership`, `requireProductOwnership` (all from the prior Role System feature) are reused exactly as-is on every new endpoint; `requireProductOwnership` is mounted on a real route for the first time (`PUT /api/products/:id`, `PATCH /api/products/:id/deactivate`)
- `orderService.js` — `VALID_TRANSITIONS` map is the single source of truth for legal status transitions: `{pending:[confirmed], confirmed:[preparing], preparing:[shipped], shipped:[delivered], delivered:[], cancelled:[]}`. `updateOrderStatus()` looks up the order (store-scoped), checks the target against this map, and calls a repository update whose `UPDATE ... WHERE status = ?` (expected current status) is an atomic guard against a race changing the order between the read and the write. A store owner can never reach `cancelled` through this path — that stays exclusively on the pre-existing customer-only `PATCH /api/orders/:id/cancel`.
- `productService.js` — `validateProductData()` (name/description length limits, category must exist via `categoryRepository.findById`, at least one variant with `price > 0` and integer `stock >= 0`), `createProduct`/`updateProduct`/`deactivateProduct`, all `.code`-tagged errors following the existing convention
- `productRepository.js` — `create`/`update` are transactional; `update` **never deletes a variant row** — a variant with an `id` in the request is updated in place, one without an `id` is appended as new; removing a variant is not exposed at all (an owner retires one by setting its stock to 0). This avoids breaking FKs from `order_items`/`cart_items` on already-placed orders.
- `storeService.js` — `getMyStores(ownerId)`, `getDashboardStats(storeId)` (order counts by status + product count, small aggregate queries)
- New repository methods: `storeRepository.findByOwnerId`, `orderRepository.findByIdForStore`/`countByStoreIdGroupedByStatus`/`updateStatus`, `productRepository.findByStoreIdForOwner`/`create`/`update`/`setActive`/`countByStoreId`
- `authService.getCurrentUser(userId)` + `authController.getMe` — `GET /api/auth/me` now re-fetches the role from the database instead of returning the JWT claim, closing the same stale-token privilege window `requireRole` already closed for authorization; the Flutter dashboard's entry-point visibility depends on this being DB-fresh
- New/extended routes on the existing `productRoutes.js`/`storeRoutes.js` (no new route files) — full list with methods/auth in `docs/project_context.md` §6

**Bugs Found & Fixed While Implementing This Feature** (both discovered as direct consequences of testing `is_active`, not something this feature intentionally set out to fix, but both block correct soft-delete behavior if left):
1. `productService.getProductById()`'s catch block discarded `error.code` and re-threw a plain `Error`, so `productController.getProductById`'s `if (error.code === 'PRODUCT_NOT_FOUND') return 404` branch could never match for *any* missing product — confirmed via `curl GET /api/products/999999` returning 500 even before this feature touched anything. Fixed by preserving `error.code` before falling back to the generic path, matching the convention already used elsewhere (e.g. `reviewService.js`). This had to be fixed for a deactivated product to correctly 404 instead of 500, which is this feature's own acceptance criterion.
2. `categoryRepository.getProductsByCategory()` and `searchRepository.search()` were missing the `is_active = 1` filter that was added to `productRepository.findAll`/`findById` — a deactivated product remained visible when browsing by category or searching, even though it correctly disappeared from the main product list/detail. Both are public product-visibility surfaces parallel to the ones already filtered, so this is the same class of gap, not a new concern; fixed by adding the same filter, and manually verified via `curl` that a deactivated seeded product (id 16) is now excluded from both.

**Flutter Architecture:**
- `data/models/current_user_model.dart`, `data/models/dashboard_stats_model.dart` (new); `store_model.dart` extended with nullable `status` (owner-scoped responses only); `product_model.dart` extended with `isActive` (defaults `true`; only ever `false` on the owner's own product list — public endpoints never send it)
- `data/repositories/store_owner_repository.dart` (new) — wraps every dashboard endpoint, resolves the JWT internally via `TokenStorage` (mirrors `OrderRepository`'s existing convention)
- `data/repositories/auth_repository.dart` — `getMe()` added; `features/auth/presentation/viewmodels/auth_viewmodel.dart` — `checkAuthStatus()` now calls it after confirming a cached token and refreshes the stored role, falling back to the cached role on any error (offline-tolerant, never blocks login/splash)
- `features/store_owner/` (new feature folder, same `presentation/{pages,viewmodels}` convention as every other feature): `StoreOwnerViewModel` (owned stores + selected store, shared by every tab — created once in `StoreOwnerHomePage` and passed down, so switching stores on the Stores tab immediately updates Dashboard/Products/Orders), `OwnerProductViewModel`, `OwnerOrderViewModel` (its `nextValidStatus()` mirrors the server's transition map for UX only — offering just the one legal next step instead of a free-form picker — and is explicitly documented in-code as not itself an authorization or validation boundary)
- `StoreOwnerHomePage` — 4-tab `BottomNavigationBar` shell (Dashboard/Products/Orders/Stores), mirroring the existing customer `HomePage`'s exact shell pattern rather than introducing a new navigation convention; does not replace `HomePage` — reached only via a new button on `ProfilePage`
- `ProductFormPage` — create/edit form; deliberately does not show an image editor when editing (the update endpoint never touches `product_images` — showing a control that silently did nothing would be misleading); existing variants have no remove control (mirrors the backend never deleting a variant row)
- `ProfilePage` — new "Store Owner Dashboard" `AppButton`, shown only when `AuthViewModel.userInfo['role'] == 'store_owner'`; the button's visibility check is wrapped in a `ListenableBuilder` on `AuthViewModel` (a fix made while adding it — without this, the button would be evaluated against the still-null pre-load `userInfo` from the very first frame and never appear once `checkAuthStatus()`'s async role refresh completes, since nothing else in that part of the page tree was listening for the change)
- 44 new localization keys added (English/Arabic, full parity)

**Localization Gap Found & Fixed While Implementing This Feature (pre-existing, unrelated to this feature's own keys):** the three generated `mobail/lib/l10n/generated/app_localizations*.dart` files were missing all 20 keys the Reviews & Ratings feature added to both `.arb` files (`writeAReview`, `submitReview`, `reviewCountLabel`, etc.) — present in the ARB source but never hand-patched into the generated Dart files, meaning the app as it stood would not compile. Discovered while hand-patching this feature's own 44 keys into the same three files (`flutter gen-l10n` cannot run in this sandbox, so every key addition across every feature has always required this manual step — see the Role System feature's Testing notes for the established pattern). Fixed by adding all 20 missing entries alongside the 44 new ones, in the same pass.

**Authorization / Business Rules:**
- Every dashboard endpoint requires `authenticate` + `requireRole('store_owner', 'admin')` + (`requireStoreOwnership('storeId')` or `requireProductOwnership('id')`, as applicable) — the same unmodified middleware from the Role System feature; admin bypasses ownership on all of them
- A store owner can never set an order to `cancelled` (customer-only), never skip a status step, and never move a status backward — enforced by `orderService.VALID_TRANSITIONS`, independent of whatever the Flutter UI offers
- A store owner can only ever see/act on their own store's products and orders; ownership is resolved server-side from the route param on every call, never trusted from a client-supplied id in the request body
- Product `is_active` is a soft-delete only; no endpoint anywhere performs a hard `DELETE` on a product row
- Existing customer authentication, cart, checkout, and order-cancellation behavior is unchanged

**Testing Performed:**
- Full backend re-verification against a freshly rebuilt MariaDB 10.11 sandbox (schema + all three migrations in order + the project's own unmodified `seed.js`), same methodology as every prior feature
- **47/47** pre-existing regression checks (`test.sh`) still passing, plus a new **54/54**-check suite (`test_dashboard.sh`) covering: customer/non-owner/wrong-owner rejection (403/404) on every new endpoint; admin bypass on every new endpoint; store-owner-only endpoints reject a plain customer; every valid one-step status transition succeeds; every invalid transition is rejected (skipping a step, going backward, setting `cancelled` through this path, transitioning from a terminal state); a deactivated product 404s on the public endpoint and disappears from category browsing and search while still appearing (with `is_active: false`) on the owner's own product list; product create/update validation (missing name, bad category, invalid variant price/stock); no client-supplied `store_id`/`owner_id`/`product_id`-adjacent field in any request body can substitute for server-resolved ownership; regression check that customer cart/checkout/product-browsing flows are unaffected by the new `is_active` filter
- Two script infrastructure bugs were found and fixed in `test_dashboard.sh` itself before it could run cleanly: `mysql -uroot` invocations needed `--default-character-set=utf8mb4` (without it, Arabic store names came back mangled and several id-lookups silently resolved empty); the admin test user needed an `UPDATE ... SET password=..., role='admin'` upsert instead of insert-only, since a stale admin row with an unknown password hash could already exist from a prior sandbox run
- Flutter side: **not** run through `flutter analyze`/`flutter pub get`/an actual build — same cloud-sandbox network restriction as every prior Flutter feature (`pub.dev`/`storage.googleapis.com` blocked, re-confirmed this session). Verified statically instead, more thoroughly than a simple brace check: every model field, repository method signature, and Design System widget parameter referenced by the 9 new UI files was individually cross-checked against its actual current definition in the codebase (not assumed from memory or from the plan) — including `Product`/`ProductVariant`/`Order`/`OrderItem`/`Store`/`CategoryModel`/`ProductImage` fields, `AppCard`/`AppTextField`/`AppButton` constructor parameters, and every `StoreOwnerRepository` method's exact parameter names — plus brace/paren/bracket balance on every new/edited file, and programmatic confirmation that all 102 distinct `l10n.*` keys referenced across the new UI files and `profile_page.dart` exist in both ARB files. **Run `flutter pub get && flutter analyze` locally before treating the Flutter side as fully verified**, same caveat as every other Flutter change made in a cloud-sandbox session.

**Files Created:**
- `database/migrations/003_add_product_is_active.sql`
- `mobail/lib/data/models/current_user_model.dart`
- `mobail/lib/data/models/dashboard_stats_model.dart`
- `mobail/lib/data/repositories/store_owner_repository.dart`
- `mobail/lib/features/store_owner/presentation/viewmodels/store_owner_viewmodel.dart`
- `mobail/lib/features/store_owner/presentation/viewmodels/owner_product_viewmodel.dart`
- `mobail/lib/features/store_owner/presentation/viewmodels/owner_order_viewmodel.dart`
- `mobail/lib/features/store_owner/presentation/pages/store_owner_home_page.dart`
- `mobail/lib/features/store_owner/presentation/pages/store_owner_products_page.dart`
- `mobail/lib/features/store_owner/presentation/pages/product_form_page.dart`
- `mobail/lib/features/store_owner/presentation/pages/store_owner_orders_page.dart`
- `mobail/lib/features/store_owner/presentation/pages/store_owner_order_details_page.dart`
- `mobail/lib/features/store_owner/presentation/pages/store_owner_stores_page.dart`

**Files Modified:**
- `backend/src/repositories/storeRepository.js` — `findByOwnerId()` added
- `backend/src/repositories/productRepository.js` — `is_active = 1` filter on `findAll`/`findById`; `findByStoreIdForOwner`/`create`/`update`/`setActive`/`countByStoreId` added
- `backend/src/repositories/orderRepository.js` — `findByIdForStore`/`countByStoreIdGroupedByStatus`/`updateStatus` added
- `backend/src/repositories/categoryRepository.js` — `is_active = 1` filter added to `getProductsByCategory` (bug fix, see above)
- `backend/src/repositories/searchRepository.js` — `is_active = 1` filter added to `search` (bug fix, see above)
- `backend/src/services/storeService.js` — `getMyStores`/`getDashboardStats` added
- `backend/src/services/productService.js` — validation + `createProduct`/`updateProduct`/`deactivateProduct` added; `getProductById` error-code bug fixed (see above)
- `backend/src/services/orderService.js` — `VALID_TRANSITIONS`, `getOrderForStore`/`updateOrderStatus` added
- `backend/src/services/authService.js` — `getCurrentUser()` added
- `backend/src/controllers/authController.js` — `getMe` now DB-fresh
- `backend/src/controllers/productController.js` — `updateProduct`/`deactivateProduct` added
- `backend/src/controllers/storeController.js` — `getMyStores`/`getDashboardStats`/`getStoreProducts`/`createStoreProduct`/`getStoreOrderDetail`/`updateStoreOrderStatus` added
- `backend/src/routes/productRoutes.js` — `PUT /:id`, `PATCH /:id/deactivate` added
- `backend/src/routes/storeRoutes.js` — `GET /mine`, `GET /:storeId/dashboard`, `GET/POST /:storeId/products`, `GET /:storeId/orders/:orderId`, `PATCH /:storeId/orders/:orderId/status` added
- `mobail/lib/data/models/models.dart` — export the two new models
- `mobail/lib/data/models/store_model.dart` — nullable `status` field added
- `mobail/lib/data/models/product_model.dart` — `isActive` field added
- `mobail/lib/config/api_config.dart` — `storesMine` endpoint constant added
- `mobail/lib/data/services/api_service.dart` — `put()` method added (mirrors `post`/`patch`)
- `mobail/lib/data/repositories/auth_repository.dart` — `getMe()` added
- `mobail/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` — `_refreshRoleFromBackend()` added, called from `checkAuthStatus()`
- `mobail/lib/features/home/presentation/pages/profile_page.dart` — "Store Owner Dashboard" entry button (role-gated), `_buildContent()` wrapped in a `ListenableBuilder` on `AuthViewModel` (see Flutter Architecture above)
- `mobail/lib/l10n/app_en.arb`, `mobail/lib/l10n/app_ar.arb` — 44 new keys added, full parity maintained
- `mobail/lib/l10n/generated/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_ar.dart` — hand-patched with the 44 new keys plus the 20 previously-missing Reviews keys (see Localization Gap note above)
- `docs/project_context.md`, `docs/AI_PROJECT_BRIEF.md`, `development_status.md` — documentation updates

**Current Project Status:**
- Core marketplace features, Authentication, Products (with filtering), Cart, Orders, Search, Favorites, Addresses, Categories, Localization, Product Reviews & Ratings, Role System/Store Ownership backend: ✅ Completed
- Store Owner Dashboard — Backend: ✅ Completed, verified end-to-end (47/47 regression + 54/54 new checks) against a real (sandbox) MariaDB instance
- Store Owner Dashboard — Flutter: ✅ Implemented, statically verified only (see Testing above)
- Orders can now reach `delivered` through the app itself (previously only via direct SQL) — resolves the gap noted in "Immediate Next Step" above and in the Reviews feature's Purchase-Eligibility Design Decision
- **Still not implemented:** Admin Dashboard, store-creation UI/endpoint, product image upload, payment gateway integration

---

**Document Purpose:** This AI_PROJECT_BRIEF.md provides portable high-level context for any AI assistant or new coding session to understand the Beep Beep project without scanning the entire repository.

**Maintenance:** This document should be updated after major architectural changes or when the overall project direction shifts significantly. For detailed feature-specific context, refer to docs/project_context.md.

**Last Updated:** 2026-08-29 (Updated with Store Owner Dashboard implementation)
