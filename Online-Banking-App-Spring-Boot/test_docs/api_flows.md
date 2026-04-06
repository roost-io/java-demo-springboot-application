# API Flows

This section describes the end-to-end API flows for core DemoBank use cases, detailing stepwise API calls, data flow, important model state changes, and integration points. Each flow references the corresponding [Gherkin-tested scenarios](gherkin_scenarios/) and uses the [OpenAPI endpoints](../openapi.json) and [Data Models](../README.md).

---

## 1. User Registration & Verification Flow
### Overview
A new user proceeds from registration, receives a verification code, and verifies their account to enable login.

#### Stepwise Call Sequence

1. **Register User**
   - POST `/register`
   - Input: email, password, name, optional KYC fields.
   - Output: User record (`pending_verification`). Verification sent to email.
2. **Verify Email**
   - GET `/verify?token=...&code=...`
   - Input: verification code and token
   - Output: Status updated to `active` (on success).
3. **Edge Cases & Error Handling**
   - Invalid/expired code (400/410); already verified (409)

#### Data Flow
- User created with status `pending_verification`
- On successful verification: status updated to `active`

---

## 2. Login & Logout Flow
### Overview
Users authenticate using credentials and receive JWT token for session.

#### Stepwise Call Sequence

1. **Login**
   - POST `/login`
   - Input: email, password
   - Output: access_token, user profile
2. **Edge/Error Cases**
   - Wrong password (401); unverified/locked account (403/423/401)
3. **Logout**
   - GET `/logout` (Authorization header)
   - Output: Success message; token invalidated

---

## 3. Dashboard Retrieval
### Overview
Authenticated users access dashboard for account overview.

#### Stepwise Call Sequence

1. **Fetch Dashboard**
   - GET `/app/dashboard` (Authorization)
   - Output: userAccounts, totalBalance, summary
2. **Edge Cases**
   - Token invalid/expired (401); server errors (500)

---

## 4. Account Creation Flow
### Overview
Authenticated users create new bank accounts for themselves.

#### Stepwise Call Sequence

1. **Create Account**
   - POST `/account/create_account`
   - Input: account_name, account_type
   - Output: new Account object
2. **Edge Cases**
   - Duplicate (409), missing fields (400), invalid type (400), unauthenticated (401)

---

## 5. Payment & Transaction History Retrieval
### Overview
Users view all payment and transaction histories for their accounts.

#### Stepwise Call Sequence

1. **Get Payment History**
   - GET `/app/payment_history` (Authorization)
   - Output: list of PaymentHistory objects
2. **Get Transaction History**
   - GET `/app/transaction_history` OR POST `/app/account_transaction_history` with account_id
   - Output: list of TransactionHistory
3. **Edge Cases**
   - Unauthorized (401), forbidden (403), invalid account_id (400)
   - Empty collections handled gracefully

---

## 6. Deposit Funds Flow
### Overview
User deposits funds into an account.

#### Stepwise Call Sequence

1. **Deposit**
   - POST `/transact/deposit`
   - Input: deposit_amount, account_id
   - Output: updated Account object or deposit status
2. **Edge/Error**
   - Unauthenticated (401), invalid account (404), invalid/negative amount (400)

---

## 7. Withdrawal Flow
### Overview
Withdraw funds from a user account.

#### Stepwise Call Sequence

1. **Withdraw**
   - POST `/transact/withdraw`
   - Input: withdrawal_amount, account_id
   - Output: updated Account, withdrawal status
2. **Edge Cases**
   - Insufficient funds (409/422); unauthorized (401); invalid fields (400)

---

## 8. Send Payment / Transfer Funds Flow
### Overview
Transfer money between accounts, or send payment to a payee.

#### Stepwise Call Sequence

1. **Transfer**
   - POST `/transact/transfer` (TransferRequest)
   - Input: sourceAccount, targetAccount, amount
   - Output: updated accounts after transfer
2. **Payment**
   - POST `/transact/payment` (PaymentRequest)
   - Input: beneficiary, account_number, reference, payment_amount
   - Output: payment status, updated accounts
3. **Edge Cases**
   - Invalid/unauthenticated (401/403), insufficient funds (409), bad input (400)

---

## Error Handling & Integration Points
- Authentication via JWT for all protected endpoints
- State transitions: Account balances, user status
- Integration: Email/SMS for verification, payment gateways for external payments
- Response codes: 200/201 (success), 400/401/403/409/422 (errors)

---

*Flows map directly against Gherkin scenarios and OpenAPI endpoints/models for traceability.*
