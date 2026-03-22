Feature: IndexController API Integration Tests

  Background:
    Given the API base URL 'http://localhost:8080'
    And the IndexController is constructed with valid UserRepository dependency

  Scenario: Get index message successfully via GET request
    Given the IndexController is available
    When I send a GET request to '/index'
    Then the response status should be 200
    And the response body should be 'Merhaba, Spring Boot JSON örnegi!'

  Scenario: Get index message via invalid HTTP method (POST)
    Given the IndexController is available
    When I send a POST request to '/index' with no payload
    Then the response status should be 405
    And the response body should contain error message 'Method Not Allowed'

  Scenario: Verify account successfully with valid token and code
    Given valid token 'abc123' exists in the database
    And valid code '7890' for user verification
    When I send a GET request to '/verify?token=abc123&code=7890'
    Then the response status should be 200
    And the response body should contain key 'message' with value 'Verification success.'

  Scenario: Verify account with expired session token
    Given invalid token 'expired_token' does not exist in database
    When I send a GET request to '/verify?token=expired_token&code=7890'
    Then the response status should be 400
    And the response body should be 'This session has expire.'

  Scenario: Verify account with missing token parameter
    Given user wants to verify email account
    When I send a GET request to '/verify?code=7890'
    Then the response status should be 400
    And the response body should contain error message indicating missing token parameter

  Scenario: Verify account with missing code parameter
    Given user wants to verify email account
    When I send a GET request to '/verify?token=abc123'
    Then the response status should be 400
    And the response body should contain error message indicating missing code parameter

  Scenario: Verify account with invalid HTTP method (POST)
    Given valid token 'abc123' exists in the database
    When I send a POST request to '/verify' with payload:
      | token | "abc123" |
      | code  | "7890"   |
    Then the response status should be 405
    And the response body should contain error message 'Method Not Allowed'
