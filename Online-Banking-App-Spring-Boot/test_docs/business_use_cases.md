# Digital Banking API System — Business Use Cases

This document describes the business use cases implemented by the API endpoints, models, and Gherkin scenarios provided.

---

## 1. Account Management

### User Stories / Goals

- As a user, I want to create a new bank account so I can deposit and manage my funds.
- As a bank, I want to enforce account creation rules to guarantee valid onboarding.

### Acceptance Criteria (from `gherkin_account.feature`)

- Account can be created with all required fields supplied.
- Attempts to create an account with missing/invalid fields are rejected.
- Cannot create duplicate accounts for the same user.
- Account creation available only for authenticated users.

### Business Rules & Constraints

- **Validations:** All required fields (e.g., account_name, account_type) must be present and valid.
- **Uniqueness:** Only one active account per user for a given account type.
- **Authorization:** Only logged-in users can create accounts.
- **Error Handling:** Clear messages for missing fields, duplicates, or unauthorized access.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoints:** `/account/create_account`
- **Models:** `Account`
- **Gherkin:** `gherkin_account.feature` (`Account creation`, `Field validation`, `Unauthenticated access`)

---

## 2. Dashboard Data

### User Stories / Goals

- As a user, I want to view my dashboard to see my account balances and summaries.
- As a user, I want a centralized place to monitor my finances.

### Acceptance Criteria (from `gherkin_app.feature`)

- Dashboard displays user's current accounts and balances.
- Only the authenticated user's data is shown; not data from other users.
- Access is forbidden if the user is not logged in.

### Business Rules & Constraints

- **Authorization:** Dashboard visible only to signed-in users.
- **Data Isolation:** Only data belonging to the current user may be returned.
- **Accuracy:** All totals and balances must match underlying account data.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoint:** `/app/dashboard`
- **Models:** `User`, `Account`
- **Gherkin:** `gherkin_app.feature` (`Dashboard view`, `Unauthorized access`)

---

## 3. Payment & Transaction History

### User Stories / Goals

- As a user, I want to view lists of my past payments and transactions.
- As a user, I want to filter history by account if needed.

### Acceptance Criteria (from `gherkin_app.feature`)

- Users can see a chronological list of all their payment and transaction history.
- Users can request transaction history for a particular account.
- Unauthenticated users are denied access.
- Only the authenticated user's history is returned.

### Business Rules & Constraints

- **Authorization:** Only available to logged-in users.
- **Data Isolation:** Each user only sees their own transaction/payment history.
- **Valid Account:** For account-based queries, the account must belong to the user.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoints:** `/app/payment_history`, `/app/transaction_history`, `/app/account_transaction_history`
- **Models:** `PaymentHistory`, `TransactionHistory`
- **Gherkin:** `gherkin_app.feature` (`Payment history`, `Transaction history`, `Account transaction history`, `Unauthorized access`)

---

## 4. Authentication

### User Stories / Goals

- As a user, I want to log in to access my banking profile and accounts.
- As a user, I want to securely log out to protect my session.

### Acceptance Criteria (from `gherkin_auth.feature`)

- Login must require valid credentials (username, password).
- Upon successful login, a session is established.
- Invalid credentials result in failed login and appropriate feedback.
- Logout invalidates the user's session.
- Verification endpoint confirms authentication or denies access for invalid sessions.

### Business Rules & Constraints

- **Field Validation:** Username and password are required.
- **Error Handling:** Clear message if authentication fails.
- **Session Management:** Logout destroys session; verify checks session validity.

### Actor Roles

- User

### Covered by

- **Endpoints:** `/login`, `/logout`, `/verify`
- **Models:** `User`
- **Gherkin:** `gherkin_auth.feature` (`Login success`, `Login failure`, `Logout`, `Session verification`)

---

## 5. Registration

### User Stories / Goals

- As a new user, I want to register for online banking access.

### Acceptance Criteria (from `gherkin_auth.feature`)

- Registration requires all mandatory fields (username, password).
- Missing or invalid fields result in an error.
- Username must be unique.

### Business Rules & Constraints

- **Field Validation:** Required fields, valid formatting.
- **Uniqueness:** Username not already taken.
- **Error Handling:** Useful feedback for any validation failure.

### Actor Roles

- Prospective User

### Covered by

- **Endpoint:** `/register`
- **Models:** `User`
- **Gherkin:** `gherkin_auth.feature` (`Registration success`, `Registration failure (missing fields)`, `Registration failure (duplicate username)`)

---

## 6. Deposit

