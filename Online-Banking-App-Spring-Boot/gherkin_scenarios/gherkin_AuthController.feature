Feature: AuthController API Functional Tests

  Background:
    Given the AuthController API is available

  @smoke
  Scenario: Successful login with valid credentials
    Given a user exists with email "alice@example.com" and password "StrongPass123" and is verified
    When I send a POST request to "/login" with JSON body:
      """
      {
        "email": "alice@example.com",
        "password": "StrongPass123"
      }
      """
    Then the response status should be 200
    And the response JSON should contain:
      | message      | Authentication confirmed |
      | access_token | <not empty>              |

  @regression
  Scenario: Login attempt with empty email and password
    When I send a POST request to "/login" with JSON body:
      """
      {
        "email": "",
        "password": ""
      }
      """
    Then the response status should be 400
    And the response JSON should contain:
      | message | Username or Password cannot be empty |

  @regression
  Scenario: Login attempt with incorrect password
    Given a user exists with email "bob@example.com" and password "Secure!456" and is verified
    When I send a POST request to "/login" with JSON body:
      """
      {
        "email": "bob@example.com",
        "password": "WrongPassword"
      }
      """
    Then the response status should be 401
    And the response JSON should contain:
      | message | Incorrect Username or Password |

  @regression
  Scenario: Login attempt with unverified account
    Given a user exists with email "eve@example.com" and password "TopSecret789" and is not verified
    When I send a POST request to "/login" with JSON body:
      """
      {
        "email": "eve@example.com",
        "password": "TopSecret789"
      }
      """
    Then the response status should be 403
    And the response JSON should contain:
      | message | Account verification required |

  @regression
  Scenario: Login attempt with email not found in the system
    When I send a POST request to "/login" with JSON body:
      """
      {
        "email": "notfound@example.com",
        "password": "AnyPassword"
      }
      """
    Then the response status should be 500
    And the response JSON should contain:
      | message | Something went wrong (email not found) |

  @smoke
  Scenario: Successful logout
    Given a user is authenticated and their sessionParam is "user"
    When I send a GET request to "/logout" with parameter "user"
    Then the response status should be 200
    And the response JSON should contain:
      | message | Logged out successfully |
