Feature: App Dashboard and History API Endpoints

  Background:
    Given the API base URL is set
    And a user exists in the system

  @smoke
  Scenario: Successfully fetch dashboard data as logged-in user
    Given I am logged in as a valid user
    When I send a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should contain "accounts"
    And the response should contain "total_balance"

  @regression
  Scenario: Attempt to fetch dashboard data without logging in
    Given I am not logged in
    When I send a GET request to "/app/dashboard"
    Then the response status should be 401
    And the response should contain "Unauthorized"

  @smoke
  Scenario: Successfully fetch payment history as logged-in user
    Given I am logged in as a valid user
    When I send a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should contain "payment_history" as JSON

  @regression
  Scenario: Attempt to fetch payment history without logging in
    Given I am not logged in
    When I send a GET request to "/app/payment_history"
    Then the response status should be 401
    And the response should contain "Unauthorized"

  @smoke
  Scenario: Successfully fetch transaction history as logged-in user
    Given I am logged in as a valid user
    When I send a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should contain "transaction_history" as JSON

  @regression
  Scenario: Attempt to fetch transaction history without logging in
    Given I am not logged in
    When I send a GET request to "/app/transaction_history"
    Then the response status should be 401
    And the response should contain "Unauthorized"

  @smoke
  Scenario: Successfully fetch account transaction history with valid account ID as logged-in user
    Given I am logged in as a valid user
    And I have a valid account ID "12345"
    When I send a POST request to "/app/account_transaction_history" with body:
      | account_id | 12345 |
    Then the response status should be 200
    And the response should contain "history" for account "12345"

  @regression
  Scenario: Attempt to fetch account transaction history without logging in
    Given I am not logged in
    And I have a valid account ID "12345"
    When I send a POST request to "/app/account_transaction_history" with body:
      | account_id | 12345 |
    Then the response status should be 401
    And the response should contain "Unauthorized"

  @regression
  Scenario: Attempt to fetch account transaction history with missing account ID as logged-in user
    Given I am logged in as a valid user
    When I send a POST request to "/app/account_transaction_history" with empty body
    Then the response status should not be 200
    And the response should indicate "account_id" is required