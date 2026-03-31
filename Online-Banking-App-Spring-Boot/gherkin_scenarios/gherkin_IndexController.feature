Feature: IndexController API Functional Tests

  Background:
    Given the API base URL is "https://api.example.com"
    And all requests include header "Accept: application/json"

  @smoke @regression
  Scenario: GET / returns welcome text (happy path)
    When I send a GET request to "/"
    Then the response status code should be 200
    And the response content type should be "text/plain"
    And the response body should be equal to "Welcome to Example API!"

  @smoke @regression
  Scenario: GET /verify returns verification success for valid token and code (happy path)
    Given I have a valid token "abc123xyz" and code "456789"
    When I send a GET request to "/verify?token=abc123xyz&code=456789"
    Then the response status code should be 200
    And the response content type should be "application/json"
    And the response body should be valid JSON
    And the response JSON should contain:
      | key         | value                |
      | verified    | true                 |
      | user_id     | 42                   |
      | message     | "Verification successful." |

  @regression
  Scenario: GET /verify returns error for missing token
    When I send a GET request to "/verify?code=456789"
    Then the response status code should be 400
    And the response content type should be "text/plain"
    And the response body should be equal to "This session has expire."

  @regression
  Scenario: GET /verify returns error for missing code
    When I send a GET request to "/verify?token=abc123xyz"
    Then the response status code should be 400
    And the response content type should be "text/plain"
    And the response body should be equal to "This session has expire."

  @regression
  Scenario: GET /verify returns error for invalid token
    When I send a GET request to "/verify?token=invalidToken&code=456789"
    Then the response status code should be 400
    And the response content type should be "text/plain"
    And the response body should be equal to "This session has expire."

  @regression
  Scenario: GET /verify returns error for invalid code
    When I send a GET request to "/verify?token=abc123xyz&code=wrongCode"
    Then the response status code should be 400
    And the response content type should be "text/plain"
    And the response body should be equal to "This session has expire."

  @regression
  Scenario: GET /verify returns error for expired session
    Given the token "expiredToken" and code "456789" belong to an expired session
    When I send a GET request to "/verify?token=expiredToken&code=456789"
    Then the response status code should be 400
    And the response content type should be "text/plain"
    And the response body should be equal to "This session has expire."