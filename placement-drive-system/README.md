# Placement Drive Automation System

An MCA-level, database-backed college placement portal built with HTML, Bootstrap 5, vanilla JavaScript, Node.js/Express, MySQL 8, bcrypt, and MySQL-backed sessions. This is a real server application, not a static-only mockup. MySQL must be configured and running for authentication and application features.

## Features

- Student registration and secure login; bcrypt password hashing, session regeneration, MySQL session persistence, login/register rate limits, role guards, CSRF token checks on state-changing API requests.
- Student profile read/update and validated PDF resume upload (MIME, `%PDF-` signature, 5 MB cap, random server filename).
- Company management; placement drive creation, edit/status APIs, publication state, department eligibility criteria.
- Backend eligibility engine checks CGPA, department, backlogs, graduation year, publication, and deadline; reasons are returned to students. Applications re-check eligibility on the server and duplicate applications are blocked by a database unique key.
- Application status workflow, transactional status notification, interview scheduling and student interview view, notifications.
- Live dashboard and report queries, department and application charts, CSV report export.
- Responsive Bootstrap UI and tests for the eligibility service.

## Stack and project map

- `src/app.js`: Express app and REST API routes.
- `src/server.js`: server bootstrap.
- `src/config/database.js`: pooled `mysql2/promise` connection.
- `src/middleware/auth.js`: session and role/CSRF middleware.
- `src/services/eligibility.js`: transparent reusable eligibility rules.
- `public/pages/`: login, registration, authenticated portal shell.
- `public/js/app.js`, `public/css/app.css`: browser interface.
- `sql/schema.sql`: normalized tables, foreign keys, indexes and uniqueness.
- `sql/seed.sql`, `scripts/seed.js`: sample data and demo account creation.
- `tests/eligibility.test.js`: built-in Node test runner tests.

## Prerequisites

- Node.js 18 or newer and npm.
- MySQL Server 8.0, with permission to create tables and the session-store table.

## Install and configure

From this directory:

```bash
npm install
cp .env.example .env
```

Edit `.env` with your local MySQL host, user, password, database, and a unique random session secret. Create a database/user if desired, then load schema:

```bash
mysql -u root -p < sql/schema.sql
```

The schema creates `placement_db`. Set `DB_NAME=placement_db` in `.env`. The session store automatically creates its own `sessions` table on first connection. Seed demo data after the schema is installed:

```bash
npm run seed
```

Demo accounts (change/remove for deployment):

- Admin: `admin@campusflow.local` / `DemoPass123!`
- Student: `student@campusflow.local` / `DemoPass123!`

The seed process creates a demo MCA 2027 student, a sample company, and a published opportunity. If sample data has already been run, it will not duplicate the user or sample company/drive.

Run the server:

```bash
npm start
```

Open `http://localhost:3000`. The server binds to `0.0.0.0` for local preview/development. Development UI references Bootstrap and Chart.js via CDN; use a connected browser for the charts and full Bootstrap appearance.

Run tests:

```bash
npm test
```

The eligibility tests are database-independent. API tests require a configured MySQL database; see limitations below.

## Database model

`users` stores login identities and roles. `students` has one-to-one user profile data. `companies` owns drives. `placement_drives` stores common criteria and dates; `drive_departments` stores the many-valued department whitelist. `applications` joins a student to a drive and enforces one submission per pair. `interviews` records rounds against applications. `notifications` belongs to a user. Foreign-key delete restrictions preserve placement history; companies and users should be deactivated rather than hard-deleted where history exists.

## API summary

All API results use JSON `{ok, ...}` and errors use `{ok:false,error}`. `GET /api/auth/me` returns the signed-in user and CSRF token. Send that token in `x-csrf-token` for POST/PUT/PATCH requests after login. Registration and login endpoints are public. Core routes include `/api/students/me`, `/api/companies`, `/api/drives`, `/api/drives/:id/eligibility`, `/api/drives/:id/apply`, `/api/applications`, `/api/interviews`, `/api/notifications`, `/api/dashboard`, and `/api/reports/*`. Admin routes are protected by server role checks. Student application lookups are scoped to the signed-in student.

## Security and operational notes

- All SQL values use mysql2 prepared statements; user-controlled content is HTML-escaped in the browser UI.
- Session cookies are HttpOnly, SameSite=Lax and Secure in production. Set `NODE_ENV=production`, HTTPS termination, and a high-entropy `SESSION_SECRET` when deploying.
- State-changing authenticated API requests require the session CSRF token.
- Resume uploads are inaccessible through the public static file handler; uploaded paths are stored as generated filenames. The current UI allows admin resume access through the protected upload route, but does not yet include an admin-facing resume download button.
- Configure MySQL least-privilege credentials, TLS and backups for deployment. Do not use demo passwords in production. Keep `.env` and uploaded resumes out of version control.

## Known limitations / not yet implemented

This delivers the core working backend and first student vertical slice plus drive, eligibility, applications, and interview workflows. It is a college project foundation, not a production-certified deployment. Admin drive/company management is currently create/status-first in the UI; APIs include company edit/deactivation and drive edit. Admin interview list currently focuses on scheduling from shortlisted/selected applicants; a dedicated admin interview-result editor and UI are not completed. Notice `is_read` is stored but no mark-read action exists. Report UI has charts and CSV export; the API currently exports application history and does not implement the requested full filter set/company-wise-selection report. Drive criteria don't currently include optional informational skill tags. Registration validates core fields but needs stronger field-specific validation for production. The SQL seed SQL file is optional; use `npm run seed` for bcrypt demo users.

The placement percentage currently uses distinct selected students divided by all registered students; it is an overall rate, not yet graduation-year filtered. Adjust the overview query when adopting a cohort-specific denominator.
