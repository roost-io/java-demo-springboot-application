Feature: Payment and Transaction History Endpoints

  Background:
    Given a registered user exists
    And the user possesses a valid authentication token

  @smoke @positive
  Scenario: Successfully retrieve payment history for authenticated user
    When the user sends a GET request to "/app/payment_history" with a valid token
    Then the response status should be 200
    And the response body should contain a non-empty array of PaymentHistory objects

  @regression
  Scenario: Authenticated user receives empty payment history collection
    Given the user's payment history is empty
    When the user sends a GET request to "/app/payment_history" with a valid token
    Then the response status should be 200
    And the response body should contain an empty array

  @regression @negative
  Scenario: Unauthorized request to payment history endpoint
    When the user sends a GET request to "/app/payment_history" without a valid token
    Then the response status should be 401
    And the response body should contain an unauthorized error message

  @regression @edgecase
  Scenario: Large payment history list is handled correctly
    Given the user has more than 1000 PaymentHistory records
    When the user sends a GET request to "/app/payment_history" with a valid token
    Then the response status should be 200
    And the response body should contain an array with more than 1000 PaymentHistory objects

  @regression @edgecase
  Scenario: Corrupt or invalid PaymentHistory data is ignored
    Given the user's payment history contains some invalid or incomplete records
    When the user sends a GET request to "/app/payment_history" with a valid token
    Then the response status should be 200
    And all objects in the response array should conform to the PaymentHistory model

  @smoke @positive
  Scenario: Successfully retrieve transaction history for authenticated user
    When the user sends a GET request to "/app/transaction_history" with a valid token
    Then the response status should be 200
    And the response body should contain a non-empty array of TransactionHistory objects

  @regression
  Scenario: Authenticated user receives empty transaction history collection
    Given the user's transaction history is empty
    When the user sends a GET request to "/app/transaction_history" with a valid token
    Then the response status should be 200
    And the response body should contain an empty array

  @regression @negative
  Scenario: Unauthorized request to transaction history endpoint
    When the user sends a GET request to "/app/transaction_history" without a valid token
    Then the response status should be 401
    And the response body should contain an unauthorized error message

  @smoke @positive
  Scenario: Successfully retrieve account-specific transaction history
    Given an account with id "12345" belongs to the user
    When the user sends a POST request to "/app/account_transaction_history" with body { "account_id": "12345" } and a valid token
    Then the response status should be 200
    And the response body should contain a non-empty array of TransactionHistory objects related to account "12345"

  @regression
  Scenario: Account transaction history returns empty collection when no transactions exist
    Given the user has an account with id "98765" and no transaction history
    When the user sends a POST request to "/app/account_transaction_history" with body { "account_id": "98765" } and a valid token
    Then the response status should be 200
    And the response body should contain an empty array

  @regression @negative
  Scenario: Unauthorized request to account transaction history endpoint
    When the user sends a POST request to "/app/account_transaction_history" with a valid account_id but no token
    Then the response status should be 401
    And the response body should contain an unauthorized error message

  @regression @negative
  Scenario: Requesting account transaction history for an account the user does not own
    Given account with id "99999" does not belong to the user
    When the user sends a POST request to "/app/account_transaction_history" with body { "account_id": "99999" } and a valid token
    Then the response status should be 403
    And the response body should contain an authorization error message

  @regression @negative @edgecase
  Scenario: Omitting account_id from request body returns error
    When the user sends a POST request to "/app/account_transaction_history" with an empty body and a valid token
    Then the response status should be 400
    And the response body should contain a validation error for missing account_id

  @regression @negative @edgecase
  Scenario: Sending invalid account_id format returns error
    When the user sends a POST request to "/app/account_transaction_history" with body { "account_id": "INVALID_ID!!" } and a valid token
    Then the response status should be 400
    And the response body should contain a validation error for account_id

  @regression @edgecase
  Scenario: Large transaction history list is handled correctly
    Given the user has more than 1000 TransactionHistory records
    When the user sends a GET request to "/app/transaction_history" with a valid token
    Then the response status should be 200
    And the response body should contain an array with more than 1000 TransactionHistory objects

  @regression @edgecase
  Scenario: System handles simultaneous requests for history endpoints gracefully
    When the user sends multiple concurrent GET requests to "/app/payment_history" and "/app/transaction_history" with a valid token
    Then all responses should have status 200
    And no data corruption or partial responses should occur
