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
- Address API with user-specific delivery address management
- Flutter Addresses screen with MVVM architecture
- Address form for adding/editing addresses
- Default address management
- Checkout integration with saved address selection
- Profile integration with My Addresses access
- Categories API with product category browsing
- Flutter Categories screen with MVVM architecture
- Home screen categories integration with real data
- Products filtering by category
- Category → Products navigation flow
- Product Filtering & Sorting API with advanced filtering options
- Product filter UI with bottom sheet and filter controls
- Filter summary chips and clear functionality
- Combined filter support (store, category, price, availability, sorting)
- App-wide English/Arabic localization with RTL/LTR support and a persisted language selector
- Product Reviews & Ratings API with purchase-verified eligibility and ownership enforcement
- Flutter review submission/edit UI with rating summary and review list on Product Details
- Product average rating and review count computed on read and exposed on Product Details
- Store Owner Dashboard: role-gated Flutter dashboard (list/switch owned stores, add/edit/deactivate products, view and progress orders through their valid status transitions) integrated into the existing app, backed by new/extended backend endpoints reusing the existing role/ownership authorization middleware

### Planned (Not Yet Implemented)
- Admin dashboard
- Store creation flow (an owner cannot create a new store through the app yet — Store Owner Dashboard v1 is list/switch/manage only)
- Product image upload (product images are URL-based only; no file upload UI)
- Advanced delivery pricing
- Payment gateway integration (Stripe, PayPal, etc.)
- User profile management beyond logout and addresses
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
- `role` values: `customer` (default), `store_owner`, `admin`. Role is never trusted from the client or from a JWT claim alone — every authorization check re-fetches the current role from this table (see §7, Role-Based Authorization).
- Relationships: One user can have multiple addresses, one shopping cart, many orders, many favorite products; a `store_owner` may own zero or more stores (see `stores.owner_id` below)
- Currently used by: authentication system, role-based authorization

**stores** *(owner_id added — Store Ownership)*
- Columns: id, `owner_id` (nullable), name, description, phone, address, logo, cover_image, status, created_at, updated_at
- Primary Key: id
- Foreign Key: `owner_id` → `users(id)`, nullable — a store can exist with no owner yet; added by `database/migrations/002_add_roles_ownership_single_store.sql` (additive, nullable)
- Relationships: One store contains many products; belongs to **at most one** `store_owner` (never more — no many-to-many ownership); an owner may own more than one store
- Index: `idx_stores_owner_id`
- Status: In use (products, ordering, browsing); ownership resolution now used by `requireStoreOwnership` middleware

**categories**
- Purpose: Store product categories with parent-child support
- Relationships: One category contains many products, can have child categories
- Status: Schema defined, not yet used

**products** *(is_active added — Store Owner Dashboard)*
- Columns: id, name, description, store_id, category_id, `is_active` (TINYINT(1), default 1), created_at, updated_at
- Primary Key: id
- Foreign Keys: store_id, category_id
- Relationships: Belongs to one store, one category; has many images, many variants
- `is_active`: soft-delete flag, added by `database/migrations/003_add_product_is_active.sql` (additive, `DEFAULT 1` — every existing row stays visible with zero behavior change). A store owner "deleting" a product from the dashboard sets `is_active = 0` server-side; the row and its variants/images are never hard-deleted (avoids breaking FKs from `order_items`/`cart_items`/`reviews`/`favorites`, and preserves historical order snapshots). Every public product-visibility surface filters `is_active = 1`: `productRepository.findAll`/`findById`, `categoryRepository.getProductsByCategory`, `searchRepository.search`. The store owner's own product list (`GET /api/stores/:storeId/products`) deliberately does **not** filter on it, so an owner can see and manage their deactivated products.
- Index: `idx_products_is_active`
- Status: In use

**product_images**
- Purpose: Store product image paths
- Relationships: Belongs to one product
- Status: Schema defined, not yet used

**product_variants**
- Purpose: Store product variations (color, size, price, stock)
- Relationships: Belongs to one product
- Status: Schema defined, not yet used

**carts** *(store_id added — Single-Store Cart Rule)*
- Purpose: Store user shopping carts
- Columns include: id, user_id, `store_id` (nullable)
- Foreign Key: `store_id` → `stores(id)`, nullable — `NULL` while the cart is empty; set server-side to the store of the **first** item added, from then on every add must be from that same store or the API rejects it with `STORE_MISMATCH` (see §6). Reset back to `NULL` whenever the cart becomes empty (item removed/quantity to 0/cart cleared), so the next add is free to pick a new store.
- Index: `idx_carts_store_id`
- Relationships: Belongs to one user, contains many cart items; tied to **exactly one** store at a time (Single-Store Cart Rule)
- Status: In use

**cart_items**
- Purpose: Store products in shopping cart
- Relationships: Belongs to one cart, one product variant
- Status: In use

