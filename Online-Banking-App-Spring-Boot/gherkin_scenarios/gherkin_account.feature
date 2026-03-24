Feature: Account creation via AccountController

  Background:
    Given the API is available

  @smoke
  Scenario: Successfully create a new Savings account
    Given I am an authenticated user with user_id 123
    When I send a POST request to /account/create_account with:
      | account_name | account_type |
      | My Savings   | Savings      |
    Then the response status should be 200
    And the response should be a JSON array of Account objects
    And at least one Account in the response should have:
      | user_id      | account_name | account_type |
      | 123          | My Savings   | Savings      |

  @regression
  Scenario: Successfully create a new Checking account with a unique name
    Given I am an authenticated user with user_id 456
    When I send a POST request to /account/create_account with:
      | account_name    | account_type |
      | Work Checking   | Checking     |
    Then the response status should be 200
    And the response should be a JSON array of Account objects
    And the array should contain at least one Account with:
      | user_id | account_name   | account_type |
      | 456     | Work Checking  | Checking     |

  @regression
  Scenario: Error when account_name is empty
    Given I am an authenticated user with user_id 789
    When I send a POST request to /account/create_account with:
      | account_name | account_type |
      |              | Savings      |
    Then the response status should be 400
    And the response should contain an error message "Account name or type is empty"

  @regression
  Scenario: Error when account_type is empty
    Given I am an authenticated user with user_id 321
    When I send a POST request to /account/create_account with:
      | account_name   | account_type |
      | Vacation Fund  |             |
    Then the response status should be 400
    And the response should contain an error message "Account name or type is empty"

  @regression
  Scenario: Error when both account_name and account_type are empty
    Given I am an authenticated user with user_id 555
    When I send a POST request to /account/create_account with:
      | account_name | account_type |
      |              |             |
    Then the response status should be 400
    And the response should contain an error message "Account name or type is empty"

  @regression
  Scenario: Error when not authenticated
    Given I am not authenticated
    When I send a POST request to /account/create_account with:
      | account_name | account_type |
      | Primary      | Checking     |
    Then the response status should be 401
    And the response should contain an error message "Unauthorized, not logged in"

  @regression
  Scenario: Create account with edge case account_name (maximum length)
    Given I am an authenticated user with user_id 888
    And the maximum allowed account_name length is 50 characters
    And I have an account_name that is exactly 50 characters long "A234567890123456789012345678901234567890123456789"
    When I send a POST request to /account/create_account with:
      | account_name                                       | account_type |
      | A234567890123456789012345678901234567890123456789   | Savings      |
    Then the response status should be 200
    And the array should contain at least one Account with:
      | user_id | account_name                                 | account_type |
      | 888     | A234567890123456789012345678901234567890123456789 | Savings      |

  @regression
  Scenario: Attempt to create account with extremely large account_name (over maximum length)
    Given I am an authenticated user with user_id 999
    And the maximum allowed account_name length is 50 characters
    And I have an account_name that is 60 characters long "A2345678901234567890123456789012345678901234567890123456789"
    When I send a POST request to /account/create_account with:
      | account_name                                         | account_type |
      | A2345678901234567890123456789012345678901234567890123456789 | Checking     |
    Then the response status should be 400
    And the response should contain an error message

  @regression
  Scenario: Attempt to create account with invalid account_type
    Given I am an authenticated user with user_id 222
    And "Investment" is not a supported account_type
    When I send a POST request to /account/create_account with:
      | account_name | account_type |
      | Stock Funds  | Investment   |
    Then the response status should be 400
    And the response should contain an error message "Account name or type is empty" or "Invalid account type"
