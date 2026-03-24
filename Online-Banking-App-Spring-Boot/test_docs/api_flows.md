# Digital Banking API Flows Documentation

This document describes the primary API flows for the Digital Banking platform, covering Account Creation, Dashboard Viewing, Payment & Transaction History Retrieval, Login/Logout, Registration, Deposit, Withdraw, Transfer, and Payment. For each flow, we detail the API call sequence, input/output data, major state transitions, and error/alternate paths with cross-references to the Gherkin feature scenarios and business use cases.

---

## 1. Account Creation

### Step-by-Step API Call Sequence

1. User Registration
   - Endpoint: `POST /register`
   - Input: User registration details (from `User` model, e.g. email, password)
   - Output: Registered User object, often with verification required
   - State Change: User created in the system

2. (Optional) User Verification
   - Endpoint: `GET /verify?token=&code=`
   - Input: Email token/code
   - Output: Verification message
   - State Change: User marked as verified

3. Account Creation
   - Endpoint: `POST /account/create_account`
   - Input: Authenticated user session, account details (account_name, account_type)
   - Output: Account object(s) (e.g., list of user accounts)
   - State Change: New account added to the user's profile

### Input and Output Data Flow
- User submits registration data.
- Verifies email if required.
- Authenticates (see Login flow), requests new account.
- System returns new account info.

### State Transition
- User goes from unregistered → registered → verified
- User profile now contains the new account

### Error and Alternate Flows
- Registration: Validation errors (e.g., missing/email invalid), duplicate email
- Verification: Expired or incorrect verification tokens
- Account creation: Missing fields, invalid types, unauthorized (not logged in)

### Coverage References
- Use Cases: Registration, Account Management
- Gherkin: `gherkin_auth.feature` (registration, verification), `gherkin_account.feature` (account creation, validation, edge cases)

---

## 2. Dashboard Viewing

### Step-by-Step API Call Sequence

1. Authenticate (if required by session)
2. Retrieve Dashboard
   - Endpoint: `GET /app/dashboard`
   - Input: User session
   - Output: JSON including `userAccounts` array and `totalBalance`

### Input and Output Data Flow
- User receives all accounts and balance summary

### State Transition
- Read-only; reflects actual post-transaction account state

### Error and Alternate Flows
- Unauthorized: 401 if not authenticated
- Zero accounts: Empty `userAccounts`, `totalBalance` is zero
- Large account lists: Confirmed (tested up to 1000 accounts)

### Coverage References
- Use Case: Dashboard Data
- Gherkin: `gherkin_app.feature` (dashboard: regular, none, large; unauthorized)

---

## 3. Payment & Transaction History Retrieval

### Step-by-Step API Call Sequence

1. Authenticate
2. Retrieve Payment History
   - Endpoint: `GET /app/payment_history`
   - Output: Array `payment_history` (PaymentHistory objects)

3. Retrieve Transaction History
   - Endpoint: `GET /app/transaction_history`
   - Output: Array `transaction_history` (TransactionHistory objects)

4. Retrieve Transaction History for Account
   - Endpoint: `POST /app/account_transaction_history`
   - Input: account_id
   - Output: Array `transaction_history` for that account

### Input and Output Data Flow
- User receives structured arrays of history items (may be empty, small, or very large)

### State Transition
- Read-only

### Error and Alternate Flows
- Unauthorized: 401 if not authenticated
- Account not found (404), missing field (400)
- Valid/invalid account ID, large result set

### Coverage References
- Use Case: Payment & Transaction History
- Gherkin: `gherkin_app.feature` (all cases: regular, empty, large, unauthorized, invalid ID)

---

## 4. Login / Logout

### Step-by-Step API Call Sequence

1. Login
   - Endpoint: `POST /login`
   - Input: Credentials (email, password)
   - Output: Success message, access_token if OK; error otherwise
2. Logout
   - Endpoint: `GET /logout`
   - Input: Session token
   - Output: Success message on logout

### Input and Output Data Flow
- Credentials exchanged for session token (used in requests)
- Logout kills session

### State Transition
- Grants or removes ability to use protected endpoints

