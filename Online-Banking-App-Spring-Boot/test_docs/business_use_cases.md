# Business Use Case Documentation

## Contents
- [Account Management](#account-management)
- [Transactions](#transactions)
- [Authentication](#authentication)
- [Registration](#registration)
- [Data Retrieval](#data-retrieval)

---

## Account Management

### Main Flows
- Create a bank account

### User Stories
| ID | Scenario | Description | Tags |
|----|----------|-------------|------|
| AM-01 | As a user, I want to create a new account so I can manage my finances. | Users can open an account. | `@smoke`, `@regression` |

*Scenario coverage from [gherkin_account.feature](../gherkin_scenarios/gherkin_account.feature)*

### Acceptance Criteria
- Account can be created with account_name and account_type present and valid
- 400 error for missing/invalid fields
- 401 error if user is not authenticated
- Account name boundaries and invalid types are handled

| Scenario Title | Endpoint | Criteria | Tag |
|---------------|----------|----------|-----|
| Successful account creation | POST `/account/create_account` | 200 OK, account appears in returned list | `@smoke` |
| Missing account_name/type | POST `/account/create_account` | 400, error message for field presence | `@regression` |
| Non-authenticated user | POST `/account/create_account` | 401, error message for authentication | `@regression` |
| Boundary values | POST `/account/create_account` | 200 or 400, depending on value | `@regression` |

### Business Rules & Constraints
- Only authenticated users (session User) can create accounts
- Required fields: account_name, account_type (validated)
- Account model must include fields as per discovered schema

### Actor Descriptions
- **User:** End customer creating and managing their accounts

---

## Transactions

### Main Flows
- Deposit, withdraw, transfer between accounts, make a payment

### User Stories
| ID | Scenario | Description | Tags |
|----|----------|-------------|------|
| TR-01 | As a user, I want to deposit funds. | Add money to my account | `@smoke`, `@regression` |
| TR-02 | As a user, I want to withdraw funds. | Remove money from my account | `@smoke`, `@regression` |
| TR-03 | As a user, I want to transfer funds. | Move money between accounts | `@smoke`, `@regression` |
| TR-04 | As a user, I want to pay a beneficiary. | Make payments to others | `@smoke`, `@regression` |

*Scenario coverage from [gherkin_transact.feature](../gherkin_scenarios/gherkin_transact.feature)*

### Acceptance Criteria
- Deposit/withdraw/transfer/payment validate amounts, accounts, sufficient funds
- 400 error for invalid/missing data
- 401 error for unauthenticated actions
- Out-of-bound values and whitespace handled

| Scenario Title | Endpoint | Criteria | Tag |
|---------------|----------|----------|-----|
| Successful deposit | POST `/transact/deposit` | 200 OK, balance increases | `@smoke` |
| Successful withdraw | POST `/transact/withdraw` | 200 OK, balance decreases | `@smoke` |
| Successful transfer | POST `/transact/transfer` | 200 OK, balances updated | `@smoke` |
| Successful payment | POST `/transact/payment` | 200 OK, balance decreases, payment record | `@smoke` |
| Invalid/missing fields | Various | 400, error message | `@regression` |
| Insufficient funds | Various | 400, error message | `@regression` |
| Unauthorized actions | Various | 401, error message | `@regression` |

### Business Rules & Constraints
- Only authenticated users can transact
- Amounts must be positive and within allowed limits
- Source/target accounts must be valid and not identical (for transfer)
- All transaction actions update account models and create transaction/payment entities

### Actor Descriptions
- **User:** Account holder initiating transactions
- **System:** Validates, updates balances, creates records

---

## Authentication

### Main Flows
- Log in, log out

### User Stories
| ID | Scenario | Description | Tags |
|----|----------|-------------|------|
| AU-01 | As a user, I want to log in securely. | Authenticate to access services | `@smoke`, `@regression` |
| AU-02 | As a user, I want to log out of my session. | End my session | `@smoke`, `@regression`, `@logout` |

*Scenario coverage from [gherkin_auth.feature](../gherkin_scenarios/gherkin_auth.feature)*

### Acceptance Criteria
- Login requires email and password, verified account
- 400 for missing/invalid fields, 401/403/500 for various fail states
- Logout succeeds with valid session, errors for expired/invalid/no session

| Scenario Title | Endpoint | Criteria | Tag |
|---------------|----------|----------|-----|
| Successful login | POST `/login` | 200 OK, access_token returned | `@smoke` |
| Successful logout | GET `/logout` | 200 OK, confirmation message | `@smoke` |
| Invalid login | POST `/login` | 400/401/403/500, error messages | `@regression` |
| Invalid logout | GET `/logout` | 401, error messages | `@regression` |

### Business Rules & Constraints
- Only registered, verified users can log in
- Sessions managed via tokens
- Account models enforce validation on credentials

### Actor Descriptions
- **User:** Logs in/out, receives tokens
- **System:** Verifies credentials, issues tokens, manages session

---

## Registration

### Main Flows
- Sign up, password confirmation, handle duplicate emails, validate fields

### User Stories
| ID | Scenario | Description | Tags |
|----|----------|-------------|------|
| RG-01 | As a new user, I want to register using valid information. | Sign up as customer | `@smoke`, `@regression` |
| RG-02 | As a user, I want my password to be confirmed. | Avoid mistakes in password entry | `@regression` |
| RG-03 | As a user, I want to avoid duplicate account registration. | Register with a unique email | `@regression` |

*Scenario coverage from [gherkin_register.feature](../gherkin_scenarios/gherkin_register.feature)*

### Acceptance Criteria
- Registration requires first_name, last_name, email, password, confirm_password
- Validation enforces presence, length, format
- Duplicate emails rejected
- Password & confirm_password must match

| Scenario Title | Endpoint | Criteria | Tag |
|---------------|----------|----------|-----|
| Successful registration | POST `/register` | 200 OK, confirmation, user returned | `@smoke` |
| Invalid fields | POST `/register` | 400, error messages | `@regression` |
| Password mismatch | POST `/register` | 400, error message | `@regression` |
| Duplicate email | POST `/register` | 400, error message | `@regression` |

### Business Rules & Constraints
- User fields validated as per discovered User model
- Only non-empty, correctly formatted data allowed
- Passwords must match confirm_password

### Actor Descriptions
- **Visitor/User:** Registers account
- **System:** Validates input, stores user

---

## Data Retrieval

### Main Flows
- Dashboard, payment history, transaction history, per-account transactions

### User Stories
| ID | Scenario | Description | Tags |
|----|----------|-------------|------|
| DR-01 | As a user, I want to view my dashboard summary. | Access accounts and total balance | `@smoke`, `@regression` |
| DR-02 | As a user, I want to see my payment history. | Track payments | `@smoke`, `@regression` |
| DR-03 | As a user, I want to see my transaction history. | Review transactions | `@smoke`, `@regression` |
| DR-04 | As a user, I want to view my account's transaction history. | See transactions for a given account | `@smoke`, `@regression` |

*Scenario coverage from [gherkin_app.feature](../gherkin_scenarios/gherkin_app.feature), [gherkin_account_transaction_history.feature](../gherkin_scenarios/gherkin_account_transaction_history.feature)*

### Acceptance Criteria
- Authentication required for all data retrieval
- 200 OK with correct data arrays for valid requests
- 401 for unauthenticated, 400 for invalid/missing account_id
- Empty arrays returned for no data

| Scenario Title | Endpoint | Criteria | Tag |
|---------------|----------|----------|-----|
| Dashboard retrieval | GET `/app/dashboard` | 200, userAccounts & totalBalance returned | `@smoke`, `@regression` |
| Payment history | GET `/app/payment_history` | 200, payment_history returned | `@smoke`, `@regression` |
| Transaction history | GET `/app/transaction_history` | 200, transaction_history returned | `@smoke`, `@regression` |
| Account transaction history | POST `/app/account_transaction_history` | 200/400/401, transaction history/results | `@smoke`, `@regression` |

### Business Rules & Constraints
- Only authenticated users can access their data
- Account IDs validated for ownership
- Models: Account, Payment, PaymentHistory

### Actor Descriptions
- **User:** Consumes dashboard, history APIs
- **System:** Serves filtered, secure data

---

## Cross-Reference Index

| Feature Tag | Endpoint Path | Business Flow | Scenario File |
|-------------|-------------------------|---------------|---------------------------|
| `@smoke`/`@regression` | POST `/account/create_account` | Account Management | gherkin_account.feature |
| `@smoke`/`@regression` | POST `/transact/deposit` | Transactions | gherkin_transact.feature |
| `@smoke`/`@regression` | GET `/app/dashboard` | Data Retrieval | gherkin_app.feature |
| `@smoke`/`@regression` | POST `/register` | Registration | gherkin_register.feature |
| `@smoke`/`@regression` | POST `/login`/GET `/logout` | Authentication | gherkin_auth.feature |
| `@smoke`/`@regression` | POST `/app/account_transaction_history` | Data Retrieval | gherkin_account_transaction_history.feature |

---

## Traceability Links

- All test scenarios are linked to business flows via scenario tags.
- Endpoints are mapped to each user story and acceptance criteria.
- Models referenced per flow are validated in feature files and reflected in request/response validations.

---