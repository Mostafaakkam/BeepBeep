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

**Not Yet Implemented:**
- Order management dashboard for store owners
- Admin dashboard
- Advanced delivery pricing
- Payment gateway integration (Stripe, PayPal, etc.)
- User profile management beyond logout
- Address management
- Store management for store owners
- Any business features beyond authentication, Home, Stores, Products, Cart, Orders, Search, and Favorites

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
- **users** - User accounts (id, name, phone, email, password, role, created_at, updated_at)
- **stores** - Shop information
- **categories** - Product categories with parent-child support
- **products** - Main product information
- **product_images** - Product image paths
- **product_variants** - Product variations (color, size, price, stock)
- **carts** - User shopping carts
- **cart_items** - Products in shopping carts
- **orders** - Customer orders
- **order_items** - Order history snapshots
- **addresses** - Customer delivery addresses
- **favorites** - User favorite products

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

## Immediate Next Step

**Implement Product Catalog and Browsing**

This is the next logical step in the marketplace feature completion:
- Implement Product catalog and browsing feature
- Create Store management functionality
- Implement authenticated API requests using stored JWT token
- Create navigation for bottom navigation tabs functionality

**Do NOT implement:**
- Shopping cart features
- Order management
- Profile management (beyond logout)
- Admin features
- Any other business features

---

**Document Purpose:** This AI_PROJECT_BRIEF.md provides portable high-level context for any AI assistant or new coding session to understand the Beep Beep project without scanning the entire repository.

**Maintenance:** This document should be updated after major architectural changes or when the overall project direction shifts significantly. For detailed feature-specific context, refer to docs/project_context.md.

**Last Updated:** 2026-08-13 (Updated with Favorites implementation)
