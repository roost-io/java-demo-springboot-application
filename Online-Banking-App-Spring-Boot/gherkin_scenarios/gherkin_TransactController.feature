Feature: TransactController API Functional Testing

  Background:
    Given the API base URL is "https://api.bank.com"
    And the user "jane.doe" with user_id "1001" is authenticated with token "valid-token"
    And jane.doe has the following accounts:
      | account_id | user_id | account_number | account_name    | account_type | balance | create_at           | updated_at           |
      | 20001      | 1001    | 9876543210     | Main SAccount   | Savings      | 5000.00 | 2024-06-01T08:00:00 | 2024-06-01T08:00:00  |
      | 20002      | 1001    | 9876543211     | Travel Fund     | Checking     | 1500.00 | 2024-06-01T08:00:00 | 2024-06-01T08:00:00  |

  @smoke
  Scenario: Deposit funds successfully
    When I send a POST request to "/transact/deposit" with JSON:
      """
      {
        "deposit_amount": 2000,
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 200
    And the "accounts" object in response should show updated balance for account_id 20001 as 7000.00

  @regression
  Scenario: Deposit with missing deposit_amount
    When I send a POST request to "/transact/deposit" with JSON:
      """
      {
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "deposit_amount is required"

  @regression
  Scenario: Deposit with zero deposit_amount
    When I send a POST request to "/transact/deposit" with JSON:
      """
      {
        "deposit_amount": 0,
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "deposit_amount must be greater than zero"

  @regression
  Scenario: Deposit without authentication
    When I send a POST request to "/transact/deposit" with JSON:
      """
      {
        "deposit_amount": 500,
        "account_id": 20001
      }
      """
      And no user session header
    Then the response status should be 401
    And the response message should be "authentication required"

  @smoke
  Scenario: Transfer funds successfully
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": 20001,
        "targetAccount": 20002,
        "amount": 300
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 200
    And the accounts in response should show account_id 20001 with balance 4700.00 and account_id 20002 with balance 1800.00

  @regression
  Scenario: Transfer with empty fields
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": "",
        "targetAccount": 20002,
        "amount": 200
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "sourceAccount is required"

  @regression
  Scenario: Transfer to same account
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": 20001,
        "targetAccount": 20001,
        "amount": 150
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "sourceAccount and targetAccount must be different"

  @regression
  Scenario: Transfer with zero amount
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": 20001,
        "targetAccount": 20002,
        "amount": 0
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "amount must be greater than zero"

  @regression
  Scenario: Transfer with insufficient funds
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": 20002,
        "targetAccount": 20001,
        "amount": 2300
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "insufficient funds"

  @regression
  Scenario: Transfer without authentication
    When I send a POST request to "/transact/transfer" with JSON:
      """
      {
        "sourceAccount": 20001,
        "targetAccount": 20002,
        "amount": 150
      }
      """
      And no user session header
    Then the response status should be 401
    And the response message should be "authentication required"

  @smoke
  Scenario: Withdraw funds successfully
    When I send a POST request to "/transact/withdraw" with JSON:
      """
      {
        "withdrawal_amount": 800,
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 200
    And the "accounts" object in response should show updated balance for account_id 20001 as 4200.00

  @regression
  Scenario: Withdraw with missing fields
    When I send a POST request to "/transact/withdraw" with JSON:
      """
      {
        "withdrawal_amount": 800
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "account_id is required"

  @regression
  Scenario: Withdraw with zero amount
    When I send a POST request to "/transact/withdraw" with JSON:
      """
      {
        "withdrawal_amount": 0,
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "withdrawal_amount must be greater than zero"

  @regression
  Scenario: Withdraw with insufficient funds
    When I send a POST request to "/transact/withdraw" with JSON:
      """
      {
        "withdrawal_amount": 6000,
        "account_id": 20001
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "insufficient funds"

  @regression
  Scenario: Withdraw without authentication
    When I send a POST request to "/transact/withdraw" with JSON:
      """
      {
        "withdrawal_amount": 500,
        "account_id": 20001
      }
      """
      And no user session header
    Then the response status should be 401
    And the response message should be "authentication required"

  @smoke
  Scenario: Process payment successfully
    When I send a POST request to "/transact/payment" with JSON:
      """
      {
        "beneficiary": "Acme Utilities",
        "account_number": "1112223333",
        "account_id": 20002,
        "reference": "June Utilities",
        "payment_amount": 400
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 200
    And the "accounts" object in response should show updated balance for account_id 20002 as 1100.00

  @regression
  Scenario: Payment with missing beneficiary
    When I send a POST request to "/transact/payment" with JSON:
      """
      {
        "account_number": "1112223333",
        "account_id": 20002,
        "reference": "June Utilities",
        "payment_amount": 400
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "beneficiary is required"

  @regression
  Scenario: Payment with zero amount
    When I send a POST request to "/transact/payment" with JSON:
      """
      {
        "beneficiary": "Acme Utilities",
        "account_number": "1112223333",
        "account_id": 20002,
        "reference": "June Utilities",
        "payment_amount": 0
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "payment_amount must be greater than zero"

  @regression
  Scenario: Payment with insufficient funds
    When I send a POST request to "/transact/payment" with JSON:
      """
      {
        "beneficiary": "Acme Utilities",
        "account_number": "1112223333",
        "account_id": 20002,
        "reference": "June Utilities",
        "payment_amount": 1600
      }
      """
      And user session header "Authorization" with "Bearer valid-token"
    Then the response status should be 400
    And the response message should be "insufficient funds"

  @regression
  Scenario: Payment without authentication
    When I send a POST request to "/transact/payment" with JSON:
      """
      {
        "beneficiary": "Acme Utilities",
        "account_number": "1112223333",
        "account_id": 20002,
        "reference": "June Utilities",
        "payment_amount": 400
      }
      """
      And no user session header
    Then the response status should be 401
    And the response message should be "authentication required"
