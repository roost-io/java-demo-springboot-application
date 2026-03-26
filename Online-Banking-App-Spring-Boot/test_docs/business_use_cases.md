# DemoBank_v1 API — Business Use Cases

## 1. User Registration  
**Controller/Endpoint:**  
RegisterController — `POST /register`  

### User Stories
- As a **new user**, I want to create a DemoBank account so that I can access banking services online.

### Acceptance Criteria
- Registration succeeds when all mandatory fields (name, email, password, etc.) are valid and unique.
- Registration fails with appropriate error for invalid email format, weak password, or duplicate email.
- User receives confirmation or welcome upon successful registration.

### Business Rules & Constraints

| Rule                                    | Constraint/Test Case                                              |
|------------------------------------------|-------------------------------------------------------------------|
| Email format validation                  | Reject registration if email is malformed                         |
| Email uniqueness                        | Return error if email already exists                              |
| Password strength                       | Require minimum length/complexity; reject weak passwords          |
| Mandatory fields must be present         | Registration fails if any required field is missing               |

### Actors
- **Unauthenticated User**: Initiates registration.
- **System**: Validates and stores user credentials.

### Cross-link
- Registration enables subsequent authentication (see Authentication use case).


---

## 2. Authentication (Login/Logout)  
**Controller/Endpoint:**  
AuthController — `POST /login`, `/logout`  

### User Stories
- As a **registered user**, I want to log in securely to access my account and services.
- As a **logged-in user**, I want to log out to protect my account.

### Acceptance Criteria
- Login succeeds with correct username/password.
- Login fails with incorrect credentials, with error message.
- Logout invalidates the session/token; further actions require re-login.

### Business Rules & Constraints

| Rule                                 | Constraint/Test Case                                               |
|---------------------------------------|--------------------------------------------------------------------|
| Credentials required                  | Reject login with missing username or password                     |
| Account must exist                    | Reject login if user is not registered                             |
| Account must be active                | Block login for locked/suspended accounts (if applicable)          |
| Logout must invalidate session        | After logout, user cannot access protected endpoints               |

### Actors
- **Registered User**: Initiates login/logout.
- **System**: Authenticates, manages sessions.

### Cross-link
- Authentication required for account management and all transactional endpoints.


---

## 3. Account Management (Creation)  
**Controller/Endpoint:**  
AccountController — `POST /account/create_account`  

### User Stories
- As a **logged-in user**, I want to create an account so I can manage my funds and perform transactions.

### Acceptance Criteria
- Account creation succeeds with valid inputs for account type, initial deposit, etc.
- Account creation fails if mandatory data is missing or business rules are violated.
- User receives account details (e.g., account number) upon success.

### Business Rules & Constraints

| Rule                                  | Constraint/Test Case                                         |
|----------------------------------------|--------------------------------------------------------------|
| Authenticated access                   | Only authenticated users can create accounts                 |
| Valid account type                     | Reject creation for unsupported account types                |
| Initial deposit required (if specified)| Fail creation if minimum deposit is not met                  |
| Unique account number                  | System generates unique account number                       |

### Actors
- **Authenticated User**: Requests account creation.
- **System**: Validates and records new account.

### Cross-link
- Account must exist for deposit, transfer, withdrawal, payment, and histories.


---

## 4. Deposit, Withdraw, Transfer, Payment  
**Controller/Endpoint:**  
TransactController — `/deposit`, `/withdraw`, `/transfer`, `/payment`  

### User Stories
- As an **account holder**, I want to deposit money, withdraw funds, transfer money to other accounts, and make payments.

### Acceptance Criteria
- Deposit succeeds with valid amount and account.
- Withdrawal succeeds only up to available balance.
- Transfer succeeds with valid source, destination, and amount.
- Payment succeeds with valid account, recipient, and amount.
- All actions fail with proper error for invalid account, insufficient balance, negative amount.

### Business Rules & Constraints

| Rule                                | Constraint/Test Case                                     |
|--------------------------------------|----------------------------------------------------------|
| Authenticated user required          | Unauthenticated requests are rejected                    |
| Valid account number                 | Fail transaction with invalid/nonexistent account        |
| Sufficient funds for withdrawal/transfer/payment | Error for insufficient balance                            |
| Amount must be positive              | Negative or zero amounts are rejected                    |
| Recipient account exists for transfer/payment | Error if beneficiary account is missing                     |

### Actors
- **Authenticated User**: Initiates transactions.
- **Beneficiary**: Receives funds (for transfers/payments).
- **System**: Validates transactions, updates balances.

### Cross-link
- Transactions recorded and visible in histories (see Dashboard/History).


---

## 5. Dashboard & Account/Transaction/Payment Histories  
**Controller/Endpoint:**  
AppController — `/dashboard`, `/payment_history`, `/transaction_history`, `/account_transaction_history`  
IndexController — `/greeting`, `/verify`  

### User Stories
- As a **logged-in user**, I want to view my account overview, transaction history, payment history, and account-specific history to monitor my finances.

### Acceptance Criteria
- Dashboard displays relevant user/account info upon login.
- History endpoints return correct, complete lists filtered by user/account.
- Unauthorized access/fake accounts yield errors.

### Business Rules & Constraints

| Rule                                  | Constraint/Test Case                                         |
|----------------------------------------|--------------------------------------------------------------|
| Authenticated access                   | Unauthenticated users denied access                          |
| Account ownership                      | User cannot view histories for accounts they do not own      |
| Data integrity                         | Returned history matches actual transactions/payments        |
| Proper filtering                       | Only user’s own transactions/payments are shown              |

### Actors
- **Authenticated User**: Accesses dashboard and histories.
- **System**: Fetches and presents relevant data.

### Cross-link
- History endpoints reflect actions in Deposit/Withdraw/Transfer/Payment.
- Authentication required; users must have registered accounts.


---

## 6. Greeting/Verification  
**Controller/Endpoint:**  
IndexController — `/greeting`, `/verify`  

### User Stories
- As any **visitor or user**, I want to access a greeting or verify service status before proceeding.

### Acceptance Criteria
- Greeting endpoint displays welcome/info message.
- Verification endpoint returns system status/info.
- No authentication required.

### Business Rules & Constraints

| Rule                                  | Constraint/Test Case                                         |
|----------------------------------------|--------------------------------------------------------------|
| Open access                            | Endpoint accessible without authentication                   |
| System status                          | Verification responds with current API/server status         |

### Actors
- **Unauthenticated User**, **Authenticated User**: Accesses endpoints.
- **System**: Responds with greeting, system info/status.

### Cross-link
- Useful for initial API/health check before registration or authentication.


---

**Notes:**  
- Each use case is grounded in respective controller endpoints and negative scenarios proven by validation/error handling.
- All business rules are explicitly linked to test scenarios for coverage.
- Actors are defined per action and cross-referenced where business logic transitions (registration → authentication → transactions/history).