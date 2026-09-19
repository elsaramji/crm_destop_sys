# Product Requirements Document (PRD)
## General-Purpose Sales & Customer Management CRM — Dummy Version (Egypt Market)

**Author:** Mahmoud "AlSaramiji" Badawy
**Status:** Draft v1.0
**Platform:** Desktop (Flutter Desktop)
**Scope:** Portfolio / Demo Build — Egypt Market

---

## 1. Problem Statement

Small and mid-sized sales operations in Egypt (retail agents, service centers, telecom points-of-sale, financial agents) rely on fragmented tools — WhatsApp chats, Excel sheets, paper logs — to track customer accounts, the services sold to them, follow-up activities, and orders. This creates duplicate customer records (a customer with the same phone number entered multiple times), lost sales history, and no single source of truth an agent can pull up in seconds during a live customer interaction.

This CRM is a **generic, business-agnostic** system (not tied to telecom, retail, or any single vertical) that gives a single admin user a central place to manage customer accounts — identified by National ID and linked phone numbers — along with their services, activities, bills, and orders. This v1 is a **local-only dummy version** meant to prove the data model and core workflows before a cloud-connected multi-role version is built.

**Cost of not solving it:** agents lose track of what was sold to whom and when, follow-ups get missed, and there's no exportable record for reporting or handover.

---

## 2. Goals

| # | Goal | How we measure it |
|---|------|--------------------|
| G1 | Give the admin one place to create/find/edit a customer in under 30 seconds | Time-to-find test with 50 dummy records |
| G2 | Eliminate duplicate customer records | Enforce unique National ID + phone-number linkage at the data layer |
| G3 | Let the admin log every service, activity, order, and bill against a customer | 100% of core entities linked to a `customerId` |
| G4 | Make data portable without needing the cloud yet | Excel export/import round-trips without data loss |
| G5 | Prove the architecture is ready for multi-role + cloud sync later | Data layer abstracted behind a repository interface (swap local → cloud with no UI change) |

---

## 3. Non-Goals (v1 — Dummy/Local Version)

| Non-Goal | Why it's out of scope now |
|---|---|
| Cloud sync / multi-device access | Planned for v2 — local-first keeps v1 simple and fast to demo |
| Multiple roles (sales agent, manager, etc.) | Only **Admin** role exists in v1; role-based permissions come in v2 |
| Payment gateway integration | Bills are recorded, not processed — no real money movement in this system |
| Mobile app | Desktop-only per current spec; mobile is a possible v3 track |
| Notifications / reminders engine | Nice-to-have, deferred to keep v1 tight — see Open Questions |
| Multi-tenant / multi-business support | This is a single-business, single-database instance |

---

## 4. Target User (v1)

**Persona: The Admin/Owner-Operator**
A single person (business owner, senior agent, or ops manager) who is the only user of the system in this version, responsible for every customer record, sale, and follow-up. Comfortable with desktop apps, needs speed over complexity, and wants confidence that no data is duplicated or lost.

---

## 5. User Stories

**Customer Management**
- As the Admin, I want to create a new customer record with National ID and phone number so that I have a unique, de-duplicated account for every person I deal with.
- As the Admin, I want to search customers by name, National ID, or phone number so that I can pull up a record instantly during a call or visit.
- As the Admin, I want to edit an existing customer's data so that I can correct mistakes or update contact info.
- As the Admin, I want to attach multiple phone numbers to one customer account so that I don't create a duplicate when they call from a different number.

**Services & Activities**
- As the Admin, I want to add a service to a customer's profile so that I have a record of what was sold to them and when.
- As the Admin, I want to log an activity (call, visit, follow-up, complaint) against a customer so that I can see the full interaction history at a glance.

**Orders & Billing**
- As the Admin, I want to create an order for a customer so that I can track what they've requested and its status.
- As the Admin, I want to record a bill against a customer so that I know what they owe or have paid.

