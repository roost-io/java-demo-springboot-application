Feature: User Login and Logout API for Online Banking

  Background:
    Given the API is available

  ## LOGIN ENDPOINT SCENARIOS

  @smoke
  Scenario: Successful Login with valid credentials
    Given a registered user exists with email "user@example.com" and password "Password123!"
    When the client sends a POST request to "/login" with body:
      | email            | password     |
      | user@example.com | Password123! |
    Then the response status should be 200
    And the response should contain a non-empty "access_token"
    And the response "message" should be "Login successful"

  @regression
  Scenario: Login fails with invalid email or password
    Given a registered user exists with email "user@example.com" and password "Password123!"
    When the client sends a POST request to "/login" with body:
      | email            | password     |
      | user@example.com | WrongPass    |
    Then the response status should be 401
    And the response "message" should be "Invalid email or password"

  @regression
  Scenario: Login fails with missing required fields
    When the client sends a POST request to "/login" with body:
      | email |
      |       |
    Then the response status should be 400
    And the response "message" should indicate "Missing required fields"

  @regression
  Scenario: Login fails for unverified user
    Given a user exists with email "unverified@example.com", password "Password123!", and not verified
    When the client sends a POST request to "/login" with body:
      | email                 | password     |
      | unverified@example.com | Password123! |
    Then the response status should be 403
    And the response "message" should be "User not verified"

  @regression
  Scenario: Login fails for locked-out user (edge case)
    Given a user exists with email "locked@example.com", password "Password123!", and is locked out after multiple failed attempts
    When the client sends a POST request to "/login" with body:
      | email              | password     |
      | locked@example.com | Password123! |
    Then the response status should be 423
    And the response "message" should be "Account locked. Please contact support."

  @regression
  Scenario: Login with extremely long email/password (boundary)
    When the client sends a POST request to "/login" with an email over 255 characters and password over 100 characters
    Then the response status should be 400
    And the response "message" should indicate "Invalid input length"

  ## LOGOUT ENDPOINT SCENARIOS

  @smoke
  Scenario: Successful logout with valid token
    Given a user is logged in and has a valid "access_token"
    When the client sends a GET request to "/logout" with the "access_token"
    Then the response status should be 200
    And the response "message" should be "Logout successful"

  @regression
  Scenario: Logout fails with missing authentication token
    When the client sends a GET request to "/logout" without an authentication header
    Then the response status should be 401
    And the response "message" should be "Authorization required"

  @regression
  Scenario: Logout fails with expired or invalid token
    When the client sends a GET request to "/logout" with an expired or tampered "access_token"
    Then the response status should be 401
    And the response "message" should be "Invalid or expired token"

  @regression
  Scenario: Logout with already logged-out token (edge case)
    Given a user has already logged out so their token is invalidated
    When the client sends a GET request to "/logout" with the invalidated "access_token"
    Then the response status should be 401
    And the response "message" should be "Invalid or expired token"
