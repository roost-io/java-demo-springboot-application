Feature: User Registration and Email Verification for Banking System

  Background:
    Given the registration endpoint is available at "/register"
    And the verification endpoint is available at "/verify"

  @smoke @registration
  Scenario: Successful user registration with valid data
    When I submit a POST request to "/register" with a valid User model and confirm_password that matches the password
    Then the response status should be 201
    And the response should include the registered user details
    And the response should contain a success message

  @smoke @verification
  Scenario: Successful email verification with valid token and code
    Given I have registered and received a verification token and code
    When I send a GET request to "/verify" with the valid token and code as query parameters
    Then the response status should be 200
    And the response should include a verification success message

  @negative @registration
  Scenario: Registration fails when required fields are missing
    When I submit a POST request to "/register" with missing required fields in the User model
    Then the response status should be 400
    And the response should contain an error describing the missing fields

  @negative @registration
  Scenario: Registration fails when passwords do not match
    When I submit a POST request to "/register" with mismatched password and confirm_password
    Then the response status should be 400
    And the response should include an error message about password mismatch

  @negative @registration
  Scenario: Registration fails with invalid field formats
    When I submit a POST request to "/register" with an invalid email format in the User model
    Then the response status should be 400
    And the response should include an error message about email format

  @negative @registration
  Scenario: Registration fails when username is already taken
    Given an existing user with username "johndoe"
    When I submit a POST request to "/register" with the username "johndoe"
    Then the response status should be 409
    And the response should include an error message about duplicate username

  @negative @verification
  Scenario: Verification fails when token is missing
    When I send a GET request to "/verify" with the code query parameter but missing the token
    Then the response status should be 400
    And the response should include an error message about the missing token

  @negative @verification
  Scenario: Verification fails when code is invalid
    When I send a GET request to "/verify" with a valid token and an invalid code
    Then the response status should be 400
    And the response should include an error message about invalid code

  @negative @verification
  Scenario: Verification fails when token is expired
    When I send a GET request to "/verify" with an expired token and valid code
    Then the response status should be 410
    And the response should include an error message about token expiration

  @edge @registration
  Scenario: Registration fails when password is exactly minimum allowed length
    When I submit a POST request to "/register" with a password of exactly the minimum length allowed
    Then the response status should be 201
    And the response should indicate registration is successful

  @edge @registration
  Scenario: Registration fails when extra unexpected fields are provided
    When I submit a POST request to "/register" with valid fields plus extra unexpected fields
    Then the response status should be 400
    And the response should mention unexpected fields

  @edge @verification
  Scenario: Verification fails when both token and code are blank
    When I send a GET request to "/verify" with both token and code as blank values
    Then the response status should be 400
    And the response should include an error message about missing required parameters

  @edge @registration
  Scenario: Registration fails with extremely long field input
    When I submit a POST request to "/register" with a username longer than the allowed maximum
    Then the response status should be 400
    And the response should include an error message about field length constraints

  @edge @verification
  Scenario: Verification fails when token and code are valid but already used
    Given the user has already completed verification with the given token and code
    When I send a GET request to "/verify" with the same token and code again
    Then the response status should be 409
    And the response should include an error message about already verified

  @edge @registration
  Scenario: Registration fails when fields have only whitespace
    When I submit a POST request to "/register" with whitespace-only values for username, email, or password
    Then the response status should be 400
    And the response should include an error message about invalid input

  @edge @registration
  Scenario: Registration fails when confirm_password is missing
    When I submit a POST request to "/register" without the confirm_password field
    Then the response status should be 400
    And the response should include an error message about missing confirm_password
