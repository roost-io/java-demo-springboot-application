Feature: User Registration API

  The POST /register endpoint allows new users to register.
  The endpoint validates field presence, length, correctness, and password confirmation.

  @smoke
  Scenario: Successful registration with valid data
    Given the following user registration payload:
      | first_name | last_name | email               | password  |
      | Alice      | Johnson   | alice@example.com   | Secret123 |
    And the confirm_password query parameter is "Secret123"
    When I send a POST request to /register
    Then the response status should be 200
    And the response body should contain "User registered successfully"
    And the response body should include the user:
      | first_name | last_name | email               |
      | Alice      | Johnson   | alice@example.com   |

  @regression
  Scenario Outline: Field validation - missing or invalid fields
    Given the following user registration payload:
      | first_name   | last_name   | email                | password      |
      | <first_name> | <last_name> | <email>              | <password>    |
    And the confirm_password query parameter is "<confirm_password>"
    When I send a POST request to /register
    Then the response status should be 400
    And the response body should contain "<error_message>"

    Examples:
      | first_name | last_name | email             | password   | confirm_password | error_message                                               |
      |            | Smith     | smith@example.com | Pass123!   | Pass123!         | "first_name cannot be empty"                                |
      | Jo         | Doe       | joe@example.com   | MySecret   | MySecret         | "first_name must be at least 3 characters"                  |
      | Jane       |           | jane@example.com  | Secretp@ss | Secretp@ss       | "last_name cannot be empty"                                 |
      | Jenna      | Li        | jen.com           | p@ssw0rd   | p@ssw0rd         | "email is not a valid email address"                        |
      | Tom        | Stark     | tom@example.com   |            |                  | "password cannot be empty"                                  |
      | Emma       | Stone     | emma@example.com  | StonePwd   |                  | "confirm_password cannot be empty"                          |

  @regression
  Scenario: Password confirmation mismatch
    Given the following user registration payload:
      | first_name | last_name | email             | password    |
      | Mark       | Hill      | mark@example.com  | MyPass123   |
    And the confirm_password query parameter is "WrongPass123"
    When I send a POST request to /register
    Then the response status should be 400
    And the response body should contain "Password and confirm_password do not match"

  @regression
  Scenario: Registration with already existing email
    Given the user with email "existing@example.com" has already registered
    And the following user registration payload:
      | first_name | last_name | email                | password  |
      | Grace      | Lee       | existing@example.com | GracePwd1 |
    And the confirm_password query parameter is "GracePwd1"
    When I send a POST request to /register
    Then the response status should be 400
    And the response body should contain "Email already exists"

  @regression
  Scenario Outline: Edge cases for field boundaries and whitespace
    Given the following user registration payload:
      | first_name   | last_name     | email                | password    |
      | <first_name> | <last_name>   | <email>              | <password>  |
    And the confirm_password query parameter is "<confirm_password>"
    When I send a POST request to /register
    Then the response status should be <status>
    And the response body should contain "<error_or_success_message>"

    Examples:
      | first_name   | last_name      | email                | password    | confirm_password | status | error_or_success_message                         |
      | Ana          | Li             | ana.li@example.com   | Pass@123    | Pass@123         | 200    | "User registered successfully"                   |
      |   Ana        | Li             | ana.li@example.com   | Pass@123    | Pass@123         | 400    | "first_name cannot start or end with whitespace" |
      | Ana          |   Li           | ana.li@example.com   | Pass@123    | Pass@123         | 400    | "last_name cannot start or end with whitespace"  |
      | Ann          | Lee            | ann@example.com      |   Pass123   |   Pass123        | 400    | "password cannot start or end with whitespace"   |
      | Jo3          | Doe            | jo3@example.com      | pass123     | pass123          | 200    | "User registered successfully"                   |
      |              | Lee            | lee@example.com      | 12345678    | 12345678         | 400    | "first_name cannot be empty"                     |
      | Max          |                | max@example.com      | maxpwd123   | maxpwd123        | 400    | "last_name cannot be empty"                      |
      | Alice        | Johnson        |                      | alicepwd    | alicepwd         | 400    | "email cannot be empty"                          |
      | Sam          | White          | sam@example.com      |             |                  | 400    | "password cannot be empty"                       |