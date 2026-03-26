Feature: IndexController API Endpoints

  Background:
    Given the API server is running and available

  @smoke
  Scenario: Successful index greeting
    When I send a GET request to "/"
    Then the response status should be 200
    And the response body should contain a greeting string

  @smoke
  Scenario: Successful verification with valid token and code
    When I send a GET request to "/verify" with query parameters:
      | token               | code   |
      | "abcd1234efgh5678" | "9900" |
    Then the response status should be 200
    And the response body should be:
      """
      {
        "message": "Verification successful"
      }
      """

  @regression
  Scenario: Verification fails with invalid token
    When I send a GET request to "/verify" with query parameters:
      | token               | code   |
      | "invalidtoken2345"  | "9900" |
    Then the response status should be 400
    And the response body should contain "Session expired or invalid token"

  @regression
  Scenario: Verification fails when token is missing
    When I send a GET request to "/verify" with query parameters:
      | code   |
      | "9900" |
    Then the response status should be 400
    And the response body should contain "Session expired or invalid token"

  @regression
  Scenario: Verification fails when code is missing
    When I send a GET request to "/verify" with query parameters:
      | token               |
      | "abcd1234efgh5678"  |
    Then the response status should be 400
    And the response body should contain "Session expired or invalid token"
