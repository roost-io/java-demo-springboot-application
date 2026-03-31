Feature: Create Bank Account via REST API

  As a logged-in user,
  I want to create a new bank account with a valid name and account type,
  So that I can manage multiple accounts in my banking application.

  Background:
    Given the API endpoint "/account/create_account" is available
    And a user with id "12345" exists in the system

  @smoke
  Scenario: Successful account creation with valid data
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name  | account_type |
      | "Savings"     | "Checking"   |
    When I POST to "/account/create_account"
    Then the response status should be 200
    And the response body should contain a list of accounts including an account with:
      | account_name  | account_type |
      | "Savings"     | "Checking"   |

  @regression
  Scenario: Create account with missing account_name
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_type |
      | "Checking"   |
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating account_name is required

  @regression
  Scenario: Create account with missing account_type
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name |
      | "Personal"   |
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating account_type is required

  @regression
  Scenario: Create account with completely missing body
    Given the user is authenticated with session user id "12345"
    And the request body is empty
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating required fields are missing

  @regression
  Scenario: Create account when not authenticated
    Given the user is not authenticated (no session user)
    And the request body contains:
      | account_name  | account_type |
      | "Savings"     | "Checking"   |
    When I POST to "/account/create_account"
    Then the response status should be 401
    And the response body should include an error message indicating authentication is required

  @regression
  Scenario: Create account with account_name at boundary length (min/max)
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name              | account_type |
      | "A"                       | "Checking"   |
    When I POST to "/account/create_account"
    Then the response status should be 200
    And the response body should contain an account with account_name "A"

    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name                              | account_type |
      | "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ" | "Savings" |
    When I POST to "/account/create_account"
    Then the response status should be 200
    And the response body should contain an account with account_name "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ"

  @regression
  Scenario: Create account with account_name or account_type as whitespace
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name  | account_type |
      | "   "         | "Checking"   |
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating account_name is invalid

    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name  | account_type |
      | "Home"        | "   "        |
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating account_type is invalid

  @regression
  Scenario: Create account with invalid account_type value
    Given the user is authenticated with session user id "12345"
    And the request body contains:
      | account_name  | account_type |
      | "Investment"  | "InvalidType" |
    When I POST to "/account/create_account"
    Then the response status should be 400
    And the response body should include an error message indicating account_type is invalid
