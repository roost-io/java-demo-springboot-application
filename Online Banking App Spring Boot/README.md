# Online Banking App — Spring Boot Backend

A demo online banking REST API built with Spring Boot 2.7.15, MySQL, and JWT authentication. Supports user registration with email verification, multiple bank accounts per user, and core transaction operations (deposit, withdrawal, transfer, payment).

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
- [Database Schema](#database-schema)
- [Class Reference](#class-reference)
  - [Entry Point](#entry-point)
  - [Models — Entities & DTOs](#models--entities--dtos)
  - [Repositories](#repositories)
  - [Controllers](#controllers)
  - [Security & Authentication](#security--authentication)
  - [Helpers](#helpers)
  - [Configuration](#configuration)
  - [Exception Handling](#exception-handling)
- [API Endpoints](#api-endpoints)
- [Application Flows](#application-flows)
- [Setup & Running](#setup--running)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Spring Boot 2.7.15 |
| Language | Java 1.8 |
| Build | Maven |
| Database | MySQL |
| ORM | Spring Data JPA / Hibernate |
| Auth | JWT (HS256) via JJWT 0.11.x |
| Password | BCrypt (`spring-security-crypto`) |
| Email | Spring Boot Mail (SMTP) |
| Server Port | 8070 |
| CORS Allowed Origin | `http://localhost:3000` |

---

## Project Structure

```
Online Banking App Spring Boot/
├── pom.xml
├── src/main/
│   ├── resources/
│   │   └── application.properties
│   └── java/com/beko/DemoBank_v1/
│       ├── DemoBankV1Application.java          ← App entry point
│       ├── config/
│       │   ├── AppConfig.java                  ← CORS, interceptor, view resolver
│       │   └── MailConfig.java                 ← SMTP configuration
│       ├── controllers/
│       │   ├── RegisterController.java         ← POST /register
│       │   ├── AuthController.java             ← POST /login, GET /logout
│       │   ├── IndexController.java            ← GET /, GET /verify
│       │   ├── AppController.java              ← GET /app/* (dashboard, history)
│       │   ├── AccountController.java          ← POST /account/create_account
│       │   └── TransactController.java         ← POST /transact/* (deposit, transfer, withdraw, payment)
│       ├── models/
│       │   ├── User.java                       ← Entity: users table
│       │   ├── Account.java                    ← Entity: accounts table
│       │   ├── Transact.java                   ← Entity: transaction_history table (write-only)
│       │   ├── Payment.java                    ← Entity: payments table (write-only)
│       │   ├── TransactionHistory.java         ← Entity: v_transaction_history view (read-only)
│       │   ├── PaymentHistory.java             ← Entity: v_payments view (read-only)
│       │   ├── TransferRequest.java            ← DTO: transfer request body
│       │   └── PaymentRequest.java             ← DTO: payment request body
│       ├── repository/
│       │   ├── UserRepository.java
│       │   ├── AccountRepository.java
│       │   ├── TransactRepository.java
│       │   ├── PaymentRepository.java
│       │   ├── TransactHistoryRepository.java
│       │   └── PaymentHistoryRepository.java
│       ├── helpers/
│       │   ├── Token.java                      ← UUID token generator
│       │   ├── GenAccountNumber.java           ← Random account number generator
│       │   ├── HTML.java                       ← HTML email template builder
│       │   └── authorization/
│       │       └── JwtService.java             ← JWT generation & validation
│       ├── interceptors/
│       │   └── AppInterceptor.java             ← JWT auth guard for protected routes
│       ├── mailMessenger/
│       │   └── MailMessenger.java              ← HTML email sender
│       ├── exception/
│       │   ├── CustomError.java                ← Custom exception with HTTP status code
│       │   └── GlobalExceptionHandler.java     ← @ControllerAdvice error handler
│       └── controller_advisor/
│           └── AdvisorController.java
```

---

## Architecture Overview

```
Client (React / Postman)
        │
        │  HTTP + Authorization: Bearer <JWT>
        ▼
┌──────────────────────┐
│    AppInterceptor    │  ← Validates JWT on all protected routes
│    (pre-handle)      │    Loads user into HTTP session
└────────┬─────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────┐
│                     Controllers                       │
│  RegisterController  AuthController  IndexController  │
│  AppController  AccountController  TransactController │
└──────────────────────────┬───────────────────────────┘
                           │  (No dedicated service layer —
                           │   business logic lives in controllers)
                           ▼
┌──────────────────────────────────────────────────────┐
│                    Repositories                       │
│  UserRepo  AccountRepo  TransactRepo  PaymentRepo     │
│  TransactHistoryRepo  PaymentHistoryRepo              │
└──────────────────────────┬───────────────────────────┘
                           │
                           ▼
                     MySQL Database
                (tables + views via JPA)
```

> Note: There is no dedicated service layer. Business logic lives directly in controllers — a common pattern in demo/learning projects.

---

## Database Schema

### Tables

**`users`**
| Column | Type | Notes |
|---|---|---|
| user_id | String | Primary key |
| first_name | String | Min 3 chars |
| last_name | String | Min 3 chars |
| email | String | Unique |
| password | String | BCrypt hashed |
| token | String | Email verification token (cleared after verify) |
| code | String | Email verification code (cleared after verify) |
| verified | int | `0` = unverified, `1` = verified |
| verified_at | LocalDate | Set on verification |
| create_at | LocalDateTime | |
| updated_at | LocalDateTime | |

**`accounts`**
| Column | Type | Notes |
|---|---|---|
| account_id | int | Primary key |
| user_id | int | FK → users |
| account_number | String | Randomly generated |
| account_name | String | |
| account_type | String | e.g. Savings, Checking |
| balance | BigDecimal | |
| create_at | LocalDateTime | |
| updated_at | LocalDateTime | |

**`transaction_history`**
| Column | Type | Notes |
|---|---|---|
| transaction_id | int | PK, auto-increment |
| account_id | int | |
| transaction_type | String | deposit / transfer / withdrawal / payment |
| amount | double | |
| source | String | e.g. "online" |
| status | String | success / failed |
| reason_code | String | Description |
| created_at | LocalDateTime | |

**`payments`**
| Column | Type | Notes |
|---|---|---|
| payment_id | int | PK, auto-increment |
| account_id | int | Source account |
| beneficiary | String | Recipient name |
| beneficiary_acc_no | String | Recipient account number |
| amount | double | |
| reference_no | String | |
| status | String | success / failed |
| reason_code | String | |
| created_at | LocalDateTime | |

### Database Views

| View | Purpose |
|---|---|
| `v_transaction_history` | Joins `transaction_history` with `accounts` and `users` — queried by `TransactHistoryRepository` |
| `v_payments` | Joins `payments` with `accounts` and `users` — queried by `PaymentHistoryRepository` |

---

## Class Reference

### Entry Point

#### `DemoBankV1Application.java`
Standard `@SpringBootApplication` class. Starts the embedded Tomcat server on port `8070`.

---

### Models — Entities & DTOs

#### `User.java`
JPA entity → `users` table. Represents a registered bank user. Carries Bean Validation annotations (`@NotEmpty`, `@Email`, `@Size`). The `verified` field (0/1) gates login — users must verify their email before they can log in.

#### `Account.java`
JPA entity → `accounts` table. One user can own multiple accounts. Balance stored as `BigDecimal` for precision.

#### `Transact.java`
JPA entity → `transaction_history` table. **Write-only.** Every deposit, withdrawal, transfer, or payment creates a row here as an audit trail.

#### `Payment.java`
JPA entity → `payments` table. **Write-only.** Records each external payment's beneficiary, amount, status, and reference number.

#### `TransactionHistory.java`
JPA entity → `v_transaction_history` **database view**. **Read-only.** Used to query enriched transaction records joined with user data.

#### `PaymentHistory.java`
JPA entity → `v_payments` **database view**. **Read-only.** Used to query payment records joined with user data.

#### `TransferRequest.java`
Non-JPA DTO. Request body for `POST /transact/transfer`.
Fields: `sourceAccount`, `targetAccount`, `amount`

#### `PaymentRequest.java`
Non-JPA DTO. Request body for `POST /transact/payment`.
Fields: `beneficiary`, `account_number`, `account_id`, `reference`, `payment_amount`

---

### Repositories

All repositories extend `CrudRepository` and use `@Query` with native SQL for custom operations.

#### `UserRepository`
| Method | SQL Operation |
|---|---|
| `getUserEmail(email)` | SELECT email |
| `getUserPassword(email)` | SELECT password |
| `isVerified(email)` | SELECT verified |
| `getUserDetails(email)` | SELECT * |
| `registerUser(...)` | INSERT new user |
| `verifyAccount(token, code)` | UPDATE verified=1, clear token/code |
| `checkToken(token)` | SELECT to validate token |

#### `AccountRepository`
| Method | SQL Operation |
|---|---|
| `getUserAccountsById(user_id)` | SELECT all accounts for user |
| `getTotalBalance(user_id)` | SUM of all account balances |
| `getAccountBalance(user_id, account_id)` | SELECT single account balance |
| `changeAccountsBalanceById(new_balance, account_id)` | UPDATE balance |
| `createBankAccount(...)` | INSERT new account |

#### `TransactRepository`
| Method | SQL Operation |
|---|---|
| `logTransaction(...)` | INSERT transaction record |

#### `PaymentRepository`
| Method | SQL Operation |
|---|---|
| `makePayment(...)` | INSERT payment record |

#### `TransactHistoryRepository`
| Method | SQL Operation |
|---|---|
| `getTransactionRecordsById(user_id)` | SELECT from view by user |
| `getTransactionRecordsByAccountId(account_id)` | SELECT from view by account |

#### `PaymentHistoryRepository`
| Method | SQL Operation |
|---|---|
| `getPaymentsRecordsById(user_id)` | SELECT from view by user |

---

### Controllers

#### `RegisterController` — `POST /register`
Registers a new user.

1. Validate all fields (not empty, password matches confirm password).
2. Generate a UUID verification `token` and a random numeric `code`.
3. BCrypt-hash the password.
4. INSERT user into DB (`verified = 0`).
5. Build an HTML email with the verification link and send it.
6. Return success message.

Request body:
```json
{
  "first_name": "string",
  "last_name": "string",
  "email": "string",
  "password": "string",
  "confirm_password": "string"
}
```

---

#### `AuthController`

**`POST /login`** — Authenticate user.

1. Validate email and password not empty.
2. Check email exists in DB.
3. Validate password with `BCrypt.checkpw()`.
4. Check `verified = 1`.
5. Generate JWT (7-day expiry).
6. Store user object and JWT in HTTP session.
7. Return JWT.

Request body:
```json
{ "email": "string", "password": "string" }
```

Response:
```json
{ "message": "Authentication confirmed", "access_token": "<JWT>" }
```

**`GET /logout`** — Invalidate the HTTP session.

---

#### `IndexController`

**`GET /`** — Returns a greeting string (health check).

**`GET /verify?token=xxx&code=yyy`** — Verify email address.

1. Look up token in DB.
2. Set `verified = 1`, clear `token` and `code`.
3. Return success.

---

#### `AppController` — `/app/*` (JWT required)

**`GET /app/dashboard`**
Returns all accounts for the logged-in user plus their total balance.

**`GET /app/payment_history`**
Returns all payment records for the user (from `v_payments` view).

**`GET /app/transaction_history`**
Returns all transaction records for the user (from `v_transaction_history` view).

**`POST /app/account_transaction_history`**
Returns transactions for one specific account.
Body: `{ "account_id": "123" }`

---

#### `AccountController` — `/account/*` (JWT required)

**`POST /account/create_account`**
Creates a new bank account for the user.

1. Validate `account_name` and `account_type` not empty.
2. Generate random account number.
3. INSERT account record (balance = 0).
4. Return updated list of all user accounts.

Body: `{ "account_name": "string", "account_type": "string" }`

---

#### `TransactController` — `/transact/*` (JWT required)

**`POST /transact/deposit`**
Adds funds to an account.

1. Validate amount > 0.
2. `newBalance = currentBalance + depositAmount`
3. UPDATE account balance.
4. Log transaction (`type=deposit`, `status=success`).
5. Return updated accounts.

Body: `{ "deposit_amount": "100.50", "account_id": "123" }`

---

**`POST /transact/transfer`**
Moves funds between two accounts belonging to the same user.

1. Validate source ≠ target, amount > 0.
2. Check source account has sufficient funds.
3. Deduct from source, add to target.
4. UPDATE both balances.
5. Log transaction.
6. Return updated accounts.

Body: `{ "sourceAccount": "123", "targetAccount": "456", "amount": "50.00" }`

---

**`POST /transact/withdraw`**
Withdraws funds from an account.

1. Validate amount > 0.
2. Check sufficient funds.
3. `newBalance = currentBalance - withdrawalAmount`
4. UPDATE balance.
5. Log transaction.
6. Return updated accounts.

Body: `{ "withdrawal_amount": "100.00", "account_id": "123" }`

---

**`POST /transact/payment`**
Pays an external beneficiary.

1. Validate all fields, amount > 0.
2. Check sufficient funds.
3. If **insufficient**: log failed payment record, log failed transaction, return 400 error.
4. If **sufficient**: deduct amount, UPDATE balance, INSERT payment record, log transaction.
5. Return updated accounts.

Body:
```json
{
  "beneficiary": "string",
  "account_number": "string",
  "account_id": "123",
  "reference": "string",
  "payment_amount": "100.00"
}
```

---

### Security & Authentication

#### `JwtService.java`
Located at `helpers/authorization/JwtService.java`. Uses JJWT with HS256.

| Method | Purpose |
|---|---|
| `generateToken(userEmail)` | Creates a signed JWT with email as subject, 7-day expiry |
| `decodeToken(token)` | Parses and validates JWT signature/expiry |
| `isTokenIncluded(header)` | Checks if `Authorization` header is present |
| `getAccessTokenFromHeader(header)` | Strips `Bearer ` prefix to extract raw token |

JWT secret is read from `application.properties` via `@Value("${demoBank.app.secret}")`.

#### `AppInterceptor.java`
Implements `HandlerInterceptor`. Registered for: `/app/*`, `/transact/*`, `/logout`, `/account/*`.

**Pre-handle flow on every protected request:**
1. Check if URI matches a protected pattern.
2. Read the `Authorization` header — return **401** if missing.
3. Extract and decode the JWT.
4. Get email from token subject.
5. Load the `User` from DB by email.
6. Store the `User` in the HTTP session.
7. Allow request to proceed to the controller.

#### Password Security
BCrypt via `spring-security-crypto`.
- Registration: `BCrypt.hashpw(password, BCrypt.gensalt())`
- Login: `BCrypt.checkpw(rawPassword, hashedPassword)`

---

### Helpers

#### `Token.java`
`generateToken()` — Returns `UUID.randomUUID().toString()`. Used for email verification tokens.

#### `GenAccountNumber.java`
`generateAccountNumber()` — Returns `1000 * random(1000)` as an integer. Used when creating new accounts.

#### `HTML.java`
`htmlEmailTemplate(String token, String code)` — Builds the HTML body for the verification email. Verification link points to `http://127.0.0.1:8070/verify?token=xxx&code=yyy`.

#### `MailMessenger.java`
`htmlEmailMessenger(from, to, subject, body)` — Sends an HTML MIME email using the injected `JavaMailSender`.

---

### Configuration

#### `AppConfig.java`
- Registers `AppInterceptor` for protected URL path patterns.
- Configures `InternalResourceViewResolver` for JSP views (prefix: `/WEB-INF/jsp/`, suffix: `.jsp`).
- Defines a `CorsFilter` bean:
  - Allowed origin: `http://localhost:3000/`
  - Credentials: enabled
  - Headers: all
  - Methods: all

#### `MailConfig.java`
Configures `JavaMailSender` for local SMTP on `localhost:25`.
Default dev credentials: `developer@beko.com` / `1234`.

---

### Exception Handling

#### `CustomError.java`
Extends `RuntimeException`. Carries an integer HTTP status code. Thrown by `AppInterceptor` when authentication fails (status 401).

#### `GlobalExceptionHandler.java`
`@ControllerAdvice` — catches `CustomError` exceptions and responds with the appropriate HTTP status code.

#### `AdvisorController.java`
Additional controller advice in the `controller_advisor` package.

---

## API Endpoints

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `GET` | `/` | No | Health check |
| `POST` | `/register` | No | Register a new user |
| `GET` | `/verify?token=&code=` | No | Email verification |
| `POST` | `/login` | No | Authenticate, returns JWT |
| `GET` | `/logout` | Yes | Invalidate session |
| `GET` | `/app/dashboard` | Yes | List accounts + total balance |
| `GET` | `/app/payment_history` | Yes | User's payment history |
| `GET` | `/app/transaction_history` | Yes | User's transaction history |
| `POST` | `/app/account_transaction_history` | Yes | Transactions for one account |
| `POST` | `/account/create_account` | Yes | Create a new bank account |
| `POST` | `/transact/deposit` | Yes | Deposit funds |
| `POST` | `/transact/transfer` | Yes | Transfer between accounts |
| `POST` | `/transact/withdraw` | Yes | Withdraw funds |
| `POST` | `/transact/payment` | Yes | Pay external beneficiary |

**Auth header format:** `Authorization: Bearer <JWT_TOKEN>`

---

## Application Flows

### 1. Registration & Email Verification

```
Client
  │── POST /register ──────────────────────────────────────────────────────┐
  │   {first_name, last_name, email, password, confirm_password}           │
  │                                         RegisterController             │
  │                                           ├── Validate inputs          │
  │                                           ├── Match passwords          │
  │                                           ├── Generate UUID token      │
  │                                           ├── Generate numeric code    │
  │                                           ├── BCrypt hash password     │
  │                                           ├── INSERT user (verified=0) │
  │                                           └── Send HTML email          │
  │◄── 200 {message: "Registration success. Check your email."} ───────────┘
  │
  │ (User clicks link in email)
  │── GET /verify?token=xxx&code=yyy ──────────────────────────────────┐
  │                                       IndexController              │
  │                                         ├── checkToken(token)     │
  │                                         └── verifyAccount(token,code)│
  │                                              └── SET verified=1   │
  │◄── 200 {message: "Verification success."} ─────────────────────────┘
```

### 2. Login & JWT Authentication

```
Client
  │── POST /login ──────────────────────────────────────────────────┐
  │   {email, password}                                             │
  │                                    AuthController               │
  │                                      ├── getUserEmail()         │
  │                                      ├── BCrypt.checkpw()       │
  │                                      ├── isVerified()           │
  │                                      ├── generateToken(email)   │
  │                                      └── Store in session       │
  │◄── 200 {access_token: "<JWT>"} ──────────────────────────────────┘
```

### 3. Protected Request Flow

```
Client
  │── GET /app/dashboard ──────────────────────────────────────────────┐
  │   Authorization: Bearer <JWT>                                      │
  │                                  AppInterceptor                   │
  │                                    ├── Extract JWT from header     │
  │                                    ├── decodeToken()               │
  │                                    ├── getUserDetails(email)       │
  │                                    └── Store User in session       │
  │                                  AppController                    │
  │                                    ├── Get User from session       │
  │                                    ├── getUserAccountsById()       │
  │                                    └── getTotalBalance()           │
  │◄── 200 {userAccounts: [...], totalBalance: 1234.56} ───────────────┘
```

### 4. Deposit Flow

```
Client
  │── POST /transact/deposit ──────────────────────────────────────────┐
  │   {deposit_amount: "100.00", account_id: "5"}                      │
  │   Authorization: Bearer <JWT>                                      │
  │                                  AppInterceptor (auth check)      │
  │                                  TransactController               │
  │                                    ├── Validate amount > 0        │
  │                                    ├── getAccountBalance()         │
  │                                    ├── newBal = old + deposit      │
  │                                    ├── changeAccountsBalance()     │
  │                                    ├── logTransaction(success)     │
  │                                    └── getUserAccountsById()       │
  │◄── 200 {message: "Amount Deposited Successfully.", accounts:[...]} ┘
```

### 5. Payment Flow (with insufficient-funds path)

```
Client
  │── POST /transact/payment ──────────────────────────────────────────┐
  │   {beneficiary, account_number, account_id, reference,             │
  │    payment_amount}                                                 │
  │                                  TransactController               │
  │                                    ├── Validate inputs             │
  │                                    ├── getAccountBalance()         │
  │                                    ├── IF balance < amount:        │
  │                                    │     makePayment(failed)       │
  │                                    │     logTransaction(failed)    │
  │                                    │     return 400 error ─────────┤
  │                                    └── ELSE:                       │
  │                                          changeAccountsBalance()   │
  │                                          makePayment(success)      │
  │                                          logTransaction(success)   │
  │◄── 200 {message: "Payment Processed Successfully!", accounts:[...]}┘
     OR
  ◄── 400 {error: "Insufficient funds"}
```

### 6. Transfer Flow

```
Client
  │── POST /transact/transfer ─────────────────────────────────────────┐
  │   {sourceAccount: "5", targetAccount: "6", amount: "200.00"}       │
  │                                  TransactController               │
  │                                    ├── Validate source ≠ target    │
  │                                    ├── Validate amount > 0         │
  │                                    ├── getAccountBalance(source)   │
  │                                    ├── Check sufficient funds       │
  │                                    ├── getAccountBalance(target)   │
  │                                    ├── UPDATE source (deduct)      │
  │                                    ├── UPDATE target (add)         │
  │                                    ├── logTransaction(success)     │
  │                                    └── getUserAccountsById()       │
  │◄── 200 {message: "Transfer completed successfully.", accounts:[...]}┘
```

---

## Setup & Running

### Prerequisites

- Java 8+
- Maven
- MySQL running on `localhost:3306`
- Local SMTP server on `localhost:25` (for email verification)

### 1. Database Setup

```sql
CREATE DATABASE demo_bank_v1;
```

Hibernate will auto-create the tables on first run (`spring.jpa.hibernate.ddl-auto=update`).

After first run, create the required views:

```sql
-- Transaction history view
CREATE OR REPLACE VIEW v_transaction_history AS
  SELECT t.*, a.user_id
  FROM transaction_history t
  JOIN accounts a ON t.account_id = a.account_id;

-- Payments view
CREATE OR REPLACE VIEW v_payments AS
  SELECT p.*, a.user_id
  FROM payments p
  JOIN accounts a ON p.account_id = a.account_id;
```

### 2. Configure `application.properties`

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/demo_bank_v1
spring.datasource.username=root
spring.datasource.password=your_password
```

### 3. Run

```bash
cd "Online Banking App Spring Boot"
./mvnw spring-boot:run
```

App starts at: `http://127.0.0.1:8070`

### 4. Quick Test (curl)

```bash
# Register
curl -X POST http://localhost:8070/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"John","last_name":"Doe","email":"john@example.com","password":"secret123","confirm_password":"secret123"}'

# Login (after email verification)
curl -X POST http://localhost:8070/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"secret123"}'

# Dashboard (use token from login response)
curl http://localhost:8070/app/dashboard \
  -H "Authorization: Bearer <JWT_TOKEN>"
```
