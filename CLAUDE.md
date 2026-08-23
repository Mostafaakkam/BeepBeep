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

\- \*\*Completed:\*\* Authentication, Home, Stores, Products (with filtering), Cart, Orders, Search, Favorites, Addresses, Categories.

\- \*\*Not Started:\*\* Admin Dashboard, Store Owner Dashboard, Payment Gateways, Advanced Analytics.



\## Branding

\- \*\*Mascot:\*\* A fast, cartoon-style bird.

\- \*\*Primary Color:\*\* #2E54D9 (Blue).

\- \*\*Accent Color:\*\* #FF9F3D (Orange).

\- \*\*Typography:\*\* Poppins (Google Fonts).



\## Immediate Next Step (Context)

Based on the current feature set, the next logical step is to implement the \*\*Product Reviews and Ratings\*\* system. Always verify this with `docs/AI\_PROJECT\_BRIEF.md` before starting.



\---



\*For detailed context, always refer to `docs/project\_context.md` and `docs/AI\_PROJECT\_BRIEF.md`.\*

