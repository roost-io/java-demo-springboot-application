Feature: Account Transaction History API

  The POST /app/account_transaction_history endpoint returns the transaction history for a specified account.
  It requires authentication and a valid account_id in the request body.

  @smoke
  Scenario: Successful retrieval of transaction history for an existing account
    Given a logged-in user with session "valid_session_token"
    And the user owns an account with account_id "ACC123"
    And the account "ACC123" has transactions
    When the user sends a POST request to "/app/account_transaction_history" with JSON body:
      | account_id | ACC123 |
    Then the response status should be 200
    And the response body should contain a "transaction_history" array
    And the "transaction_history" array should have at least one transaction

  @regression
  Scenario: Unauthorized access when session is missing
    Given no session is present
    When the user sends a POST request to "/app/account_transaction_history" with JSON body:
      | account_id | ACC123 |
    Then the response status should be 401
    And the response body should contain an error message "Unauthorized"

  @regression
  Scenario: Missing account_id in request body
    Given a logged-in user with session "valid_session_token"
    When the user sends a POST request to "/app/account_transaction_history" with JSON body:
      | account_id |       |
    Then the response status should be 400
    And the response body should contain an error message "Missing account_id"

  @regression
  Scenario: Invalid account_id not owned by user
    Given a logged-in user with session "valid_session_token"
    And the account_id "ACC999" exists but is not owned by the user
    When the user sends a POST request to "/app/account_transaction_history" with JSON body:
      | account_id | ACC999 |
    Then the response status should be 400
    And the response body should contain an error message "Invalid account_id"

  @regression
  Scenario: Account with no transactions
    Given a logged-in user with session "valid_session_token"
    And the user owns an account with account_id "ACC456"
    And the account "ACC456" has no transactions
    When the user sends a POST request to "/app/account_transaction_history" with JSON body:
      | account_id | ACC456 |
    Then the response status should be 200
    And the response body should contain a "transaction_history" array
    And the "transaction_history" array should be empty
