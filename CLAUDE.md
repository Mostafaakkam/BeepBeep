\# CLAUDE.md



\## Project Identity

\- \*\*Name:\*\* Beep Beep

\- \*\*Type:\*\* Mobile Marketplace Application (Flutter + Node.js)

\- \*\*Primary Location:\*\* Aleppo, Syria (MVP)

\- \*\*Status:\*\* Active Development (Core Features Completed)



\## Quick Architecture Reference

\- \*\*Flutter:\*\* MVVM (View → ViewModel → Repository → API Service)

\- \*\*Backend (Node.js):\*\* Layered (Route → Controller → Service → Repository → Database)

\- \*\*Database:\*\* MySQL (Name: `beep\_beep`)

\- \*\*Auth:\*\* JWT (7-day expiry) + bcrypt hashing

\- \*\*State Management:\*\* `ChangeNotifier` pattern



\## Key Directories

\- \*\*Backend Source:\*\* `/backend/src/`

\- \*\*Flutter Source:\*\* `/mobail/lib/`

\- \*\*Primary Docs:\*\* `/docs/`



\## Critical Rules for AI

1\.  \*\*Read First:\*\* Always check `docs/AI\_PROJECT\_BRIEF.md` and `docs/project\_context.md` first.

2\.  \*\*No SQL in Controllers:\*\* All DB access goes through Repositories.

3\.  \*\*No HTTP in Views:\*\* All API calls go through Services/Repositories.

4\.  \*\*Use Design System:\*\* In Flutter, use `AppColors`, `AppSpacing`, `AppButton`, etc. (no custom raw styles).

5\.  \*\*Feature Completion:\*\* Complete one full feature (backend + frontend) before moving to the next.

6\.  \*\*Documentation:\*\* Update `docs/project\_context.md` after every significant change.

7\.  \*\*Security:\*\* Never expose secrets; use `.env` files. Use parameterized queries.

8\.  \*\*Verification:\*\* Verify actual code before assuming based on docs. If conflict, code wins.



\## Quick Status

\- \*\*Completed (customer flow):\*\* Authentication, Home/Stores/Categories, Products \& Product Details, Reviews \& Ratings, Search, Favorites, Addresses, Cart (single-store rule, server-side stock enforcement), Checkout, Orders \& Order Details, order cancellation, Localization (EN/AR, RTL).

\- \*\*Completed (store owner flow):\*\* Store Owner Dashboard (dashboard statistics, store products, product CRUD incl. soft-delete/reactivation, store orders \& order details, order status transitions, ownership authorization).

\- \*\*Order lifecycle (as implemented):\*\* `pending → confirmed → preparing → shipped → delivered`, one step at a time, enforced server-side. The legacy `shipping` DB enum value is unused by the application (kept only for backward compatibility) and is \*\*not\*\* an application state.

\- \*\*Verification (2026-09-14):\*\* Full customer and store-owner flows re-verified against the real backend/database (live API testing, authorization matrix, full order lifecycle end-to-end). Several DECIMAL/string and UI bugs found and fixed (see `development_status.md`). `flutter pub get`/`flutter analyze` passed; on-device Flutter runtime testing was not performed (no emulator/device available).

\- \*\*Not Started:\*\* Admin Dashboard, Store creation flow, Product image upload, User profile editing, Payment Gateways, Product Recommendations, Coupons, Notifications, Delivery-driver integration, Multi-city support, Advanced Analytics.



\## Branding

\- \*\*Mascot:\*\* A fast, cartoon-style bird.

\- \*\*Primary Color:\*\* #2E54D9 (Blue).

\- \*\*Accent Color:\*\* #FF9F3D (Orange).

\- \*\*Typography:\*\* Poppins (Google Fonts).



\## Immediate Next Step (Context)

The full customer flow (Auth → Home/Stores/Categories → Products → Cart → Checkout → Orders) and the full Store Owner Dashboard flow (dashboard → products → orders → status transitions) have both been re-verified end-to-end against the real backend and live database, including the complete order lifecycle and an authorization matrix (unauthenticated / customer / correct owner / wrong owner). All bugs found during that verification (checkout address-selector overflow, cart stock accumulation, orders/store-owner-product DECIMAL-to-JSON-number normalization) are fixed. This work is committed and pushed. The next logical step is the \*\*Admin Dashboard\*\*. Always verify current status with `development_status.md` and `docs/AI\_PROJECT\_BRIEF.md` before starting.



\---



\*For detailed context, always refer to `docs/project\_context.md` and `docs/AI\_PROJECT\_BRIEF.md`.\*