**Data Portability**
- As the Admin, I want to export all customer data to Excel so that I can back it up or report on it outside the app.
- As the Admin, I want to import customer data from Excel so that I can bulk-load existing records instead of typing them one by one.

**Edge Cases**
- As the Admin, if I try to create a customer with a National ID that already exists, I want a clear warning so that I don't create a duplicate.
- As the Admin, if an Excel import has malformed rows, I want to see which rows failed and why so that I can fix and re-import just those rows.

---

## 6. Functional Requirements

### P0 — Must-Have (v1 cannot ship without these)

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P0-1 | Create Customer | Given valid National ID + at least one phone number, When Admin saves, Then a new customer record is created with a unique internal ID. National ID is validated as unique. |
| P0-2 | Edit Customer | Given an existing customer, When Admin updates any field, Then changes persist and an `updatedAt` timestamp is set. |
| P0-3 | Customer Profile View | Given a customer record, Then Admin sees a single screen showing: personal data, linked phone numbers, services, activities, bills, and orders. |
| P0-4 | Add Service to Customer | Given a customer, When Admin adds a service (name, category, date, price), Then it appears in that customer's service history. |
| P0-5 | Add Activity to Customer | Given a customer, When Admin logs an activity (type, note, date/time), Then it appears in the customer's activity timeline, sorted newest-first. |
| P0-6 | Create Order | Given a customer, When Admin creates an order (items/services, quantity, status: Pending/In Progress/Completed/Cancelled), Then it's saved and linked to that customer. |
| P0-7 | Record Bill | Given a customer, When Admin adds a bill (amount, date, status: Paid/Unpaid/Partial), Then it's saved and reflected in the customer's balance summary. |
| P0-8 | Search & Filter Customers | Given the customer list, When Admin types a name, National ID, or phone number, Then matching results filter in real time. |
| P0-9 | Local Persistence | All data persists locally between app sessions (no data loss on close/reopen). |
| P0-10 | Export to Excel | Given the customer database, When Admin clicks Export, Then a `.xlsx` file is generated containing customers, services, activities, orders, and bills (each as a separate sheet). |
| P0-11 | Import from Excel | Given a correctly-formatted `.xlsx` file, When Admin imports it, Then customer records are created/updated, duplicates (matched by National ID) are flagged, and malformed rows are reported without blocking valid rows. |
| P0-12 | Admin Login | Given a username/password, When Admin logs in, Then access is granted to the app; no login = no access to data screens. |

### P1 — Nice-to-Have (fast follow, not blocking v1)

| # | Requirement | Acceptance Criteria |
|---|---|---|
| P1-1 | Customizable Fields | Admin can add custom key-value fields to a customer profile (e.g., "Preferred Branch") without a code change. |
| P1-2 | Dashboard/Home Summary | Home screen shows total customers, open orders, unpaid bills, and activities logged this week. |
| P1-3 | Bilingual UI Toggle | UI text switches between Arabic and English (RTL/LTR layout support). |
| P1-4 | Order Status History | Each order shows a timeline of status changes, not just the current status. |
| P1-5 | Soft Delete | Deleting a customer archives rather than permanently erases the record. |

### P2 — Future Considerations (v2+, don't build now, design around them)

| # | Requirement | Why it's P2 |
|---|---|---|
| P2-1 | Cloud sync (multi-device) | Requires backend + auth infrastructure — separate initiative |
| P2-2 | Role-based access (Sales Agent, Manager, Viewer) | Needs permission system; only Admin exists in v1 |
| P2-3 | Notifications/reminders for follow-ups | Needs a scheduler/background service |
| P2-4 | Audit log (who changed what) | Meaningless with a single-user system; matters once multi-role lands |
| P2-5 | Reporting/analytics dashboard (charts, trends) | Needs a critical mass of real data first |

---

## 7. Data Model (Draft)

