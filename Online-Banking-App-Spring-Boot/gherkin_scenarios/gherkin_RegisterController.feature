Feature: User Registration via RegisterController

  Background:
    Given the API server is running and accessible

  @smoke
  Scenario: Successful registration with valid input
    When I POST to "/register?confirm_password=SecureP@ss123" with JSON:
      """
      {
        "first_name": "John",
        "last_name": "Doe",
        "email": "john.doe@example.com",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 200
    And the response JSON should contain:
      | user_id      |
      | first_name   |
      | last_name    |
      | email        |
      | token        |
      | code         |
      | verified     |
      | verified_at  |
      | created_at   |
      | updated_at   |
    And the "email" in response should be "john.doe@example.com"
    And the "verified" in response should be false

  @regression
  Scenario: Registration fails when first_name is missing
    When I POST to "/register?confirm_password=SecureP@ss123" with JSON:
      """
      {
        "last_name": "Doe",
        "email": "missing.first@example.com",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "first_name is required"

  @regression
  Scenario: Registration fails when email is invalid
    When I POST to "/register?confirm_password=SecureP@ss123" with JSON:
      """
      {
        "first_name": "Alice",
        "last_name": "Smith",
        "email": "not-an-email",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "email is invalid"

  @regression
  Scenario: Registration fails when password and confirm_password do not match
    When I POST to "/register?confirm_password=NotMatching123" with JSON:
      """
      {
        "first_name": "Tom",
        "last_name": "Taylor",
        "email": "tom.taylor@example.com",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "passwords do not match"

  @regression
  Scenario: Registration fails when password is too short
    When I POST to "/register?confirm_password=Ab1!" with JSON:
      """
      {
        "first_name": "Kyle",
        "last_name": "Short",
        "email": "kyle.short@example.com",
        "password": "Ab1!"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "password is too short"

  @regression
  Scenario: Registration fails when password is too long
    When I POST to "/register?confirm_password=VeryLongP@ssword1234567890abcdefghi" with JSON:
      """
      {
        "first_name": "Lara",
        "last_name": "Long",
        "email": "lara.long@example.com",
        "password": "VeryLongP@ssword1234567890abcdefghi"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "password is too long"

  @regression
  Scenario: Registration fails when first_name contains invalid characters
    When I POST to "/register?confirm_password=SecureP@ss123" with JSON:
      """
      {
        "first_name": "J@hn#",
        "last_name": "Doe",
        "email": "invalid.chars@example.com",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "first_name is invalid"

  @regression
  Scenario: Registration fails when last_name is too long
    When I POST to "/register?confirm_password=SecureP@ss123" with JSON:
      """
      {
        "first_name": "Jane",
        "last_name": "ThisIsAReallyReallyLongLastNameThatExceedsTheLimit",
        "email": "jane.longlastname@example.com",
        "password": "SecureP@ss123"
      }
      """
    Then the response status should be 400
    And the response JSON should contain "last_name is too long"
