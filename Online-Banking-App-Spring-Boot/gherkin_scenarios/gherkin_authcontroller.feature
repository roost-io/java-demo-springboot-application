Feature: User Authentication and Logout REST API

  Background:
    Given the API is available

  @smoke
  Scenario: Successful login with valid credentials
    Given a user exists with email "user@example.com" and password "correct_password" and is verified
    When the client sends a POST request to "/login" with body:
      | email           | password         |
      | user@example.com | correct_password |
    Then the response status should be 200
    And the response body should contain "Authentication confirmed"
    And a session cookie is set

  @smoke
  Scenario: Successful logout with valid session
    Given the client is authenticated via a session cookie
    When the client sends a GET request to "/logout" with the session cookie
    Then the response status should be 200
    And the response body should contain "Logged out"
    And the session cookie should be cleared

  @regression
  Scenario: Login attempt with incorrect password
    Given a user exists with email "user@example.com" and password "correct_password" and is verified
    When the client sends a POST request to "/login" with body:
      | email           | password         |
      | user@example.com | wrong_password   |
    Then the response status should be 401
    And the response body should contain "Incorrect credentials"
    And no session cookie is set

  @regression
  Scenario: Login attempt with missing email and password
    When the client sends a POST request to "/login" with body:
      | email | password |
      |       |         |
    Then the response status should be 400
    And the response body should contain "Username/Password empty"
    And no session cookie is set

  @regression
  Scenario: Login attempt with unverified user
    Given a user exists with email "unverified@example.com" and password "pass1234" and is NOT verified
    When the client sends a POST request to "/login" with body:
      | email                | password  |
      | unverified@example.com | pass1234 |
    Then the response status should be 403
    And the response body should contain "Verification required"
    And no session cookie is set

  @regression
  Scenario: Login attempt with email not found
    Given no user exists with email "nonexistent@example.com"
    When the client sends a POST request to "/login" with body:
      | email                | password     |
      | nonexistent@example.com | somepass      |
    Then the response status should be 500
    And the response body should contain "Email not found"
    And no session cookie is set

  @regression
  Scenario: Logout attempt without session cookie
    When the client sends a GET request to "/logout" without a session cookie
    Then the response status should be 200
    And the response body should contain "Logged out"
    And no session cookie should be present

  @regression
  Scenario: Logout attempt with an expired session cookie
    Given the client has an expired session cookie
    When the client sends a GET request to "/logout" with the expired session cookie
    Then the response status should be 200
    And the response body should contain "Logged out"
    And the session cookie should be cleared

  @regression
  Scenario: Login attempt with invalid email format
    When the client sends a POST request to "/login" with body:
      | email      | password   |
      | bad-email  | test1234   |
    Then the response status should be 400
    And the response body should contain "Username/Password empty"
    And no session cookie is set
