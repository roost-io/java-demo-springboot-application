Feature: Account Creation via AccountController API

  Background:
    Given the API service is running
    And the user "john.doe@example.com" is authenticated with sessionParam "user"

  @smoke
  Scenario: Successful account creation with valid data
    When the user sends a POST request to "/account/create_account" with JSON body:
      """
      {
        "account_name": "Savings Account",
        "account_type": "Savings"
      }
      """
    Then the response status should be 200
    And the response should contain a list of accounts as JSON
    And there should be an account with:
      | account_name   | account_type | balance  |
      | Savings Account | Savings      | 0.00     |
    And the account should have a non-empty "account_id" and "account_number"
    And "create_at" and "updated_at" should be valid timestamps

  @regression
  Scenario: Account creation fails with missing account_name
    When the user sends a POST request to "/account/create_account" with JSON body:
      """
      {
        "account_type": "Checking"
      }
      """
    Then the response status should be 400
    And the response should contain an error message stating "Missing account_name"

  @regression
  Scenario: Account creation fails with missing account_type
    When the user sends a POST request to "/account/create_account" with JSON body:
      """
      {
        "account_name": "Business Account"
      }
      """
    Then the response status should be 400
    And the response should contain an error message stating "Missing account_type"

  @regression
  Scenario: Unauthorized account creation attempt
    Given the user is not authenticated
    When the user sends a POST request to "/account/create_account" with JSON body:
      """
      {
        "account_name": "Personal Account",
        "account_type": "Savings"
      }
      """
    Then the response status should be 401
    And the response should contain an error message stating "User not logged in"
