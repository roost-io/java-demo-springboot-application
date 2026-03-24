Feature: AppController Endpoints API

  Background:
    Given the API is available

  #
  # 1. GET /app/dashboard
  #

  @smoke
  Scenario: Authenticated user retrieves dashboard with populated accounts
    Given a user "alice" is authenticated
    When the user sends a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should include a "userAccounts" array with at least 1 Account item
    And the response should include a "totalBalance" number greater than 0

  @regression
  Scenario: Unauthenticated user attempts to access dashboard
    Given the user is not authenticated
    When the user sends a GET request to "/app/dashboard"
    Then the response status should be 401
    And the response should contain an authentication error message

  @regression
  Scenario: Authenticated user has no accounts on dashboard
    Given a user "bob" is authenticated and has no accounts
    When the user sends a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should include a "userAccounts" array with 0 items
    And the response should include a "totalBalance" number equal to 0

  @regression
  Scenario: Authenticated user with a large number of accounts on dashboard
    Given a user "charlie" is authenticated and has 1000 accounts with random balances
    When the user sends a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should include a "userAccounts" array with 1000 Account items
    And the response should include a "totalBalance" number equal to the sum of all account balances

  #
  # 2. GET /app/payment_history
  #

  @smoke
  Scenario: Authenticated user retrieves payment history with records
    Given a user "alice" is authenticated
    And the user has at least 2 payment history records
    When the user sends a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should include a "payment_history" array with 2 or more PaymentHistory items

  @regression
  Scenario: Unauthenticated user attempts to access payment history
    Given the user is not authenticated
    When the user sends a GET request to "/app/payment_history"
    Then the response status should be 401
    And the response should contain an authentication error message

  @regression
  Scenario: Authenticated user with no payment history
    Given a user "bob" is authenticated and has no payment history
    When the user sends a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should include a "payment_history" array with 0 items

  @regression
  Scenario: Authenticated user with a large payment history
    Given a user "charlie" is authenticated and has 5000 payment history records
    When the user sends a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should include a "payment_history" array with 5000 PaymentHistory items

  #
  # 3. GET /app/transaction_history
  #

  @smoke
  Scenario: Authenticated user retrieves transaction history with records
    Given a user "alice" is authenticated
    And the user has at least 3 transaction history records
    When the user sends a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 3 or more TransactionHistory items

  @regression
  Scenario: Unauthenticated user attempts to access transaction history
    Given the user is not authenticated
    When the user sends a GET request to "/app/transaction_history"
    Then the response status should be 401
    And the response should contain an authentication error message

  @regression
  Scenario: Authenticated user with no transaction history
    Given a user "bob" is authenticated and has no transaction history
    When the user sends a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 0 items

  @regression
  Scenario: Authenticated user with a very large transaction history
    Given a user "charlie" is authenticated and has 10000 transaction history records
    When the user sends a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 10000 TransactionHistory items

  #
  # 4. POST /app/account_transaction_history
  #

  @smoke
  Scenario: Authenticated user retrieves transaction history for a valid account
    Given a user "alice" is authenticated
    And "alice" has an account with account_id "ACC123"
    And the account "ACC123" has 5 transaction records
    When the user sends a POST request to "/app/account_transaction_history" with account_id "ACC123"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 5 TransactionHistory items

  @regression
  Scenario: Unauthenticated user attempts to retrieve account transaction history
    When the user sends a POST request to "/app/account_transaction_history" with account_id "ACC123" without authentication
    Then the response status should be 401
    And the response should contain an authentication error message

  @regression
  Scenario: Authenticated user provides missing account_id in request
    Given a user "alice" is authenticated
    When the user sends a POST request to "/app/account_transaction_history" without "account_id"
    Then the response status should be 400
    And the response should contain a validation error about missing "account_id"

  @regression
  Scenario: Authenticated user provides an invalid account_id value
    Given a user "alice" is authenticated
    When the user sends a POST request to "/app/account_transaction_history" with account_id "INVALID_ACC"
    Then the response status should be 404
    And the response should contain an account not found error message

  @regression
  Scenario: Authenticated user requests transaction history for their valid account, with no transactions
    Given a user "bob" is authenticated
    And "bob" has an account with account_id "ACC456" with no transaction history
    When the user sends a POST request to "/app/account_transaction_history" with account_id "ACC456"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 0 items

  @regression
  Scenario: Authenticated user requests transaction history for their valid account with a very large dataset
    Given a user "charlie" is authenticated
    And "charlie" has an account with account_id "ACC789" and 20000 transaction history records
    When the user sends a POST request to "/app/account_transaction_history" with account_id "ACC789"
    Then the response status should be 200
    And the response should include a "transaction_history" array with 20000 TransactionHistory items
