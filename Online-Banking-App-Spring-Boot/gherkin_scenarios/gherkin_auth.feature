Feature: User Login

  Background:
    Given the API is available

  @smoke
  Scenario: Successful login with valid credentials
    Given a registered user with email "test.user@example.com" and password "ValidPassword123"
    When the user logs in with email "test.user@example.com" and password "ValidPassword123"
    Then the response status should be 200
    And the response should contain an access_token and a message

  @regression
  Scenario: Login with missing email
    When the user logs in with email "" and password "ValidPassword123"
    Then the response status should be 400
    And the response should indicate that the email field is missing

  @regression
  Scenario: Login with missing password
    When the user logs in with email "test.user@example.com" and password ""
    Then the response status should be 400
    And the response should indicate that the password field is missing

  @regression
  Scenario: Login with both fields missing
    When the user logs in with email "" and password ""
    Then the response status should be 400
    And the response should indicate that email and password fields are missing

  @regression
  Scenario: Login with invalid email format
    When the user logs in with email "invalid-email-format" and password "ValidPassword123"
    Then the response status should be 400
    And the response should indicate that the email format is invalid

  @regression
  Scenario: Login with invalid credentials
    When the user logs in with email "test.user@example.com" and password "WrongPassword"
    Then the response status should be 401
    And the response should indicate bad credentials

  @regression
  Scenario: Login with unverified account
    Given the user account is registered but not verified
    When the user logs in with email "test.unverified@example.com" and password "ValidPassword123"
    Then the response status should be 403
    And the response should indicate the account is not verified

  @regression
  Scenario: Login with unknown email
    When the user logs in with email "unknown@example.com" and password "AnyPassword"
    Then the response status should be 500
    And the response should indicate that the email was not found

  @regression
  Scenario: Login with blank spaces in email and password fields
    When the user logs in with email "   " and password "   "
    Then the response status should be 400
    And the response should indicate that email and password fields are missing

  @regression
  Scenario: Login without authentication header
    When the user logs in with email "test.user@example.com" and password "ValidPassword123" but without authentication header
    Then the response status should be 401
    And the response should indicate missing or invalid authentication

  @regression
  Scenario: Login with excessively long email and password fields
    When the user logs in with email "longemailuser12345678901234567890123456789012345678901234567890@example.com" and password "VeryLongPasswordThatExceedsMaxLimit12345678901234567890"
    Then the response status should be 400
    And the response should indicate field length validation errors

  @regression
  Scenario: Login with SQL injection attempt in email and password
    When the user logs in with email "' OR 1=1; -- " and password "' OR 1=1; -- "
    Then the response status should be 401
    And the response should indicate bad credentials

Feature: Logout Functionality

  The /logout endpoint allows users to end their session. 
  These scenarios cover successful and unsuccessful logout attempts under different authentication conditions.

  @smoke @logout
  Scenario: Successful logout when logged in
    Given the user is authenticated with a valid session token
    When the user sends a GET request to /logout with the session token
    Then the response status should be 200
    And the response body should contain a confirmation message "You have been logged out successfully."

  @regression @logout
  Scenario: Logout attempt with no active session
    Given the user does not have any session token
    When the user sends a GET request to /logout without authentication headers
    Then the response status should be 401
    And the response body should contain an error message "No active session found."

  @regression @logout
  Scenario: Logout attempt with expired session
    Given the user is authenticated with an expired session token
    When the user sends a GET request to /logout with the expired session token
    Then the response status should be 401
    And the response body should contain an error message "Session has expired. Please log in again."

  @regression @logout
  Scenario: Logout attempt with invalid session token
    Given the user is authenticated with an invalid session token
    When the user sends a GET request to /logout with the invalid session token
    Then the response status should be 401
    And the response body should contain an error message "Invalid session token."
