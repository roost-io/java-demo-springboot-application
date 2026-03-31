Feature: Account Creation via AccountController

  As an authenticated user
  I want to create new accounts using the AccountController
  So that I can manage my finances

  Background:
    Given the API endpoint is "/account/create_account"
    And the request method is POST

  @smoke
  Scenario: Successfully create a new account with valid details
    Given I am a logged-in user with a valid session
    And the request body contains:
      | account_name   | account_type |
      | "Personal Fund" | "Savings"    |
    When I send the POST request to "/account/create_account"
    Then the response status should be 200
    And the response should contain a list of Account objects
    And each Account object should have fields:
      | account_id     |
      | user_id        |
      | account_number |
      | account_name   |
      | account_type   |
      | balance        |
      | create_at      |
      | updated_at     |

  @regression
  Scenario: Fail to create account with missing account_name
    Given I am a logged-in user with a valid session
    And the request body contains:
      | account_name | account_type |
      | ""           | "Savings"    |
    When I send the POST request to "/account/create_account"
    Then the response status should be 400
    And the response should contain the message "Account name cannot be Empty!"

  @regression
  Scenario: Fail to create account when user is not authenticated
    Given I am not logged in and have no valid session
    And the request body contains:
      | account_name   | account_type |
      | "Personal Fund" | "Savings"    |
    When I send the POST request to "/account/create_account"
    Then the response status should be 401
    And the response should contain the message "You must login first."