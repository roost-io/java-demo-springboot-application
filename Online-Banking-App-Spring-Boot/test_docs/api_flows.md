# Banking API: API Flows Documentation

This documentation outlines key end-to-end business flows supported by the Banking API. Each flow details the required sequence of API calls, involved data and models, state transitions, and error handling, with references to relevant endpoint specifications and Gherkin scenarios.

---

## Table of Contents

1. [User Registration Flow](#user-registration-flow)
2. [User Login Flow](#user-login-flow)
3. [Account Management Flow](#account-management-flow)
4. [Dashboard Viewing Flow](#dashboard-viewing-flow)
5. [Transaction Flow](#transaction-flow)
6. [Payment Flow](#payment-flow)
7. [Verification Flow](#verification-flow)

---

## 1. User Registration Flow

**Purpose:** Allow new users to create an account.

**Sequence:**
1. **POST** `/api/v1/users/register`  
   *Client submits registration details.*
2. **(Optional) POST** `/api/v1/users/verify`  
   *User provides verification code (from email/SMS).*

**Data Flow:**
- Client sends registration data →  
- API creates a `User` and `UserProfile` (in PENDING_VERIFICATION state if verification is required).

**State Transitions:**
- Initial: `UNREGISTERED`
- After `/register`: `PENDING_VERIFICATION` or `ACTIVE`  
- After successful `/verify`: `ACTIVE`

**Error Handling:**
- Validation errors (400): missing/invalid fields
- Conflict (409): user exists
- Verification errors (401/422): wrong/failure code

**References:**
- **Endpoints:** `/users/register`, `/users/verify`
- **Models:** `User`, `UserProfile`
- **Gherkin:** `Register new user`, `Verify user email`

---

## 2. User Login Flow

**Purpose:** Authenticate users and issue tokens.

**Sequence:**
1. **POST** `/api/v1/auth/login`  
   *Credentials submitted; API returns JWT or session.*

**Data Flow:**
- Client sends username/password →  
- API validates and returns auth token

**State Transitions:**
- User must be in `ACTIVE` state

**Error Handling:**
- Authentication error (401): wrong credentials or unverified account
- Locked/disabled user (423/403)

**References:**
- **Endpoints:** `/auth/login`
- **Models:** `User`
- **Gherkin:** `User logs in with valid credentials`

---

## 3. Account Management Flow

**Purpose:** Allow users to view, create, or manage bank accounts.

**Sequence:**
1. **Auth required**: Ensure token from login flow.
2. **GET** `/api/v1/accounts`  
   *Fetch list of user's accounts.*
3. **POST** `/api/v1/accounts`  
   *Open new bank account.*
4. **PATCH** `/api/v1/accounts/{accountId}`  
   *Update account info/settings.*

**Data Flow:**
- Authenticated token →  
- API pulls `Account` records for current user  
- On create/update: persists in database

**State Transitions:**
- Account creation: `NEW` → `ACTIVE`
- Update: changes reflected on update fields (e.g., nickname, limits)

**Error Handling:**
- Unauthorized (401)
- Validation errors (400)
- Permission errors (403): access to own accounts only

**References:**
- **Endpoints:** `/accounts`, `/accounts/{accountId}`
- **Models:** `Account`
- **Gherkin:** `View account list`, `Create account`, `Update account`

---

## 4. Dashboard Viewing Flow

**Purpose:** Fetch consolidated financial overview.

**Sequence:**
1. **Auth required**
2. **GET** `/api/v1/dashboard`  
   *Returns totals, balances, upcoming payments.*

**Data Flow:**
- Authenticated token →  
- API aggregates data from `User`, `Account`, `Transaction`, `Payment`

**State Transitions:**
- No state changes; read-only

**Error Handling:**
- Unauthorized (401)

**References:**
- **Endpoints:** `/dashboard`
- **Models:** Aggregates: `User`, `Account`, `Transaction`, `Payment`
- **Gherkin:** `View dashboard`

---

## 5. Transaction Flow

**Purpose:** Manage account transactions (view, initiate transfer).

**Sequence:**
1. **Auth required**
2. **GET** `/api/v1/accounts/{accountId}/transactions`  
   *Retrieve statement/history.*
3. **POST** `/api/v1/transactions`  
   *Request funds transfer/transaction.*

**Data Flow:**
- Client requests transaction list →  
- API retrieves from `Transaction` model  
- For transfer: validates, persists, updates involved accounts

**State Transitions:**
- On POST, creates new transaction in `PENDING` or `COMPLETED` (depending on processing rules)
- Account balances debited/credited as appropriate

**Error Handling:**
- Unauthorized (401)
- Forbidden (403): not account owner
- Validation errors (400): insufficient funds, invalid details
- Transaction declined (402/422): e.g., over limits

**References:**
- **Endpoints:** `/accounts/{accountId}/transactions`, `/transactions`
- **Models:** `Transaction`, `Account`
- **Gherkin:** `List transactions`, `Make transfer`

---

## 6. Payment Flow

**Purpose:** Initiate or view scheduled/payments (e.g., bill pay).

**Sequence:**
1. **Auth required**
2. **GET** `/api/v1/payments`  
   *List all payments (scheduled, history).*
3. **POST** `/api/v1/payments`  
   *Schedule a payment.*

**Data Flow:**
- Client requests/payment creation →  
- API processes via `Payment` model, links to `Account`
- Scheduled/recurring payments use internal scheduler

**State Transitions:**
- On create: `SCHEDULED` → `PROCESSING` → `COMPLETED` or `FAILED`

**Error Handling:**
- Unauthorized (401)
- Validation errors (400): bad amounts, dates
- Payment failures (402): insufficient funds
- Not found (404): unknown payee

**References:**
- **Endpoints:** `/payments`
- **Models:** `Payment`, `Account`
- **Gherkin:** `View payment list`, `Schedule payment`

---

## 7. Verification Flow

**Purpose:** Confirm user identity (KYC, device/email/phone).

**Sequence:**
1. **User registration or updates trigger VERIFICATION_REQUIRED status**
2. **POST** `/api/v1/users/verify`  
   *Submit verification code/contact info.*
3. **(If necessary)** Repeat verification with new code (`/users/resend-verification`)

**Data Flow:**
- Client submits code →  
- API checks code, updates `User` status

**State Transitions:**
- `PENDING_VERIFICATION` → `ACTIVE` (on success)
- Remain in `PENDING_VERIFICATION` (on failure)

**Error Handling:**
- Invalid/missing code (422)
- Code expired (410)
- Attempts exhausted (423 lockout)

**References:**
- **Endpoints:** `/users/verify`, `/users/resend-verification`
- **Models:** `User`, `VerificationCode`
- **Gherkin:** `Verify KYC`, `Resend verification code`, `Handle failed attempts`

---

## Cross-Referencing Table

| Flow                | Endpoints                                                        | Models                                | Gherkin Scenarios                       |
|---------------------|------------------------------------------------------------------|---------------------------------------|------------------------------------------|
| Registration        | `/users/register`, `/users/verify`                              | `User`, `UserProfile`, `Verification` | Register, verify                        |
| Login               | `/auth/login`                                                    | `User`                                | Login                                   |
| Account Mgmt        | `/accounts`, `/accounts/{id}`                                   | `Account`                             | List/create/update account               |
| Dashboard           | `/dashboard`                                                    | Aggregates (User, Account, ...)       | Dashboard display                        |
| Transactions        | `/accounts/{id}/transactions`, `/transactions`                  | `Transaction`, `Account`              | List/make transactions                   |
| Payments            | `/payments`                                                     | `Payment`, `Account`                  | View/schedule/cancel payment             |
| Verification        | `/users/verify`, `/users/resend-verification`                   | `User`, `VerificationCode`            | User/email/phone/KYC verification        |

---

> For more detail, refer to individual [Endpoint Reference Documentation], [Model Definitions], and [Feature/Gherkin files].  
> Flows are secured with JWT/session authentication unless specified.  
> All errors should be reported with detailed body and standard HTTP status codes as described per endpoint.

---

**End of Flows Documentation**