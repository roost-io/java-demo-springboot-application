Feature: Account Creation API

  Background:
    Given the API is available

  @smoke
  Scenario: Successful account creation
    Given a user is authenticated with a valid session cookie
    And the user provides "Personal Savings" as account_name
    And the user provides "savings" as account_type
    When the user sends a POST request to /account/create_account with the account_name and account_type
    Then the response status should be 200
    And the response should include the created account with account_name "Personal Savings" and account_type "savings"

  @regression
  Scenario: Missing account_name field
    Given a user is authenticated with a valid session cookie
    And the user provides no account_name
    And the user provides "checking" as account_type
    When the user sends a POST request to /account/create_account with only account_type
    Then the response status should be 400
    And the response should include an error message stating "account_name is required"

  @regression
  Scenario: Missing account_type field
    Given a user is authenticated with a valid session cookie
    And the user provides "Business Account" as account_name
    And the user provides no account_type
    When the user sends a POST request to /account/create_account with only account_name
    Then the response status should be 400
    And the response should include an error message stating "account_type is required"

  @regression
  Scenario: Unauthenticated access attempt
    Given the user is not authenticated
    And the user provides "Vacation Fund" as account_name
    And the user provides "savings" as account_type
    When the user sends a POST request to /account/create_account without a session cookie
    Then the response status should be 401
    And the response should include an error message stating "Authentication required"

  @regression
  Scenario: Empty account_name field
    Given a user is authenticated with a valid session cookie
    And the user provides "" as account_name
    And the user provides "checking" as account_type
    When the user sends a POST request to /account/create_account with empty account_name
    Then the response status should be 400
    And the response should include an error message stating "account_name cannot be empty"

  @regression
  Scenario: Empty account_type field
    Given a user is authenticated with a valid session cookie
    And the user provides "Travel Account" as account_name
    And the user provides "" as account_type
    When the user sends a POST request to /account/create_account with empty account_type
    Then the response status should be 400
    And the response should include an error message stating "account_type cannot be empty"

  @regression
  Scenario: Duplicate account_name creation attempt
    Given a user is authenticated with a valid session cookie
    And the user has already created an account with account_name "Personal Savings" and account_type "savings"
    And the user provides "Personal Savings" as account_name
    And the user provides "savings" as account_type
    When the user sends a POST request to /account/create_account with the same account_name and account_type
    Then the response status should be 400
    And the response should include an error message stating "account_name already exists"
