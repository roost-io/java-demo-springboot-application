Feature: Account Data Retrieval
  As an authenticated user
  I want to retrieve my dashboard, payment history, and transaction history
  So that I can view my financial data securely

  @smoke
  Scenario: Successful dashboard retrieval
    Given I am an authenticated user with account data
    When I send a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should contain "userAccounts" as a non-empty array
    And the response should contain "totalBalance" as a number

  @regression
  Scenario: Unauthorized dashboard retrieval
    Given I am not authenticated
    When I send a GET request to "/app/dashboard"
    Then the response status should be 401
    And the response should not contain "userAccounts"
    And the response should not contain "totalBalance"

  @regression
  Scenario: Dashboard with no accounts
    Given I am an authenticated user with no account data
    When I send a GET request to "/app/dashboard"
    Then the response status should be 200
    And the response should contain "userAccounts" as an empty array
    And the response should contain "totalBalance" as 0

  @smoke
  Scenario: Payment history with data
    Given I am an authenticated user with payment history data
    When I send a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should contain "payment_history" as a non-empty array

  @regression
  Scenario: Payment history with no data
    Given I am an authenticated user with no payment history data
    When I send a GET request to "/app/payment_history"
    Then the response status should be 200
    And the response should contain "payment_history" as an empty array

  @regression
  Scenario: Unauthorized payment history retrieval
    Given I am not authenticated
    When I send a GET request to "/app/payment_history"
    Then the response status should be 401
    And the response should not contain "payment_history"

  @smoke
  Scenario: Transaction history with data
    Given I am an authenticated user with transaction history data
    When I send a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should contain "transaction_history" as a non-empty array

  @regression
  Scenario: Transaction history with no data
    Given I am an authenticated user with no transaction history data
    When I send a GET request to "/app/transaction_history"
    Then the response status should be 200
    And the response should contain "transaction_history" as an empty array

  @regression
  Scenario: Unauthorized transaction history retrieval
    Given I am not authenticated
    When I send a GET request to "/app/transaction_history"
    Then the response status should be 401
    And the response should not contain "transaction_history"