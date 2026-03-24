Feature: Authentication Endpoints

  Background:
    Given the API is available

  ##############################
  # POST /login
  ##############################

  @smoke
  Scenario: User logs in successfully with valid credentials
    Given a verified user exists with email "john.doe@example.com" and password "Secret123!"
    When the client sends a POST request to /login with body:
      | email                | password    |
      | john.doe@example.com | Secret123!  |
    Then the response status should be 200
    And the response body should contain:
      | message       | access_token              |
      | Login success | <non-empty access_token>  |

  @regression
  Scenario: Login attempt with missing email
    When the client sends a POST request to /login with body:
      | email | password    |
      |       | Secret123!  |
    Then the response status should be 400
    And the response body should contain "Username or Password Cannot Be Empty."

  @regression
  Scenario: Login attempt with missing password
    When the client sends a POST request to /login with body:
      | email                | password |
      | john.doe@example.com |         |
    Then the response status should be 400
    And the response body should contain "Username or Password Cannot Be Empty."

  @regression
  Scenario: Login attempt with both email and password missing
    When the client sends a POST request to /login with body:
      | email | password |
      |       |          |
    Then the response status should be 400
    And the response body should contain "Username or Password Cannot Be Empty."

  @regression
  Scenario: Login attempt with incorrect email
    Given a verified user exists with email "john.doe@example.com" and password "Secret123!"
    When the client sends a POST request to /login with body:
      | email                | password    |
      | fake.user@example.com| Secret123!  |
    Then the response status should be 401
    And the response body should contain "Incorrect Username or Password"

  @regression
  Scenario: Login attempt with incorrect password
    Given a verified user exists with email "john.doe@example.com" and password "Secret123!"
    When the client sends a POST request to /login with body:
      | email                | password      |
      | john.doe@example.com | WrongPass987! |
    Then the response status should be 401
    And the response body should contain "Incorrect Username or Password"

  @regression
  Scenario: Login attempt by unverified user
    Given an unverified user exists with email "alice.smith@example.com" and password "Password1!"
    When the client sends a POST request to /login with body:
      | email                  | password    |
      | alice.smith@example.com| Password1!  |
    Then the response status should be 403
    And the response body should contain "Account verification required."

  @regression
  Scenario: Login attempt with malformed data (email as number)
    When the client sends a POST request to /login with body:
      | email | password    |
      | 12345 | Secret123!  |
    Then the response status should be 400
    And the response body should contain "Username or Password Cannot Be Empty."

  @regression
  Scenario: Internal server error during login
    Given the backend will return an internal error for email "server.error@example.com"
    When the client sends a POST request to /login with body:
      | email                  | password    |
      | server.error@example.com | AnyPass!  |
    Then the response status should be 500
    And the response body should contain "Internal server error."

  ##############################
  # GET /logout
  ##############################

  @smoke
  Scenario: User logs out successfully with valid session token
    Given a user is logged in and has a valid session token "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.valid.token"
    When the client sends a GET request to /logout with header "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.valid.token"
    Then the response status should be 200
    And the response body should contain "User logged out successfully."

  @regression
  Scenario: Logout attempt with missing session token
    When the client sends a GET request to /logout without an Authorization header
    Then the response status should be 401
    And the response body should contain "Authentication required."

  @regression
  Scenario: Logout attempt with invalid session token
    When the client sends a GET request to /logout with header "Authorization: Bearer invalid.token"
    Then the response status should be 401
    And the response body should contain "Authentication required."

  @regression
  Scenario: Logout attempt with an expired session token
    When the client sends a GET request to /logout with header "Authorization: Bearer expired.token"
    Then the response status should be 401
    And the response body should contain "Authentication required."
