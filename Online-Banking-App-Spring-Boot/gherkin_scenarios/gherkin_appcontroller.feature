Feature: AppController Dashboard and History Endpoints

  Background:
    Given the API is available

  #
  # /app/dashboard endpoint scenarios
  #
  @smoke
  Scenario: Successful dashboard data retrieval with valid session
    Given the user has a valid session
    When the user sends a GET request to /app/dashboard
    Then the response status should be 200
    And the response body should contain the dashboard data

  @regression
  Scenario: Unauthorized access to dashboard with no session
    Given the user does not have a session
    When the user sends a GET request to /app/dashboard
    Then the response status should be 401
    And the response body should indicate unauthorized access

  @regression
  Scenario: Dashboard returns empty data for boundary condition
    Given the user has a valid session and no dashboard data is available
    When the user sends a GET request to /app/dashboard
    Then the response status should be 200
    And the response body should contain an empty dashboard data set

  @regression
  Scenario: Dashboard returns large dataset
    Given the user has a valid session and dashboard data contains a large dataset
    When the user sends a GET request to /app/dashboard
    Then the response status should be 200
    And the response body should contain more than 1000 dashboard items

  #
  # /app/payment_history endpoint scenarios
  #
  @smoke
  Scenario: Successful payment history retrieval with valid session
    Given the user has a valid session
    When the user sends a GET request to /app/payment_history
    Then the response status should be 200
    And the response body should contain the payment history

  @regression
  Scenario: Unauthorized access to payment history with invalid session
    Given the user has an invalid session
    When the user sends a GET request to /app/payment_history
    Then the response status should be 401
    And the response body should indicate unauthorized access

  @regression
  Scenario: Payment history returns empty data for boundary condition
    Given the user has a valid session and no payment history exists
    When the user sends a GET request to /app/payment_history
    Then the response status should be 200
    And the response body should contain an empty payment history list

  @regression
  Scenario: Payment history returns large dataset
    Given the user has a valid session and payment history contains a large dataset
    When the user sends a GET request to /app/payment_history
    Then the response status should be 200
    And the response body should contain more than 1000 payment history items

  #
  # /app/transaction_history endpoint scenarios
  #
  @smoke
  Scenario: Successful transaction history retrieval with valid session
    Given the user has a valid session
    When the user sends a GET request to /app/transaction_history
    Then the response status should be 200
    And the response body should contain the transaction history

  @regression
  Scenario: Unauthorized access to transaction history with no session
    Given the user does not have a session
    When the user sends a GET request to /app/transaction_history
    Then the response status should be 401
    And the response body should indicate unauthorized access

  @regression
  Scenario: Transaction history returns empty data for boundary condition
    Given the user has a valid session and transaction history is empty
    When the user sends a GET request to /app/transaction_history
    Then the response status should be 200
    And the response body should contain an empty transaction history list

  @regression
  Scenario: Transaction history returns large dataset
    Given the user has a valid session and transaction history contains a large dataset
    When the user sends a GET request to /app/transaction_history
    Then the response status should be 200
    And the response body should contain more than 1000 transaction history items

  #
  # /app/account_transaction_history endpoint scenarios
  #
  @smoke
  Scenario: Successful account transaction history retrieval with valid session and account id
    Given the user has a valid session
    And the user specifies a valid account_id in the request body
    When the user sends a POST request to /app/account_transaction_history
    Then the response status should be 200
    And the response body should contain the account transaction history

  @regression
  Scenario: Unauthorized access to account transaction history with missing session
    Given the user does not have a session
    And the user specifies a valid account_id in the request body
    When the user sends a POST request to /app/account_transaction_history
    Then the response status should be 401
    And the response body should indicate unauthorized access

  @regression
  Scenario: Account transaction history returns empty data for boundary condition
    Given the user has a valid session
    And the user specifies an account_id with no transaction history
    When the user sends a POST request to /app/account_transaction_history
    Then the response status should be 200
    And the response body should contain an empty transaction history list

  @regression
  Scenario: Account transaction history returns large dataset
    Given the user has a valid session
    And the user specifies an account_id with a large transaction history dataset
    When the user sends a POST request to /app/account_transaction_history
    Then the response status should be 200
    And the response body should contain more than 1000 account transaction history items
