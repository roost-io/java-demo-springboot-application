# Business Use Cases

This section details the end-to-end business use cases for DemoBank's online banking system, integrating system flows, user perspectives, business rules, actors, and acceptance criteria. Each use case ties directly to endpoints, tested scenarios (Gherkin feature summaries), and validated flows per the OpenAPI specification.

---

## 1. Account Creation

### User Stories

- **As a new customer**, I want to create a bank account so that I can perform banking transactions online.
- **As a system admin**, I want to ensure all account creations are properly validated and logged.

### Acceptance Criteria

- The user provides all mandatory data (name, email, phone, password, etc.).
- The system verifies data validity and uniqueness (e.g., unique email/username).
- Upon success, the account is created in a 'pending verification' state.
- The user receives an account creation confirmation along with a verification process initiation.
- Error messages are presented for missing or invalid fields.

### Business Rules & Constraints

- All required fields must be supplied, and must pass format validation (e.g. valid email, password complexity).
- Duplicate email or phone numbers are not allowed.
- Created accounts remain inactive until verified.
- System must log attempts (both successful and failed) for audit purposes.

### Actors

- **Customer (User):** Initiates account creation.
- **Admin:** Monitors for compliance and addresses registration issues.
- **External Email/SMS Provider:** Delivers verification email/SMS.

---

## 2. Registration & Verification

### User Stories

- **As a new user**, I want to register and verify my account so that I gain access to the online banking system.
- **As the system**, I want to enforce multi-factor account validation to improve security.

### Acceptance Criteria

- Upon registration, a verification code/link is sent via email/SMS.
- The user submits the correct verification code or clicks the verification link.
- Verified accounts are marked as 'active'; if fail, remain 'pending' or get 'locked' after maximum attempts.
- User receives confirmation of successful verification.
- Incorrect or expired codes result in a clear error message.

### Business Rules & Constraints

- Verification links/codes expire after a configured period (e.g., 24 hours).
- A maximum number of verification attempts is enforced.
- Upon repeated failure, account entry may be locked pending admin intervention.

### Actors

- **Customer (User):** Completes verification, receives notification.
- **External Email/SMS Provider:** Delivers verification.
- **Admin:** Unlocks or re-verifies accounts if needed.

---

## 3. Login/Logout

### User Stories

- **As a registered user**, I want to securely log in and out so that my account and transactions are safe.
- **As the system**, I ensure inactive/locked accounts cannot log in.

### Acceptance Criteria

- User provides valid username and password.
- Only accounts that are both active and verified can log in.
- Upon success, a session or JWT token is issued.
- User can log out, which destroys the session/token.
- Incorrect credentials or locked accounts are rejected with appropriate error messages.

### Business Rules & Constraints

- Passwords must be stored securely (e.g., hashed & salted).
- Logins are logged for audit and fraud detection.
- After a configurable number of failed attempts, the account is locked.
- Password reset flow is available if user forgets password.

### Actors

- **Customer (User):** Authenticates to the system.
- **Admin:** Views login attempts, unlocks accounts.
- **Authentication Service:** Issues and validates tokens/session.

---

## 4. Dashboard & Balance Inquiry

### User Stories

- **As a logged-in user**, I want to view my account dashboard and real-time balances so that I can manage my finances.
- **As the system**, I restrict dashboard/balance access to authenticated users only.

### Acceptance Criteria

- User is authenticated before access is granted.
- Dashboard displays current balances for all linked accounts.
- User sees recent activity summaries (last N transactions per account).
- Data is up-to-date and accurate per the account ledger.

### Business Rules & Constraints

- Balance information must reflect all cleared and pending transactions.
- Only accounts owned by a user are listed.
- No sensitive information beyond configured data is displayed.

### Actors

- **Customer (User):** Views dashboard and balances.
- **Account Service:** Computes and serves requested data.

---

## 5. Deposit, Withdraw, Payment, & Transfer

### User Stories

- **As a user**, I want to deposit to, withdraw from, or transfer money between accounts, or make payments so that I can manage my finances.
- **As the system**, I enforce transaction limits, validate recipient/payee details, and ensure funds sufficiency.

### Acceptance Criteria

- Only logged-in, active, and verified users can initiate transactions.
- Transaction requests validate required fields, amount, and sufficient balance (for outgoing transactions).
- Deposits increase balance; withdrawals/payments/transfers debit accordingly.
- For transfers and payments, recipient info is checked (valid account/external payee).
- Transactions are atomic—either fully succeed (with updated balances & entry in transaction history), or failure is rolled back.
- User sees clear success or error confirmation, including reason for any failure.

### Business Rules & Constraints

- Minimum and maximum amounts per operation are enforced (configurable per bank policy).
- Overdrafts are not allowed unless account is configured explicitly.
- All transactions are timestamped and recorded in transaction history.
- Daily and per-transaction limits are enforced.
- Additional 2-factor confirmation may be required above certain thresholds.
- Suspicious or repeated failed attempts are logged and may trigger security rules.

### Actors

- **Customer (User):** Initiates all types of transactions.
- **Account Service:** Validates, processes, and records transactions.
- **Admin:** Monitors for fraud, reviews/approves flagged transactions.
- **External Payment Systems:** (for payment endpoints) Process external payments.

---

## 6. Payment & Transaction History

### User Stories

- **As a user**, I want to review my transaction history so that I can track deposits, withdrawals, payments, and transfers.
- **As the system**, I ensure only the account owner can view sensitive transaction data.

### Acceptance Criteria

- User is authenticated and authorized for target account's data.
- The endpoint returns a paginated, filterable (by date/type/amount) list of all past transactions.
- Transaction data includes amount, type, date, status, and description.
- User can view transaction details and export summaries.

### Business Rules & Constraints

- Only account holders and authorized admins can view transaction details.
- Sensitive information (such as payee details for certain transaction types) is masked as per privacy policy.
- History reflects all cleared and pending transactions and is immutable.
- Transactions recorded in strict chronological order.

### Actors

- **Customer (User):** Reviews and exports transaction history.
- **Account Service:** Provides secure, filtered transaction data.
- **Admin:** Audits transaction records.

---

## Actor Descriptions

- **Customer (User):** Individual bank customers using the DemoBank online platform for personal financial management.
- **Admin:** Bank staff authorized to manage accounts, monitor for compliance/security, resolve user issues.
- **External Systems:** Trusted third parties such as payment gateways, SMS/email providers, and regulatory auditing systems.

---

## General Business Rules & Constraints

- All major user flows are protected by authentication and authorization per endpoint.
- Changes to user/profile/financial data are auditable and logged.
- Data privacy and security are enforced per financial regulations (e.g., PCI DSS, GDPR).
- All endpoints adhere to the API contract described in OpenAPI documentation.
- System must provide meaningful error codes and descriptions per failure case.
- All monetary operations use the system's currency configuration, and amounts are processed with correct precision/rounding.

---

*End of Business Use Cases Section*
