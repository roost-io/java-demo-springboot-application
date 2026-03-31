Feature: User Registration via POST /register
  As a new user
  I want to be able to register an account
  So that I can access protected features

  Background:
    Given the API endpoint "/register" is available
    And the following request headers are set:
      | Content-Type | application/json |

  @smoke
  Scenario: Successfully register with valid details and matching confirm_password
    Given the request body is:
      """
      {
        "name": "Alice Johnson",
        "email": "alice.johnson@example.com",
        "password": "S3cureP@ssword"
      }
      """
    And the query parameter "confirm_password" is set to "S3cureP@ssword"
    When I POST to "/register"
    Then the response status code should be 200
    And the response should include a user id and welcome message

  @regression
  Scenario: Registration fails with missing required fields
    Given the request body is:
      """
      {
        "email": "bob.smith@example.com",
        "password": "Pa$$word123"
      }
      """
    And the query parameter "confirm_password" is set to "Pa$$word123"
    When I POST to "/register"
    Then the response status code should be 400
    And the response body should contain "name is required"

  @regression
  Scenario: Registration fails when password and confirm_password do not match
    Given the request body is:
      """
      {
        "name": "Charlie Lee",
        "email": "charlie.lee@example.com",
        "password": "StrongPass1"
      }
      """
    And the query parameter "confirm_password" is set to "DifferentPass1"
    When I POST to "/register"
    Then the response status code should be 400
    And the response body should contain "Password and confirm_password do not match"

  @regression
  Scenario: Registration fails with invalid email format
    Given the request body is:
      """
      {
        "name": "Diana Miller",
        "email": "diana.miller[at]example",
        "password": "ValidP@ss123"
      }
      """
    And the query parameter "confirm_password" is set to "ValidP@ss123"
    When I POST to "/register"
    Then the response status code should be 400
    And the response body should contain "email must be a valid email address"