### User Stories / Goals

- As a user, I want to deposit funds into my account.

### Acceptance Criteria (from `gherkin_transact.feature`)

- User can deposit an allowed amount into their account.
- Deposit not allowed if the amount is missing, negative, or above max limit.
- Only authenticated users may deposit.
- User can only deposit into accounts they own.

### Business Rules & Constraints

- **Amount Validation:** Required, must be positive, within allowed range.
- **Ownership:** Destination account must belong to the user.
- **Authorization:** Only authenticated users may deposit.
- **Error Handling:** Clear errors for invalid amounts or unauthorized actions.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoint:** `/transact/deposit`
- **Models:** `Account`, `TransactionHistory`
- **Gherkin:** `gherkin_transact.feature` (`Deposit funds`, `Deposit validation`, `Unauthorized deposit`)

---

## 7. Withdraw

### User Stories / Goals

- As a user, I want to withdraw funds from my account.

### Acceptance Criteria (from `gherkin_transact.feature`)

- Withdrawals require sufficient account balance.
- Only positive amounts within withdrawal limits are accepted.
- Only the account owner can withdraw.
- Only authenticated users may withdraw.
- Errors shown for insufficient funds, invalid amount, or unauthorized access.

### Business Rules & Constraints

- **Balance Validation:** User cannot withdraw more than available balance.
- **Amount Validation:** Positive, present, within limits.
- **Ownership:** Must own the account.
- **Authorization:** Only signed-in users.
- **Error Handling:** Clear messages for each failure mode.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoint:** `/transact/withdraw`
- **Models:** `Account`, `TransactionHistory`
- **Gherkin:** `gherkin_transact.feature` (`Withdraw funds`, `Withdrawal fails (insufficient funds)`, `Withdrawal validation`, `Unauthorized withdrawal`)

---

## 8. Transfer

### User Stories / Goals

- As a user, I want to transfer money between my accounts or to another user's account.

### Acceptance Criteria (from `gherkin_transact.feature`)

- Source and destination accounts must both exist.
- User must own the source account.
- Sufficient funds must be available.
- Transfer amount must be valid and within limits.
- Transfers cannot be made to the same account.
- Only authenticated users can transfer.
- Appropriate errors for all validation failures.

### Business Rules & Constraints

- **Account Validation:** Both accounts must exist; source must belong to user.
- **Amount Validation:** Positive, present, within limits.
- **Edge Case:** Cannot transfer to the same account.
- **Sufficient Balance:** Source must cover the amount.
- **Authorization:** Only authenticated users.
- **Error Handling:** Errors for each failed check.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoint:** `/transact/transfer`
- **Models:** `TransferRequest`, `Account`, `TransactionHistory`
- **Gherkin:** `gherkin_transact.feature` (`Transfer funds`, `Transfer fails (insufficient funds)`, `Transfer fails (invalid accounts)`, `Transfer validation`, `Unauthorized transfer`)

---

## 9. Payment

### User Stories / Goals

- As a user, I want to make payments from my account to payees.

### Acceptance Criteria (from `gherkin_transact.feature`)

- Payments require valid payee, amount, and user authorization.
- User must have sufficient funds.
- Payment amount must be positive and within limits.
- Only account owners can make payments.
- Only authenticated users.
- Errors returned for invalid payee, insufficient funds, or unauthorized actions.

### Business Rules & Constraints

- **Payee Validation:** Payee field required and must exist.
- **Amount Validation:** Required, positive, within limits.
- **Sufficient Balance:** User must have enough funds.
- **Ownership:** Account must belong to user.
- **Authorization:** User must be signed in.
- **Error Handling:** All validation failures return descriptive errors.

### Actor Roles

- Authenticated User

### Covered by

- **Endpoint:** `/transact/payment`
- **Models:** `PaymentRequest`, `Account`, `PaymentHistory`
- **Gherkin:** `gherkin_transact.feature` (`Make payment`, `Payment fails (invalid payee)`, `Payment fails (insufficient funds)`, `Payment validation`, `Unauthorized payment`)

---

# Cross-References

- All transaction endpoints (Deposit, Withdraw, Transfer, Payment) are restricted to authenticated users, account ownership is enforced, and amount input is validated.
- Transaction and Payment history endpoints are used to review actions completed in other business areas.
- Dashboard centralizes account-level data for the authenticated user.

---

Each use case above references the concrete endpoints, models, and Gherkin scenario(s) demonstrating coverage. No requirements or interpretations have been inferred beyond the supplied evidence.
