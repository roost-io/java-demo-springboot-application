Feature: Account Management and Dashboard

  Background:
    Given the API is available

  # --- Account Creation ---

  @smoke
  Scenario: Successfully create a new account
    Given I am an authenticated user
    When I send a POST request to /account/create_account with body:
      | account_name  | account_type |
      | "Savings"     | "savings"    |
    Then the response status should be 201
    And the response should contain an Account object with account_name "Savings" and account_type "savings"

  @regression
  Scenario: Fail to create account when unauthenticated
    Given I am not authenticated
    When I send a POST request to /account/create_account with body:
      | account_name  | account_type |
      | "Invalid"     | "savings"    |
    Then the response status should be 401
    And the response should contain an error message indicating authentication is required

  @regression
  Scenario: Fail to create account with missing required fields
    Given I am an authenticated user
    When I send a POST request to /account/create_account with body:
      | account_type |
      | "checking"   |
    Then the response status should be 400
    And the response should contain an error message for missing account_name

  @regression
  Scenario: Fail to create account with invalid account_type
    Given I am an authenticated user
    When I send a POST request to /account/create_account with body:
      | account_name | account_type   |
      | "Invalid"    | "investment"   |
    Then the response status should be 400
    And the response should contain an error message for invalid account_type

  @regression
  Scenario: Fail to create duplicate account with same name and type
    Given I am an authenticated user
      And I have already created an account with name "Personal" and type "savings"
    When I send a POST request to /account/create_account with body:
      | account_name | account_type |
      | "Personal"   | "savings"    |
    Then the response status should be 409
    And the response should contain an error message indicating duplicate account

  # --- Dashboard ---

  @smoke
  Scenario: View dashboard with account summary
    Given I am an authenticated user
      And I have the following accounts:
        | account_name | account_type | balance |
        | "Main"       | "checking"   | 2500    |
        | "Savings"    | "savings"    | 5000    |
    When I send a GET request to /app/dashboard
    Then the response status should be 200
    And the response should contain a list of userAccounts with 2 accounts
    And the response should contain totalBalance equal to 7500

  @regression
  Scenario: Fail to view dashboard when unauthenticated
    Given I am not authenticated
    When I send a GET request to /app/dashboard
    Then the response status should be 401
    And the response should contain an error message indicating authentication is required

  @smoke
  Scenario: View dashboard when user has no accounts
    Given I am an authenticated user
      And I have no accounts
    When I send a GET request to /app/dashboard
    Then the response status should be 200
    And the response should contain userAccounts as an empty list
    And the response should contain totalBalance equal to 0

  @regression
  Scenario: Handle internal server error when fetching dashboard
    Given I am an authenticated user
      And a backend error occurs while fetching dashboard data
    When I send a GET request to /app/dashboard
    Then the response status should be 500
    And the response should contain an error message indicating a server error

  # --- Edge Cases ---

  @regression
  Scenario: Create account with name at maximum allowed length
    Given I am an authenticated user
      And the maximum allowed account name length is 255 characters
    When I send a POST request to /account/create_account with body:
      | account_name                       | account_type |
      | "<255_char_string>"                | "checking"   |
    Then the response status should be 201
    And the response should contain an Account object with the given name

  @regression
  Scenario: Fail to create account with overly long account_name
    Given I am an authenticated user
      And the maximum allowed account name length is 255 characters
    When I send a POST request to /account/create_account with body:
      | account_name          | account_type |
      | "<256_char_string>"   | "checking"   |
    Then the response status should be 400
    And the response should contain an error message for account_name length

  @regression
  Scenario: Create multiple different accounts with the same name but different types
    Given I am an authenticated user
      And I have created an account with name "Holiday" and type "savings"
    When I send a POST request to /account/create_account with body:
      | account_name | account_type |
      | "Holiday"    | "checking"   |
    Then the response status should be 201
    And the response should contain an Account object with account_name "Holiday" and account_type "checking"

  @regression
  Scenario: Balance calculation includes all user-owned accounts
    Given I am an authenticated user
      And I have the following accounts:
        | account_name  | account_type | balance |
        | "USD"         | "checking"   | 1000    |
        | "EUR"         | "checking"   | 2000    |
        | "GBP"         | "savings"    | 3000    |
    When I send a GET request to /app/dashboard
    Then the response totalBalance should be 6000

  @regression
  Scenario: Dashboard displays only accounts owned by the user
    Given I am user "alice" authenticated
      And user "bob" has an account named "Joint" with balance 5000
    When "alice" sends a GET request to /app/dashboard
    Then the response should not contain the "Joint" account owned by "bob"