**orders** *(store_id added — Single-Store Order Rule)*
- Columns: id, user_id, `store_id` (nullable), status, total_price, created_at, updated_at
- Primary Key: id
- Foreign Keys: user_id, `store_id` → `stores(id)` (nullable — `NULL` on legacy orders created before this migration; new orders always get it populated, see below)
- `store_id` is derived and validated **server-side only**, from the cart's actual items at the moment of checkout — it is never accepted from the client. A cart that somehow contains items from more than one store (bypassing the cart-level `STORE_MISMATCH` check) is rejected at checkout with `MULTI_STORE_CART` instead of being allowed through.
- Index: `idx_orders_store_id`
- Status values: `pending`, `confirmed`, `preparing`, `shipped`, `delivered`, `cancelled` (no DB `ENUM`/`CHECK` constraint on this column — the value set is enforced entirely at the application layer, see `orderService.VALID_TRANSITIONS` below). *(Correction — this list previously read "pending, confirmed, shipping, delivered, cancelled"; `preparing`/`shipped` is the actual set already in use by `Order.formattedStatus` in the Flutter model and is now also the single source of truth enforced server-side by the Store Owner Dashboard's status-update endpoint.)*
- Status transitions: `pending → confirmed → preparing → shipped → delivered`, one step at a time, no skipping, no going backward — enforced by `orderService.VALID_TRANSITIONS` (Store Owner Dashboard, `PATCH /api/stores/:storeId/orders/:orderId/status`, see §6). `pending → cancelled` remains exclusively on the pre-existing customer-only `PATCH /api/orders/:id/cancel` endpoint; a store owner can never set `cancelled`.
- Relationships: Belongs to one user, contains many order items; belongs to **exactly one** store (Single-Store Order Rule — "one order must contain products from one store only")
- Status: In use

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

**reviews** *(new — Product Reviews & Ratings)*
- Columns: id, product_id, user_id, rating (TINYINT, 1-5), comment (TEXT, nullable), created_at, updated_at
- Primary Key: id
- Foreign Keys: product_id → products(id) ON DELETE CASCADE, user_id → users(id) ON DELETE CASCADE
- Constraints: UNIQUE(user_id, product_id) — one review per user per product; CHECK(rating BETWEEN 1 AND 5)
- Relationships: Belongs to one product, one user
- Indexes: product_id, user_id
- Migration file: `database/migrations/001_create_reviews_table.sql` (additive only; no existing tables changed)
- Note: average rating and review count are NOT stored as columns anywhere — they are computed on read via `AVG(rating)`/`COUNT(*)` over this table (see `reviewRepository.getRatingSummary()` and the extended `productRepository.findById()`)
- Status: Implemented and in use

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
- **Update (Store Owner Dashboard):** `role` is now re-fetched fresh from the database on every call (`authService.getCurrentUser` → `userRepository.findById`) instead of being read from the JWT claim — closes the same stale-token privilege window that `requireRole` already closed for authorization checks, and is what the Flutter `AuthViewModel` uses on session restore to decide whether to show the Store Owner Dashboard entry point (never trusts a client-cached role indefinitely). Responds 401 with `USER_NOT_FOUND` if the user has been deleted since the token was issued.

**GET /api/products**
- Purpose: Retrieve products with advanced filtering and sorting
- Authentication: None required (public endpoint)
- Query Parameters:
  - `store_id` (optional): Filter by store ID
  - `category_id` (optional): Filter by category ID
  - `min_price` (optional): Minimum variant price
  - `max_price` (optional): Maximum variant price
  - `in_stock` (optional): Filter for in-stock products only
  - `sort` (optional): Sort order (newest, price_asc, price_desc, name_asc, name_desc)
- Response Structure (200):
  ```json
  {
    "success": true,
    "message": "Products retrieved successfully",
    "data": [
      {
        "id": 1,
        "name": "Product Name",
        "description": "Product description",
        "store_id": 1,
        "category_id": 1,
        "store_name": "Store Name",
        "store_logo": "logo_path",
        "created_at": "2026-08-10T10:00:00.000Z",
        "updated_at": "2026-08-10T10:00:00.000Z"
      }
    ]
  }
  ```
- Status Codes: 200 (success), 500 (server error)
- Implementation Notes: All filters are combinable, variant-based price/stock filtering, parameterized SQL, whitelisted sorting
- **Note (Reviews & Ratings):** the response for `GET /api/products/:id` now also includes `average_rating` (number, 0 if no reviews) and `review_count` (integer), computed on read from the `reviews` table.
- **Note (Store Owner Dashboard):** both `GET /api/products` and `GET /api/products/:id` now filter `is_active = 1` (deactivated products are excluded from public browsing/search/category listings — see `products.is_active` in §5). Fixed alongside this: `GET /api/products/:id` previously returned 500 instead of 404 for *any* nonexistent product id (a pre-existing bug in `productService.getProductById`'s error handling that swallowed the `PRODUCT_NOT_FOUND` error code) — this was caught because it's exactly the path a deactivated product must hit to disappear correctly from the storefront.

**GET /api/reviews/product/:productId**
- Purpose: Retrieve a product's reviews and rating summary
- Authentication: None required (public endpoint)
- Response Structure (200):
  ```json
  {
    "success": true,
    "message": "Reviews retrieved successfully",
    "data": {
      "reviews": [
        { "id": 1, "product_id": 1, "user_id": 2, "rating": 5, "comment": "Great product!", "created_at": "...", "updated_at": "...", "user_name": "Sara Yousef" }
      ],
      "summary": { "reviewCount": 1, "averageRating": 5 }
    }
  }
  ```
- Status Codes: 200 (success), 500 (server error)

**GET /api/reviews/product/:productId/eligibility**
- Purpose: Check whether the authenticated user can review this product (purchased via a delivered order, and hasn't already reviewed it)
- Authentication: Required (JWT Bearer token)
- Response Structure (200): `{ "success": true, "data": { "hasPurchased": true, "hasReviewed": false, "canReview": true, "existingReview": null } }`
- Status Codes: 200 (success), 404 (product not found), 500 (server error)

**POST /api/reviews/product/:productId**
- Purpose: Submit a new review for a product
- Authentication: Required (JWT Bearer token)
- Request Body: `{ "rating": 5, "comment": "Optional text" }`
- Business rules enforced: rating must be an integer 1-5; comment optional, max 1000 chars; product must exist; user must not have already reviewed this product; user must have a `delivered` order containing this product
- Status Codes: 201 (success), 400 (invalid rating/comment), 403 (purchase required), 404 (product not found), 409 (already reviewed), 500 (server error)

**PATCH /api/reviews/:id**
- Purpose: Edit the authenticated user's own review
- Authentication: Required (JWT Bearer token); ownership enforced (`WHERE id = ? AND user_id = ?`)
- Request Body: `{ "rating": 4, "comment": "Updated text" }`
- Status Codes: 200 (success), 400 (invalid rating/comment), 404 (review not found or not owned by this user), 500 (server error)

**DELETE /api/reviews/:id**
- Purpose: Delete the authenticated user's own review
- Authentication: Required (JWT Bearer token); ownership enforced (`WHERE id = ? AND user_id = ?`)
- Status Codes: 200 (success), 404 (review not found or not owned by this user), 500 (server error)

### Cart, Orders & Store Ownership API Changes *(new — Role System, Store Ownership & Single-Store Order Rule)*

The pre-existing cart (`/api/cart`) and orders (`/api/orders`) endpoints are unchanged in shape except for the additions below (existing fields/behavior preserved):

**POST /api/cart/items** (existing endpoint — behavior change)
- New rejection case: if the cart already contains an item from a different store, the add is rejected instead of mixing stores.
- Response Structure (409):
  ```json
  {
    "success": false,
    "message": "Your cart contains items from another store",
    "code": "STORE_MISMATCH",
    "data": {
      "currentStore": { "id": 1, "name": "..." },
      "requestedStore": { "id": 2, "name": "..." }
    }
  }
  ```

**POST /api/cart/switch-store** *(new)*
- Purpose: Atomically clear the cart and add the given item, for when the customer confirms switching stores after a `STORE_MISMATCH`
- Authentication: Required (JWT Bearer token)
- Request Body: `{ "product_id": 5, "variant_id": 12, "quantity": 1 }` (same shape as `POST /api/cart/items`)
- Implementation: single DB transaction (delete all cart_items → insert new item → update cart's `store_id`) — never leaves the cart half-cleared on failure
- Status Codes: 200 (success), 400/404 (invalid product/variant), 401 (unauthenticated), 500 (server error)

**POST /api/orders** (existing checkout endpoint — behavior change)
- `store_id` is now derived server-side from the cart's items and stamped onto the created order; never accepted from the client
- New rejection case (defensive, independent of the cart-level `STORE_MISMATCH` check above): if the cart somehow contains items from more than one store at checkout time, the order is not created.
- Response Structure (400): `{ "success": false, "message": "Cart contains products from multiple stores", "code": "MULTI_STORE_CART" }`

**GET /api/stores/:storeId/orders**
- Purpose: List orders placed against one store, for the store owner
- Authentication: Required (JWT Bearer token); Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')` (admin bypasses ownership)
- Query Parameters: `status` (optional) — filter by order status
- Status Codes: 200 (success), 401 (unauthenticated), 403 (not this store's owner and not admin, or the store has no owner), 500 (server error)
- Note: predates the Store Owner Dashboard (added as the ownership middleware's first real mounting point); now reused as-is by the dashboard's Orders tab.

### Store Owner Dashboard API *(new)*

All endpoints below reuse the pre-existing `authenticate` / `requireRole` / `requireStoreOwnership` / `requireProductOwnership` middleware (§7) exactly as-is — no authorization middleware was modified for this feature. Every response follows the existing `{ success, message, data }` / `{ success, message, code }` shape used elsewhere.

**GET /api/stores/mine** *(new)*
- Purpose: The authenticated store owner's own stores (for the dashboard's store list/switcher)
- Authentication: Required; Authorization: `requireRole('store_owner')`
- Response: `data` is an array of stores the caller owns, including `status` (omitted on the public store list/detail endpoints)
- Status Codes: 200 (success), 401 (unauthenticated), 403 (not a store owner), 500 (server error)

**GET /api/stores/:storeId/dashboard** *(new)*
- Purpose: Summary stats for the dashboard home — order counts by status (`pending`/`confirmed`/`preparing`/`shipped`/`delivered`) plus total product count for the store
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')`
- Status Codes: 200 (success), 401, 403, 500

**GET /api/stores/:storeId/products** *(new)*
- Purpose: The store's full product list for the owner, including deactivated (`is_active = 0`) products — unlike the public `GET /api/products`, which excludes them
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')`
- Status Codes: 200 (success), 401, 403, 500

**POST /api/stores/:storeId/products** *(new)*
- Purpose: Create a product in the given store
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')`
- Request Body: `{ "name": "...", "description": "...", "categoryId": 3, "variants": [{ "color": "Red", "size": "M", "price": 19.99, "stock": 10 }], "images": ["https://.../a.jpg"] }` — fields map 1:1 to the existing `products`/`product_variants`/`product_images` columns; no new columns invented
- Validation (service layer, mirrors `reviewService`'s style): name/description length limits, `categoryId` must reference an existing category, at least one variant with `price > 0` and an integer `stock >= 0`
- Status Codes: 201 (success, `data: { id }`), 400 (validation failed — `INVALID_NAME`/`INVALID_DESCRIPTION`/`INVALID_CATEGORY`/`CATEGORY_NOT_FOUND`/`INVALID_VARIANTS`/`INVALID_IMAGES`), 401, 403, 500

**PUT /api/products/:id** *(new)*
- Purpose: Update a product's name/description/category and variants
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireProductOwnership('id')`
- Request Body: same shape as create, minus `images`. Variants with an `id` are updated in place; variants without one are appended as new. **A variant row is never deleted through this endpoint** — an owner retires a variant by setting its stock to 0, not by removing the row — this avoids breaking foreign keys from `order_items`/`cart_items` on already-placed orders.
- Note: does not touch `product_images` — there is no image-editing endpoint in v1 (images are set once at creation only)
- Status Codes: 200 (success), 400 (same validation codes as create), 401, 403, 404 (product not found), 500

**PATCH /api/products/:id/deactivate** *(new)*
- Purpose: Soft-delete a product (`is_active = 0`) — never a hard `DELETE`
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireProductOwnership('id')`
- Status Codes: 200 (success), 401, 403, 404, 500

**GET /api/stores/:storeId/orders/:orderId** *(new)*
- Purpose: Order detail scoped to one store (store-owner sibling of the customer-scoped `GET /api/orders/:id`)
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')`
- Status Codes: 200 (success), 401, 403, 404 (order not found or not in this store), 500

**PATCH /api/stores/:storeId/orders/:orderId/status** *(new)*
- Purpose: Advance an order to the single next valid status (see the `orders` status-transition table in §5)
- Authentication: Required; Authorization: `requireRole('store_owner', 'admin')` then `requireStoreOwnership('storeId')`
- Request Body: `{ "status": "confirmed" }` — target must be one of `confirmed`/`preparing`/`shipped`/`delivered` (never `cancelled` — that stays customer-only) and must be the single valid next step from the order's current status
- Implementation: the underlying `UPDATE` includes `WHERE status = ?` (the expected current status) as an atomic guard against a race changing the order's status between the read and the write
- Status Codes: 200 (success, `data: { status }`), 400 (`INVALID_STATUS` / `INVALID_STATUS_TRANSITION`), 401, 403, 404 (order not found or not in this store), 500

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

**Role-Based Authorization** *(new — Role System, Store Ownership & Single-Store Order Rule)*
- Roles: `customer` (default), `store_owner`, `admin` — stored on `users.role`
- Middleware: `backend/src/middlewares/authorizationMiddleware.js`, applied after `authenticate`:
  - `requireRole(...allowedRoles)` — re-fetches the user's **current** role from the database (via `userRepository.findById`) rather than trusting the JWT's `role` claim, and refreshes `req.user.role`. This closes a stale-token privilege window: a role change (promotion or demotion) in the database takes effect on the very next request made with an already-issued token, without waiting for the token to expire or be reissued. Responds 403 if the (fresh) role is not in `allowedRoles`.
  - `requireStoreOwnership(paramName = 'storeId')` / `requireProductOwnership(paramName = 'id')` — resolve the target store/product from the route param, look up its owner server-side (`storeRepository.findOwnerId` / `productRepository.findStoreIdById`, both distinct from the public-facing `findById` methods so `owner_id` is never exposed on public endpoints), and allow the request only if the authenticated user is that owner, **or** has the `admin` role (ownership bypass, for future admin functionality). Otherwise 403. On success, attaches the resolved resource (`req.store` / `req.product`) for the controller to use.
  - Client-supplied owner/store/user IDs in the request body are never trusted for authorization — ownership is always resolved from the database via the route param, independent of anything in the request body.
  - `requireProductOwnership` *(Store Owner Dashboard)*: now mounted on `PUT /api/products/:id` and `PATCH /api/products/:id/deactivate` — the first product-management endpoints in the app. No changes were made to the middleware itself; it was implemented and tested in the prior feature and reused as-is.
  - `requireStoreOwnership` *(Store Owner Dashboard)*: also now mounted on every new `/api/stores/:storeId/...` dashboard endpoint (§6) — same unmodified middleware, same admin-bypass behavior.
- Applied to `GET /api/stores/:storeId/orders` and the full Store Owner Dashboard endpoint set (`GET /api/stores/mine`, `GET/POST /api/stores/:storeId/products`, `PUT /api/products/:id`, `PATCH /api/products/:id/deactivate`, `GET /api/stores/:storeId/orders/:orderId`, `PATCH /api/stores/:storeId/orders/:orderId/status`) — see §6.
- Existing customer authentication behavior (register/login/JWT/`authenticate` middleware) is unchanged by this feature.

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

### Localization
- **Status**: ✅ Completed (implemented and statically verified; on-device `flutter analyze`/build not run this session — see §12)
- **Related Files**:
  - `mobail/l10n.yaml` — gen_l10n configuration
  - `mobail/lib/l10n/app_en.arb` — English strings (template/default locale, 320 keys as of Store Owner Dashboard)
  - `mobail/lib/l10n/app_ar.arb` — Arabic strings (320 keys, full parity with English)
  - `mobail/lib/l10n/generated/app_localizations.dart` — generated by `flutter gen-l10n` (not committed; produced by `flutter pub get`)
  - `mobail/lib/core/locale/locale_provider.dart` — `LocaleProvider` (ChangeNotifier) + `SharedPreferences` persistence
  - `mobail/lib/main.dart` — wires `locale`, `supportedLocales`, `localizationsDelegates` into `MaterialApp`
  - `mobail/lib/core/utils/validators.dart` — validators take `AppLocalizations` for localized error text
  - `mobail/lib/features/auth/presentation/viewmodels/login_viewmodel.dart`, `register_viewmodel.dart` — `setLocalizations()` bridge pattern (ViewModel stays free of `BuildContext`)
  - `mobail/lib/features/home/presentation/pages/profile_page.dart` — language selector (English/Arabic) under Profile
  - Every page under `mobail/lib/features/*/presentation/pages/` — hardcoded strings replaced with `AppLocalizations.of(context)!.<key>` calls
- **Implementation Notes**: Uses Flutter's standard `flutter_localizations` + ARB/gen_l10n toolchain (no custom/hand-rolled localization system, no unnecessary dependencies beyond `flutter_localizations` + `intl`, both from the Flutter SDK). English is the default language; Arabic is fully supported with automatic RTL layout (Flutter derives `Directionality` from the active `Locale`). Manual RTL-correctness fixes applied where needed: `` on custom back-arrow/chevron icons, and `EdgeInsetsDirectional`/`PositionedDirectional` in place of directionally-hardcoded `EdgeInsets.only(right:)`/`Positioned(right:)` for horizontal-list spacing and badges. Language choice persists across restarts via `SharedPreferences`. MVVM architecture and Design System reused throughout; no UI redesign, no backend/API/database changes.
- **Correction (2026-08-22, during Reviews & Ratings work):** `product_details_page.dart` was found to still have hardcoded English strings and to never call `AuthViewModel.checkAuthStatus()` (so `isAuthenticated` was always `false`, silently breaking both the favorite-button state and, now, review eligibility). Both were fixed while adding the review UI to that same page — see the Reviews entry below.
- **Correction (Store Owner Dashboard):** the three generated `mobail/lib/l10n/generated/app_localizations*.dart` files were found to be missing all 20 of the Reviews feature's keys (`writeAReview`, `submitReview`, `reviewCountLabel`, etc.) — present in both ARB files but never hand-patched into the generated Dart files after that feature's `flutter gen-l10n` couldn't run in this sandbox. This meant the app as delivered would not compile. Fixed alongside this feature's own 44 new keys (all 64 hand-patched into all three generated files, matching the existing pattern for parameterized vs. plain keys); not something this feature introduced, but discovered and fixed while hand-patching its own keys into the same files.

### Reviews
- **Status**: ✅ Completed (backend verified end-to-end in a local sandbox MySQL instance; Flutter side statically verified only — see §12)
- **Related Files**:
  - `mobail/lib/data/models/review_model.dart` — `Review` and `RatingSummary` models
  - `mobail/lib/data/repositories/review_repository.dart` — API communication (list/eligibility/create/update/delete)
  - `mobail/lib/features/reviews/presentation/viewmodels/review_viewmodel.dart` — `ReviewViewModel` (ChangeNotifier) for review list, eligibility, and submit/edit/delete state
  - `mobail/lib/features/reviews/presentation/widgets/review_form_sheet.dart` — shared bottom-sheet form (star picker + optional comment) used for both submitting and editing a review
  - `mobail/lib/features/products/presentation/pages/product_details_page.dart` — extended with rating summary, review list, and the write/edit/delete review flow
  - `mobail/lib/data/models/product_model.dart` — extended with `averageRating`/`reviewCount`
  - `mobail/lib/config/api_config.dart` — extended with the `/reviews` endpoint base path
  - `mobail/lib/l10n/app_en.arb`, `mobail/lib/l10n/app_ar.arb` — review-related strings added (key parity maintained)
- **Implementation Notes**: Authenticated users who purchased a product via a `delivered` order can leave a 1-5 star rating with an optional comment; users can edit/delete their own review; one review per user per product (service-layer check + database `UNIQUE` constraint). Rating summary (average + count) and the review list are shown on Product Details, along with a context-appropriate action: "Write a Review" button, the user's own review with edit/delete icons, a purchase-required message, or a login prompt — depending on auth/purchase/review state. Star rating picker and star displays are plain `Icon(Icons.star / Icons.star_border)` rows (no new dependency). MVVM architecture and Design System reused throughout (`AppCard`, `AppButton`, `AppTextField`, `AppColors`, `AppSpacing`, `AppBorderRadius`); fully localized and RTL-safe (uses `EdgeInsetsDirectional` for the image-thumbnail row already on that page).

### Store Owner Dashboard
- **Status**: ✅ Completed (backend verified end-to-end in a local sandbox MariaDB instance — 47/47 pre-existing regression checks + 54/54 new dashboard checks; Flutter side statically verified only — see §12)
- **Related Files**:
  - `mobail/lib/data/models/current_user_model.dart` — `CurrentUser` model for the DB-fresh `GET /api/auth/me` response
  - `mobail/lib/data/models/dashboard_stats_model.dart` — `DashboardStats` model (order counts by status + product count)
  - `mobail/lib/data/models/store_model.dart` — extended with nullable `status` (owner-scoped responses only)
  - `mobail/lib/data/models/product_model.dart` — extended with `isActive` (defaults to `true`; only ever `false` on the owner's own product list)
  - `mobail/lib/data/repositories/store_owner_repository.dart` — wraps every dashboard endpoint (§6)
  - `mobail/lib/data/repositories/auth_repository.dart` — extended with `getMe()`
  - `mobail/lib/features/auth/presentation/viewmodels/auth_viewmodel.dart` — `checkAuthStatus()` now refreshes the role from the backend after confirming a cached token, falling back to the cached role if the call fails (offline-tolerant)
  - `mobail/lib/features/store_owner/presentation/viewmodels/store_owner_viewmodel.dart` — owned stores, selected store (shared across all dashboard tabs), dashboard stats
  - `mobail/lib/features/store_owner/presentation/viewmodels/owner_product_viewmodel.dart` — product list/create/update/deactivate for the selected store
  - `mobail/lib/features/store_owner/presentation/viewmodels/owner_order_viewmodel.dart` — order list/detail/status-update for the selected store; `nextValidStatus()` mirrors the server's transition map for UX only (not an enforcement point)
  - `mobail/lib/features/store_owner/presentation/pages/store_owner_home_page.dart` — the dashboard shell (4-tab `BottomNavigationBar`, mirrors `HomePage`'s existing pattern) + the Dashboard tab (welcome, store selector, summary stat cards, quick actions)
  - `mobail/lib/features/store_owner/presentation/pages/store_owner_products_page.dart`, `product_form_page.dart` — product list + create/edit form (variants sub-form; images field shown only when creating)
  - `mobail/lib/features/store_owner/presentation/pages/store_owner_orders_page.dart`, `store_owner_order_details_page.dart` — order list + detail with a single "Mark as X" status-advance button
  - `mobail/lib/features/store_owner/presentation/pages/store_owner_stores_page.dart` — list/switch owned stores
  - `mobail/lib/features/home/presentation/pages/profile_page.dart` — "Store Owner Dashboard" entry button, shown only when the (DB-fresh) role is `store_owner`
  - `mobail/lib/l10n/app_en.arb`, `mobail/lib/l10n/app_ar.arb` — 44 new keys added (full EN/AR parity)
- **Implementation Notes**: A single `StoreOwnerViewModel` instance is created once (in `StoreOwnerHomePage`) and passed to every tab, so switching the selected store on the Stores tab immediately updates what the Dashboard/Products/Orders tabs show. Does **not** replace the customer `HomePage` — reached only via the new Profile button, and a store owner can back out to the normal marketplace at any time. No store-creation UI (matches the backend — v1 is list/switch/manage only). The product edit form deliberately omits an image editor, since the update endpoint never touches `product_images` (showing a control that silently did nothing would be misleading); existing variants have no remove control in the UI (mirrors the backend never deleting a variant row). Every screen re-verifies nothing client-side that the backend doesn't already enforce — ownership and status-transition validity are always re-checked server-side regardless of what the UI offers. MVVM architecture and Design System reused throughout; fully localized (English/Arabic).
- **Verification caveat**: no Flutter/Dart SDK is available in this cloud sandbox (confirmed again this session — `pub.dev`/`storage.googleapis.com` blocked), so this feature's Flutter code was verified by static review only: every model/widget/repository/viewmodel API referenced by the new UI files was cross-checked against its actual definition (not assumed), brace/paren/bracket balance was checked on every new/edited file, and all 44 new + previously-missing 20 Reviews-feature localization keys were confirmed present in both ARB files and all three generated `app_localizations*.dart` files (hand-patched — `flutter gen-l10n` cannot run here). `flutter analyze`/`flutter pub get`/an on-device build were **not** run — run these locally before considering the Flutter side fully verified, same caveat as every prior Flutter feature in this project.

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
│   │   ├── favoriteController.js # Favorite request handling
│   │   ├── addressController.js # Address request handling
│   │   ├── categoryController.js # Category request handling
│   │   └── reviewController.js  # Review request handling
│   ├── middlewares/
│   │   └── authMiddleware.js    # JWT authentication middleware
│   ├── repositories/
│   │   ├── userRepository.js     # User data access layer
│   │   ├── storeRepository.js   # Store data access layer
│   │   ├── productRepository.js # Product data access layer
│   │   ├── cartRepository.js    # Cart data access layer
│   │   ├── orderRepository.js   # Order data access layer
│   │   ├── searchRepository.js  # Search data access layer
│   │   ├── favoriteRepository.js # Favorite data access layer
│   │   ├── addressRepository.js # Address data access layer
│   │   ├── categoryRepository.js # Category data access layer
│   │   └── reviewRepository.js  # Review data access layer
│   ├── routes/
│   │   ├── authRoutes.js        # Authentication routes
│   │   ├── healthRoutes.js      # Health check routes
│   │   ├── storeRoutes.js       # Store routes
│   │   ├── productRoutes.js     # Product routes
│   │   ├── cartRoutes.js        # Cart routes
│   │   ├── orderRoutes.js       # Order routes
│   │   ├── searchRoutes.js      # Search routes
│   │   ├── favoriteRoutes.js    # Favorite routes
│   │   ├── addressRoutes.js     # Address routes
│   │   ├── categoryRoutes.js    # Category routes
│   │   └── reviewRoutes.js      # Review routes
│   ├── services/
│   │   ├── authService.js       # Authentication business logic
│   │   ├── storeService.js      # Store business logic
│   │   ├── productService.js    # Product business logic
│   │   ├── cartService.js       # Cart business logic
│   │   ├── orderService.js      # Order business logic
│   │   ├── searchService.js     # Search business logic
│   │   ├── favoriteService.js   # Favorite business logic
│   │   ├── addressService.js    # Address business logic
│   │   ├── categoryService.js   # Category business logic
│   │   └── reviewService.js     # Review business logic
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
│   │   ├── utils/
│   │   │   └── validators.dart            # Input validation utilities (localized)
│   │   └── locale/
│   │       └── locale_provider.dart       # LocaleProvider (ChangeNotifier) + SharedPreferences persistence
│   ├── l10n/
│   │   ├── app_en.arb                     # English strings (template/default locale)
│   │   ├── app_ar.arb                     # Arabic strings
│   │   └── generated/
│   │       └── app_localizations.dart     # gen_l10n output (generated, not committed)
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
│   │   │   ├── address_model.dart         # Address model
│   │   │   ├── category_model.dart        # Category model
│   │   │   ├── product_filter.dart        # Product filter model
│   │   │   ├── review_model.dart          # Review + RatingSummary models
│   │   │   ├── current_user_model.dart    # CurrentUser model (Store Owner Dashboard)
│   │   │   ├── dashboard_stats_model.dart # DashboardStats model (Store Owner Dashboard)
│   │   │   └── models.dart               # Barrel export
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart      # Authentication repository
│   │   │   ├── store_repository.dart      # Store repository
│   │   │   ├── product_repository.dart    # Product repository
│   │   │   ├── cart_repository.dart       # Cart repository
│   │   │   ├── order_repository.dart      # Order repository
│   │   │   ├── favorite_repository.dart   # Favorite repository
│   │   │   ├── address_repository.dart    # Address repository
│   │   │   ├── category_repository.dart   # Category repository
│   │   │   ├── review_repository.dart     # Review repository
│   │   │   └── store_owner_repository.dart # Store Owner Dashboard repository
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
│           │   ├── product_details_page.dart # Product details screen
│           │   └── product_filter_sheet.dart # Product filter bottom sheet
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
│   └── addresses/
│       └── presentation/
│           ├── pages/
│           │   ├── addresses_page.dart         # Addresses screen
│           │   └── address_form_page.dart      # Address form screen
│           └── viewmodels/
│               └── address_viewmodel.dart      # Address ViewModel
│   └── categories/
│       └── presentation/
│           ├── pages/
│           │   └── categories_page.dart        # Categories screen
│           └── viewmodels/
│               └── category_viewmodel.dart     # Category ViewModel
│   └── reviews/
│       └── presentation/
│           ├── widgets/
│           │   └── review_form_sheet.dart      # Submit/edit review bottom sheet
│           └── viewmodels/
│               └── review_viewmodel.dart       # Review ViewModel
│   └── store_owner/
│       └── presentation/
│           ├── pages/
│           │   ├── store_owner_home_page.dart         # Dashboard shell (4-tab BottomNavigationBar) + Dashboard tab
│           │   ├── store_owner_products_page.dart      # Product list for the selected store
│           │   ├── product_form_page.dart              # Create/edit product form
│           │   ├── store_owner_orders_page.dart         # Order list for the selected store
│           │   ├── store_owner_order_details_page.dart # Order detail + status-advance button
│           │   └── store_owner_stores_page.dart         # List/switch owned stores
│           └── viewmodels/
│               ├── store_owner_viewmodel.dart    # Owned stores, selected store, dashboard stats
│               ├── owner_product_viewmodel.dart  # Product list/create/update/deactivate
│               └── owner_order_viewmodel.dart    # Order list/detail/status-update
│   ├── config/
│   │   └── api_config.dart               # API configuration
│   ├── design_system_demo.dart           # Design system demo (for reference)
│   └── main.dart                         # App entry point
├── test/
│   └── widget_test.dart                 # Widget tests
├── pubspec.yaml                          # Flutter dependencies
├── l10n.yaml                             # gen_l10n configuration (arb-dir, output-dir, etc.)
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

### Database Migrations
```
database/
└── migrations/
    ├── 001_create_reviews_table.sql              # Adds the `reviews` table
    ├── 002_add_roles_ownership_single_store.sql  # Adds users.role, stores.owner_id, carts.store_id, orders.store_id
    └── 003_add_product_is_active.sql             # Adds products.is_active (Store Owner Dashboard soft-delete)
```
Run manually, in order, against your local `beep_beep` database — no automated migration runner exists yet (see §15).

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
- **Flutter Products Feature Implemented**: Flutter Products screen with MVVM architecture
- **Product Details Implemented**: Product details screen with variants and images
- **Store → Products Flow**: Navigation from stores to their products
- **Cart API Implemented**: Backend endpoints for shopping cart with authentication
- **Cart Feature Implemented**: Flutter Cart screen with MVVM architecture
- **Add to Cart Implemented**: Functional Add to Cart in Product Details
- **Cart Badge Implemented**: Item count badge in navigation
- **Order API Implemented**: Backend endpoints for order processing with transaction support
- **Order Feature Implemented**: Flutter Orders screen with MVVM architecture
- **Checkout Implemented**: Checkout screen with delivery information and Cash on Delivery
- **Order Success Screen**: Order confirmation screen with order details
- **Order Details Implemented**: Order details screen with full order information
- **Order Cancellation Implemented**: Pending order cancellation functionality
- **Profile Orders Integration**: My Orders access from Profile screen
- **Search API Implemented**: Backend endpoints for unified search across products and stores
- **Search Feature Implemented**: Flutter Search screen with MVVM architecture
- **Home Search Integration**: Search field integration in Home screen
- **Debounced Search**: Debounced search behavior for improved performance
- **Favorites API Implemented**: Backend endpoints for user-specific product bookmarking
- **Favorites Feature Implemented**: Flutter Favorites screen with MVVM architecture
- **Favorite Button Implemented**: Favorite button in Product Details with authentication check
- **Profile Favorites Integration**: My Favorites access from Profile screen
- **Address API Implemented**: Backend endpoints for user address management
- **Address Feature Implemented**: Flutter Addresses screen with MVVM architecture
- **Address Form Implemented**: Address form for adding/editing addresses
- **Default Address Management**: Default address selection and management
- **Checkout Address Integration**: Saved address selection in Checkout
- **Profile Addresses Integration**: My Addresses access from Profile screen
- **Categories API Implemented**: Backend endpoints for product category browsing
- **Categories Feature Implemented**: Flutter Categories screen with MVVM architecture
- **Home Categories Integration**: Real category data integration in Home screen
- **Category Products Filtering**: Products filtering by category
- **Category → Products Flow**: Navigation from categories to filtered products
- **Product Filtering API Implemented**: Advanced product filtering with multiple criteria
- **Product Filtering UI Implemented**: Filter bottom sheet with price, stock, and sort controls
- **Filter Summary Chips**: Visual filter summary with individual removal capability
- **Combined Filters**: Support for multiple simultaneous filters (store, category, price, stock, sort)
- **Empty Filtered States**: Clear empty state with Clear Filters action for filtered results
- **Localization Implemented**: App-wide English/Arabic localization via `flutter_localizations` + ARB/gen_l10n, RTL/LTR support, language selector with persistence — infrastructure step completed ahead of Product Reviews & Ratings
- **Product Reviews & Ratings Implemented**: New `reviews` table + migration, review API (create/edit/delete/list/eligibility) with purchase verification and ownership enforcement, product average rating and review count computed on read, Flutter rating summary + review list + submit/edit UI on Product Details, fully localized — backend verified end-to-end in a local sandbox MySQL instance
- **Store Owner Dashboard Implemented**: New `products.is_active` column + migration, product create/update/deactivate + order status-transition endpoints reusing the existing role/ownership middleware unmodified, DB-fresh `GET /api/auth/me`, role-gated Flutter dashboard (4-tab shell: Dashboard/Products/Orders/Stores) reached from a new Profile button, fully localized (44 new keys) — backend verified end-to-end in a local sandbox MariaDB instance (47/47 regression + 54/54 new checks)

## 12. Current Status

### Backend
- **Infrastructure**: ✅ Completed
- **Authentication**: ✅ Completed (register, login, JWT middleware)
- **Product API**: ✅ Completed (with advanced filtering and sorting)
- **Store API**: ✅ Completed
- **Cart API**: ✅ Completed
- **Order API**: ✅ Completed
- **Search API**: ✅ Completed
- **Favorites API**: ✅ Completed
- **Address API**: ✅ Completed
- **Category API**: ✅ Completed
- **Review API**: ✅ Completed (create/edit/delete/list/eligibility, purchase-verified, ownership-enforced) — verified end-to-end against a local sandbox MySQL instance (seeded data, real HTTP requests via curl); see §14/report for details
- **Store Owner Dashboard API**: ✅ Completed (store list, dashboard stats, product create/update/deactivate, order detail/status-update — see §6) — verified end-to-end against a local sandbox MariaDB instance (47/47 regression + 54/54 new checks)
- **Admin Features**: ❌ Not started

### Flutter
- **Design System**: ✅ Completed
- **Authentication UI**: ✅ Completed (Register and Login screens)
- **Home Screen**: ✅ Completed
- **Categories Screen**: ✅ Completed
- **Product Screens**: ✅ Completed (with filtering and sorting)
- **Cart Screen**: ✅ Completed
- **Order Screens**: ✅ Completed
- **Profile Screen**: ✅ Completed
- **Search Screen**: ✅ Completed
- **Favorites Screen**: ✅ Completed
- **Addresses Screen**: ✅ Completed
- **Reviews (Product Details integration)**: ✅ Implemented (rating summary, review list, write/edit/delete flow); statically verified only — see caveat below
- **Store Owner Dashboard**: ✅ Implemented (dashboard home, product management, order management, store switcher, role-gated Profile entry point — see §8); statically verified only — see caveat below
- **MVVM Architecture**: ✅ Completed (implemented for all features)
- **API Service Layer**: ✅ Completed
- **State Management**: ✅ Completed (ChangeNotifier pattern)
- **JWT Token Storage**: ✅ Completed (SharedPreferences)
- **Localization (English/Arabic)**: ✅ Implemented, statically verified (ARB key parity, no leftover hardcoded strings; 320 keys, full EN/AR parity confirmed programmatically after adding Store Owner Dashboard strings; the 20 Reviews-feature keys missing from the generated Dart files were also found and fixed — see the Localization Correction note in §8). ⚠️ `flutter analyze`/`flutter pub get`/on-device build not run this session — Flutter/Dart SDK download was blocked by the cloud sandbox's network policy (confirmed again this session: `pub.dev`/`storage.googleapis.com` both return a blocked CONNECT tunnel) and no local device shell was available. Run these locally to confirm before treating the Flutter side as fully verified.

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
- Implement advanced search with filters
- Implement user profile management (beyond logout and addresses)
- Add notification system for order updates
- Implement product recommendations

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
- Store creation flow for store owners (v1 of the Store Owner Dashboard is list/switch/manage only)
- Product image upload (currently URL-based only)
- Delivery driver integration
- Payment processing
- Multi-city expansion
- Advanced search and filtering
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

**Last Updated**: 2026-08-29 (Store Owner Dashboard implementation completed)
