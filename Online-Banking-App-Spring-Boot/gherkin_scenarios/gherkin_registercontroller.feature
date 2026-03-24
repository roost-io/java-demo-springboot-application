Feature: User Registration API

  Background:
    Given the API is available

  @smoke
  Scenario: Successful user registration
    When I send a POST request to /register with the body:
      | first_name | last_name | email               | password    |
      | John       | Doe       | john.doe@email.com  | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 200
    And the response body should contain:
      | success | true        |
      | message | User registered successfully |

  @regression
  Scenario: Registration fails when required fields are missing
    When I send a POST request to /register with the body:
      | first_name | last_name | email               | password |
      |            | Doe       | john.doe@email.com  | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 400
    And the response body should contain:
      | error | "first_name is required" |

  @regression
  Scenario: Registration fails when first_name is too short
    When I send a POST request to /register with the body:
      | first_name | last_name | email              | password    |
      | Jo         | Doe       | jo.doe@email.com   | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 400
    And the response body should contain:
      | error | "first_name must be at least 3 characters" |

  @regression
  Scenario: Registration fails when last_name is too short
    When I send a POST request to /register with the body:
      | first_name | last_name | email              | password    |
      | John       | Do        | john.do@email.com  | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 400
    And the response body should contain:
      | error | "last_name must be at least 3 characters" |

  @regression
  Scenario: Registration fails with invalid email format
    When I send a POST request to /register with the body:
      | first_name | last_name | email      | password    |
      | Jane       | Smith     | janesmith  | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 400
    And the response body should contain:
      | error | "email must be a valid email address" |

  @regression
  Scenario: Registration fails when password and confirm_password do not match
    When I send a POST request to /register with the body:
      | first_name | last_name | email                | password    |
      | Alice      | Johnson   | alice.j@email.com    | StrongPass1 |
    And the query parameter "confirm_password" is "WrongPass2"
    Then the response code should be 400
    And the response body should contain:
      | error | "passwords do not match" |

  @regression
  Scenario: Registration fails when email is already registered
    Given a user exists with email "bob@example.com"
    When I send a POST request to /register with the body:
      | first_name | last_name | email             | password    |
      | Bob        | Builder   | bob@example.com   | StrongPass1 |
    And the query parameter "confirm_password" is "StrongPass1"
    Then the response code should be 400
    And the response body should contain:
      | error | "email already registered" |
