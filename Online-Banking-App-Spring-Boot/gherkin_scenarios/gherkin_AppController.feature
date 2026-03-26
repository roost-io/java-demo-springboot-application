Feature: App Dashboard and History API Endpoints

  Background:
    Given the API server is running

  # -------------------------------
  # DASHBOARD ENDPOINT
  # -------------------------------

  @smoke
  Scenario: Retrieve dashboard data when user has accounts
    Given an authenticated user with user_id "user_123"
    When the user sends a GET request to "/app/dashboard" with sessionParam "user"
    Then the response status should be 200
    And the response body contains:
      | accounts          | total_balance |
      | [Account objects] | 1500.00       |

  @regression
  Scenario: Retrieve dashboard data when user is not authenticated
    When the user sends a GET request to "/app/dashboard" without authentication
    Then the response status should be 401
    And the response body contains an error message "Authentication required"

  @regression
  Scenario: Retrieve dashboard data when user has no accounts
    Given an authenticated user with user_id "user_456" and 0 accounts
    When the user sends a GET request to "/app/dashboard" with sessionParam "user"
    Then the response status should be 200
    And the response body contains:
      | accounts | total_balance |
      | []       | 0.00          |

  # -------------------------------
  # PAYMENT HISTORY ENDPOINT
  # -------------------------------

  @smoke
  Scenario: Get payment history when payments exist
    Given an authenticated user with user_id "user_123" with payments in history
    When the user sends a GET request to "/app/payment_history" with sessionParam "user"
    Then the response status should be 200
    And the response body contains payment history list with at least one PaymentHistory object

  @regression
  Scenario: Get payment history when user has no payments
    Given an authenticated user with user_id "user_789" with empty payment history
    When the user sends a GET request to "/app/payment_history" with sessionParam "user"
    Then the response status should be 200
    And the response body contains payment history list as []

  @regression
  Scenario: Get payment history when user is not authenticated
    When the user sends a GET request to "/app/payment_history" without authentication
    Then the response status should be 401
    And the response body contains an error message "Authentication required"

  # -------------------------------
  # TRANSACTION HISTORY ENDPOINT
  # -------------------------------

  @smoke
  Scenario: Query transaction history when transactions exist
    Given an authenticated user with user_id "user_123" with transactions in history
    When the user sends a GET request to "/app/transaction_history" with sessionParam "user"
    Then the response status should be 200
    And the response body contains transaction history list with at least one TransactionHistory object

  @regression
  Scenario: Query transaction history when user has no transactions
    Given an authenticated user with user_id "user_555" with empty transaction history
    When the user sends a GET request to "/app/transaction_history" with sessionParam "user"
    Then the response status should be 200
    And the response body contains transaction history list as []

  @regression
  Scenario: Query transaction history when user is not authenticated
    When the user sends a GET request to "/app/transaction_history" without authentication
    Then the response status should be 401
    And the response body contains an error message "Authentication required"

  # -------------------------------
  # ACCOUNT TRANSACTION HISTORY ENDPOINT
  # -------------------------------

  @smoke
  Scenario: Retrieve transaction history for a valid account with transactions
    Given an authenticated user with user_id "user_123" and an account_id "acc_001" with transactions
    When the user sends a POST request to "/app/account_transaction_history" with JSON:
      """
      {
        "account_id": "acc_001"
      }
      """
      And sessionParam "user"
    Then the response status should be 200
    And the response body contains transaction history list with at least one TransactionHistory object

  @regression
  Scenario: Retrieve transaction history for a valid account with no transactions
    Given an authenticated user with user_id "user_123" and an account_id "acc_002" with no transactions
    When the user sends a POST request to "/app/account_transaction_history" with JSON:
      """
      {
        "account_id": "acc_002"
      }
      """
      And sessionParam "user"
    Then the response status should be 200
    And the response body contains transaction history list as []

  @regression
  Scenario: Retrieve transaction history for account when user is not authenticated
    When the user sends a POST request to "/app/account_transaction_history" with JSON:
      """
      {
        "account_id": "acc_003"
      }
      """
      And no authentication
    Then the response status should be 401
    And the response body contains an error message "Authentication required"