```
Customer
├── id (internal UUID)
├── nationalId (unique, required)
├── fullName
├── phoneNumbers[] (1..n, at least one required)
├── address (optional)
├── email (optional)
├── customFields[] (key-value, P1)
├── createdAt / updatedAt

Service
├── id
├── customerId (FK)
├── name / category
├── price
├── dateProvided
├── notes

Activity
├── id
├── customerId (FK)
├── type (Call / Visit / Complaint / Follow-up / Other)
├── note
├── timestamp

Order
├── id
├── customerId (FK)
├── items[] (service refs or free text)
├── status (Pending / In Progress / Completed / Cancelled)
├── createdAt / updatedAt

Bill
├── id
├── customerId (FK)
├── amount
├── status (Paid / Unpaid / Partial)
├── dueDate
├── issuedAt
```

All child entities (Service, Activity, Order, Bill) link back to `Customer.id` — one customer, one unified history.

---

## 8. Technical Considerations

- **Framework:** Flutter Desktop (Windows-first, since that matches your existing Clean Architecture / BLoC stack — same codebase can extend to macOS/Linux later with minimal friction).
- **Architecture:** Clean Architecture layers you already use (Presentation → Domain → Data), with the **Data layer behind a repository interface** — this is the key decision that makes the v1→v2 (local→cloud) migration painless. Swap `LocalCustomerRepository` for `CloudCustomerRepository` later without touching UI or domain logic.
- **Local Storage:** SQLite via `drift` (recommended over Hive here — you need relational queries: customer → services/activities/orders/bills, and `drift` gives you type-safe joins, which Hive doesn't do well).
- **State Management:** BLoC/Cubit, consistent with your existing portfolio projects.
- **Excel I/O:** `excel` or `syncfusion_flutter_xlsio` package for export/import — the latter has better formatting control if you want polished exports.
- **Auth (v1):** Simple local username/password check against a local admin credentials table (hashed, not plaintext) — not a full auth system, just a gate.
- **Localization:** `intl` + `flutter_localizations` for the bilingual Arabic/English toggle, with RTL support via Flutter's built-in `Directionality`.

---

## 9. Success Metrics (for the demo/portfolio purpose)

Since this is a dummy version built to demonstrate capability (not a live business), success is measured differently than a normal product:

- **Functional completeness:** All P0 requirements demoable end-to-end without crashes.
- **Data integrity:** Zero duplicate customers after importing a 100-row test Excel file with intentional duplicates.
- **Round-trip fidelity:** Export → re-import produces identical data (no loss/corruption).
- **Architecture proof:** A code reviewer/interviewer can see the repository pattern and confirm cloud swap would only touch the Data layer.
- **Time-to-demo:** A new customer can be created, given a service, an activity, and an order in under 2 minutes live in an interview/demo setting.

---

## 10. Open Questions

| Question | Who answers | Blocking? |
|---|---|---|
| Should phone numbers be validated against Egyptian mobile number format (01[0-2,5]XXXXXXXX)? | You (product decision) | Non-blocking — can default to yes |
| Do you want reminders/notifications in v1 or strictly defer to P2? | You | Non-blocking |
| Should the Excel import support updating existing customers, or only creating new ones? | You | **Blocking** — affects import logic design |
| Any specific currency formatting needed for Bills (EGP symbol, decimal rules)? | You | Non-blocking |
| Should "customize data" (P1-1 custom fields) be free-text only, or support typed fields (number/date/dropdown)? | You | Non-blocking, affects UI complexity |

---

## 11. Phasing / Roadmap

**v1 (this PRD) — Local Dummy Version**
Single Admin, local SQLite storage, all P0 requirements, Excel import/export, bilingual UI.

**v2 — Cloud-Connected**
Swap local repository for cloud (Firebase/Supabase — both already in your stack), add real-time sync, keep single-device UX equivalent to v1.

**v3 — Multi-Role**
Add Sales Agent / Manager / Viewer roles with permission boundaries, audit log, notifications engine, and reporting dashboard.

---

*This PRD is a working draft — sections marked in Open Questions need your input before implementation starts.*
