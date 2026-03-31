Feature: AuthController Authentication Endpoints

  Background:
    Given the API base URL is "/"
    And the user data is as follows:
      | email                | password      | verified | correct_password |
      | user@example.com     | secret123     | true     | secret123        |
      | unverified@example.com | secret321   | false    | secret321        |

  @smoke
  Scenario: Successful login with valid credentials
    When I send a POST request to "/login" with body:
      | email              | password    |
      | user@example.com   | secret123   |
    Then the response status should be 200
    And the response should contain JSON field "access_token"

  @regression
  Scenario: Login fails when email is missing
    When I send a POST request to "/login" with body:
      | password    |
      | secret123   |
    Then the response status should be 400
    And the response should contain an error message "Missing required field: email"

  @regression
  Scenario: Login fails when password is missing
    When I send a POST request to "/login" with body:
      | email              |
      | user@example.com   |
    Then the response status should be 400
    And the response should contain an error message "Missing required field: password"

  @regression
  Scenario: Login fails with incorrect credentials
    When I send a POST request to "/login" with body:
      | email              | password      |
      | user@example.com   | wrongpass     |
    Then the response status should be 401
    And the response should contain an error message "Invalid email or password"

  @regression
  Scenario: Login fails when account verification is required
    When I send a POST request to "/login" with body:
      | email                    | password    |
      | unverified@example.com   | secret321   |
    Then the response status should be 403
    And the response should contain an error message "Account verification required"

  @regression
  Scenario: Login fails due to server error
    Given the authentication service is unavailable
    When I send a POST request to "/login" with body:
      | email              | password    |
      | user@example.com   | secret123   |
    Then the response status should be 500
    And the response should contain an error message "Internal server error"

  @smoke
  Scenario: Successful logout for logged-in user
    Given the user "user@example.com" is logged in with a valid session
    When I send a GET request to "/logout"
    Then the response status should be 200
    And the response should contain a success message "Logout successful"

  @regression
  Scenario: Logout fails for not logged-in user
    Given no user is logged in
    When I send a GET request to "/logout"
    Then the response status should be 401
    And the response should contain an error message "Authentication required"