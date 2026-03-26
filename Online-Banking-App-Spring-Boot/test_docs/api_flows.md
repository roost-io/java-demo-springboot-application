# DemoBank_v1 API End-to-End Flow Documentation

## Table of Contents

1. [User Registration](#user-registration)
2. [User Authentication](#user-authentication)
3. [Account Management](#account-management)
4. [Deposit, Withdraw, Transfer, Payment](#transaction-flows)
5. [Dashboard & Transaction History](#dashboard-and-history)

---

## 1. User Registration

### **Happy Path Flow**

| Step | API Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|--------------|------------|--------------|----------------------|------------------|
| 1    | `POST /register` | `RegisterController` | Input: user details (first/last name, email, password, confirm_password)<br>Output: success message, user data | New user record created in DB | `gherkin_RegisterController.feature`<br>Scenario: Successful registration |

#### Flow Details
1. Client submits user details to `/register`.
2. System validates (unique email, input formats, matching passwords).
3. On success, user is persisted; verification info included in response.

#### **Error Flows**

| Scenario | Error Response | Handling |
|----------|---------------|----------|
| Duplicate/invalid email | `400 BAD REQUEST`, relevant message | Client must correct input |
| Password issues (short/long/mismatch) | `400 BAD REQUEST`, relevant message | Client corrects input |
| Field validation errors | `400 BAD REQUEST` | See validation coverage |

#### **Authentication State**
- Not required for registration.

#### **Integration Points**
- Enables login flow upon success.

---

## 2. User Authentication

### **Happy Path Flow**

| Step | API Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|--------------|------------|--------------|----------------------|------------------|
| 1    | `POST /login` | `AuthController` | Input: email, password<br>Output: token/session | Session is created | `gherkin_AuthController.feature`<br>Scenario: Successful login |
| 2    | `GET /logout` | `AuthController` | Input: sessionParam<br>Output: logout message | Session is expired/invalidated | Scenario: Successful logout |

#### Flow Details
1. Client authenticates via `/login`, receives session/token on success.
2. All subsequent protected API calls include sessionParam (header, cookie, etc.).
3. Logout via `/logout` invalidates session.

#### **Error Flows**

| Scenario | Error Response | Handling |
|----------|---------------|----------|
| Incorrect credentials | `401 UNAUTHORIZED` w/ error message | Client reattempts/login |
| Unverified/not found user | `403 FORBIDDEN` or `500 ERROR` | Client follows instructions |
| Missing fields | `400 BAD REQUEST` | Input correction needed |

#### **Authentication State**
- Required for all user/account/transactional endpoints.
- Session/token provided post login; must be used post-authentication.

#### **Integration Points**
- Drives authorized flows such as account, transaction, dashboard requests.

---

## 3. Account Management

### **Happy Path Flow**

| Step | API Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|--------------|------------|--------------|----------------------|------------------|
| 1    | `POST /account/create_account` | `AccountController` | Input: account_name, account_type<br>Output: accounts list | New account added to user | `gherkin_AccountController.feature`<br>Scenario: Successful account creation |

#### Flow Details
1. Authenticated user calls `/account/create_account` with valid data.
2. Account is created and linked; all account data returned.

#### **Error Flows**

| Scenario | Error Response | Handling |
|----------|---------------|----------|
| Missing fields (name/type) | `400 BAD REQUEST` | User corrects input |
| Unauthenticated request | `401 UNAUTHORIZED` | Login required |

#### **Authentication State**
- SessionParam required; enforced in both code and Gherkin features.

#### **Integration Points**
- Created accounts used for all transaction endpoints.

---

## 4. Deposit, Withdraw, Transfer, Payment

### **Deposit Flow (Happy Path)**

| Step | API Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|--------------|------------|--------------|----------------------|------------------|
| 1    | `POST /transact/deposit` | `TransactController` | Input: deposit_amount, account_id<br>Output: account balances | Balance updated (+) | `gherkin_TransactController.feature`<br>Scenario: Deposit funds successfully |

### **Withdraw Flow (Happy Path)**

| Step | Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|----------|------------|--------------|----------------------|------------------|
| 1    | `POST /transact/withdraw` | `TransactController` | Input: withdrawal_amount, account_id<br>Output: account balances | Balance updated (-) | Scenario: Withdraw funds successfully |

### **Transfer Flow (Happy Path)**

| Step | Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|----------|------------|--------------|----------------------|------------------|
| 1    | `POST /transact/transfer` | `TransactController` | Input: sourceAccount, targetAccount, amount<br>Output: accounts balances | Two balances updated | Scenario: Transfer funds successfully |

### **Payment Flow (Happy Path)**

| Step | Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|----------|------------|--------------|----------------------|------------------|
| 1    | `POST /transact/payment` | `TransactController` | Input: beneficiary, account_number, reference, payment_amount, account_id<br>Output: account balances | Balance updated (-), payment recorded | Scenario: Process payment successfully |

#### **Error Flows**

| Scenario | Error Response | Handling |
|----------|---------------|----------|
| Insufficient funds | `400 BAD REQUEST` | Transaction refused; error shown |
| Zero/negative/invalid amount | `400 BAD REQUEST` | As above |
| Wrong/missing fields | `400 BAD REQUEST` | Correction needed |
| Unauthenticated | `401 UNAUTHORIZED` | Require login |
| Transfers to same account | `400 BAD REQUEST` | Client must change input |

#### **Authentication State**
- Required for all endpoints (sessionParam checked).

#### **Integration Points**
- Transfers/payments update and depend on current account balances (validated each operation).
- Payment references may be used for cross-service integrations (future/external billers).

---

## 5. Dashboard and History

### **Happy Path Flow**

| Step | API Endpoint | Controller | Input/Output | State/Data Transition | Feature Reference |
|------|--------------|------------|--------------|----------------------|------------------|
| 1    | `GET /app/dashboard` | `AppController` | Input: sessionParam<br>Output: accounts & total balance | Data retrieved only for auth'd user | `gherkin_AppController.feature`<br>Scenario: Retrieve dashboard data when user has accounts |
| 2    | `GET /app/payment_history` | `AppController` | Input: sessionParam<br>Output: payment history list | Shows historical payments | Scenario: Get payment history when payments exist |
| 3    | `GET /app/transaction_history` | `AppController` | Input: sessionParam<br>Output: transaction history | As above |
| 4    | `POST /app/account_transaction_history` | `AppController` | Input: account_id (JSON), sessionParam<br>Output: account-scoped history | Account filter applied | Scenario: Retrieve transaction history for a valid account |

#### **Error Flows**

| Scenario | Error Response | Handling |
|----------|---------------|----------|
| Unauthenticated | `401 UNAUTHORIZED` | Login required |
| Access to wrong account | Not explicitly covered | Authorization expected |

#### **Authentication State**
- SessionParam required, enforced.

#### **Integration Points**
- All historical/summary views reflect output of transaction endpoints.
- Dashboard aggregates account/balance details, cross-controller.

---

## **Authentication & Session Management**

- All protected endpoints check for sessionParam/token; required for all account and transaction actions.
- Post-login, sessionParam must be used in every subsequent request.
- Session invalidation on logout prevents access until re-auth.

---

## **Integration Points & Data Dependencies**

- Account existence/ownership validated in both AccountController and TransactController operations.
- Histories and dashboard aggregate persistent state from accounts and transactional logs.
- Payment endpoints may serve as integration points with external systems in the future.

---

## **Feature Scenario Cross-References**

- Each flow and error scenario link directly to tested Gherkin feature files, ensuring test-driven documentation and traceability.

---

## **Summary**

End-to-end API process flows, happy and negative paths, state transitions, error handling, and major integration points are confirmed and enforced by DemoBank_v1's feature files, endpoint implementations, and session requirements. This flow documentation ensures system behavior can be reproduced and tested stepwise for each business process.