### Error and Alternate Flows
- Invalid credentials: 400/401 with error messages
- Unverified user: 403
- Missing or expired token: 401 errors
- Internal error: 500

### Coverage References
- Use Case: Authentication
- Gherkin: `gherkin_auth.feature` (login positive/negative, logout, token problems, unverified)

---

## 5. Registration

### Step-by-Step API Call Sequence

See Account Creation above for sequence (register, verify, login, create account).

### Coverage References
- Use Case: Registration
- Gherkin: `gherkin_auth.feature` (register, verify, edge-cases)

---

## 6. Deposit

### Step-by-Step API Call Sequence

1. Authenticate
2. Deposit Funds
   - Endpoint: `POST /transact/deposit`
   - Input: deposit_amount, account_id
   - Output: Message, updated account list/balances

### Input and Output Data Flow
- Amount credited to user’s account, result reflects new balances

### State Transition
- Account balance increases, transaction history updated

### Error and Alternate Flows
- Not authenticated: 401
- Empty/malformed/negative/non-numeric/invalid amount: 400
- Invalid/missing account: 400

### Coverage References
- Use Case: Deposit
- Gherkin: `gherkin_transact.feature` (deposit: all validation and errors, unauthorized)
- Dashboard & Transaction History reflect post-deposit state

---

## 7. Withdraw

### Step-by-Step API Call Sequence

1. Authenticate
2. Withdraw Funds
   - Endpoint: `POST /transact/withdraw`
   - Input: withdrawal_amount, account_id
   - Output: Message, updated accounts

### Input and Output Data Flow
- Funds debited; updated balances returned

### State Transition
- Account balance decreases, transaction history updated

### Error and Alternate Flows
- Not authenticated: 401
- Invalid/empty/non-numeric/negative amount: 400
- Insufficient funds: 400
- Invalid/missing account: 400

### Coverage References
- Use Case: Withdraw
- Gherkin: `gherkin_transact.feature` (withdraw: all validation, error, unauthorized)
- Dashboard & Transaction History reflect post-withdraw state

---

## 8. Transfer

### Step-by-Step API Call Sequence

1. Authenticate
2. Transfer Funds
   - Endpoint: `POST /transact/transfer`
   - Input: sourceAccount, targetAccount, amount
   - Output: Message, accounts array

### Input and Output Data Flow
- Funds moved from source to target; new balances reported

### State Transition
- Source balance decreases, target increases, transaction entries generated

### Error and Alternate Flows
- Not authenticated: 401
- Invalid/missing/negative/non-numeric/zero amount: 400
- Insufficient funds: 400
- Transfer to same account: 400
- Missing accounts: 400

### Coverage References
- Use Case: Transfer
- Gherkin: `gherkin_transact.feature` (transfer: happy and negative paths)
- Dashboard & Transaction History reflect post-transfer state

---

## 9. Payment

### Step-by-Step API Call Sequence

1. Authenticate
2. Make Payment
   - Endpoint: `POST /transact/payment`
   - Input: beneficiary, account_number, account_id, reference, payment_amount
   - Output: Message, updated accounts

### Input and Output Data Flow
- Funds debited for payment; updated accounts/balances returned

### State Transition
- Account debited, payment history records created

### Error and Alternate Flows
- Not authenticated: 401
- Missing, negative, or non-numeric amount: 400
- Insufficient funds: 400
- Missing/invalid payee: 400
- Invalid/missing account: 400

### Coverage References
- Use Case: Payment
- Gherkin: `gherkin_transact.feature` (all payment happy and negative paths)
- Dashboard, Payment, and Transaction History reflect post-payment state

---

## Shared State and Cross-links
- Authentication is required for all flows except registration/verification.
- Account state (balance, transaction record) is consistently updated by Deposit, Withdraw, Transfer, Payment; read by Dashboard and History retrieval.
- Errors/edge-case coverage is mainly driven by the same negative Gherkin scenarios referenced above.

---

Coverage mapped to: `gherkin_account.feature`, `gherkin_app.feature`, `gherkin_auth.feature`, `gherkin_transact.feature`, see also [Business Use Cases](business_use_cases.md).
