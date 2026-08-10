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
- JWT token storage with SharedPreferences
- User registration and login API endpoints
- JWT-based authentication with middleware

**Not Yet Implemented:**
- Product catalog and browsing
- Store management
- Shopping cart functionality
- Order processing and management
- User profile management
- Favorites/wishlist functionality
- Admin dashboard
- Any business features beyond authentication

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
- **Authentication UI:** ✅ Completed (Register and Login screens)
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

## Immediate Next Step

**Implement Logout Functionality and Authenticated Navigation**

This is the next logical step in the authentication feature completion:
- Implement logout functionality with token clearing
- Create navigation structure for authenticated vs unauthenticated screens
- Implement authenticated API requests using stored JWT token
- Create placeholder Home screen for authenticated users

**Do NOT implement:**
- Product features
- Store features
- Cart features
- Order features
- Admin features
- Any other business features

---

**Document Purpose:** This AI_PROJECT_BRIEF.md provides portable high-level context for any AI assistant or new coding session to understand the Beep Beep project without scanning the entire repository.

**Maintenance:** This document should be updated after major architectural changes or when the overall project direction shifts significantly. For detailed feature-specific context, refer to docs/project_context.md.

**Last Updated:** 2026-08-10 (Updated with Login feature implementation)
