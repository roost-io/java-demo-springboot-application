Feature: TransactController Endpoints
  Comprehensive feature tests for all transaction endpoints: deposit, transfer, withdraw, and payment.

  Background:
    Given the API is available

  ########################################################################
  ## POST /transact/deposit
  ########################################################################

  @smoke
  Scenario: Successful deposit to a valid account
    Given a user "user123" is authenticated
    And the user has an account with ID "acct-1001" and balance "1000.00"
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount | 500.00   |
      | account_id     | acct-1001 |
    Then the response status should be 200
    And the response should contain message "Deposit successful"
    And the response should include account "acct-1001" with a balance of "1500.00"

  @regression
  Scenario: Deposit with empty deposit_amount field
    Given a user "user123" is authenticated
    And the user has an account with ID "acct-1002" and balance "200.00"
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount |          |
      | account_id     | acct-1002 |
    Then the response status should be 400
    And the response should contain message "Deposit amount is required"

  @regression
  Scenario: Deposit with invalid deposit amount (negative number)
    Given a user "user123" is authenticated
    And the user has an account with ID "acct-1003" and balance "200.00"
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount | -50.00    |
      | account_id     | acct-1003 |
    Then the response status should be 400
    And the response should contain message "Deposit amount must be positive"

  @regression
  Scenario: Deposit with non-numeric amount
    Given a user "user123" is authenticated
    And the user has an account with ID "acct-1004" and balance "0.00"
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount | fifty    |
      | account_id     | acct-1004 |
    Then the response status should be 400
    And the response should contain message "Deposit amount must be a valid number"

  @regression
  Scenario: Deposit to non-existent account
    Given a user "user123" is authenticated
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount | 50.00        |
      | account_id     | acct-nonexist |
    Then the response status should be 400
    And the response should contain message "Invalid account ID"

  @regression
  Scenario: Deposit with unauthenticated user
    Given the user is not authenticated
    When the user sends a POST request to "/transact/deposit" with:
      | deposit_amount | 100.00   |
      | account_id     | acct-1005 |
    Then the response status should be 401

  ########################################################################
  ## POST /transact/transfer
  ########################################################################

  @smoke
  Scenario: Successful transfer between two accounts
    Given a user "user234" is authenticated
    And the user has two accounts:
      | account_id  | balance  |
      | acct-2001   | 500.00   |
      | acct-2002   | 100.00   |
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2001 |
      | targetAccount | acct-2002 |
      | amount        | 200.00    |
    Then the response status should be 200
    And the response should contain message "Transfer completed successfully"
    And the response should include account "acct-2001" with a balance of "300.00"
    And the response should include account "acct-2002" with a balance of "300.00"

  @regression
  Scenario: Transfer with insufficient funds
    Given a user "user234" is authenticated
    And the user has two accounts:
      | account_id  | balance  |
      | acct-2003   | 50.00    |
      | acct-2004   | 500.00   |
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2003 |
      | targetAccount | acct-2004 |
      | amount        | 100.00    |
    Then the response status should be 400
    And the response should contain message "Insufficient funds"

  @regression
  Scenario: Transfer to same account
    Given a user "user234" is authenticated
    And the user has an account with ID "acct-2005" and balance "1000.00"
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2005 |
      | targetAccount | acct-2005 |
      | amount        | 10.00     |
    Then the response status should be 400
    And the response should contain message "Source and target accounts must be different"

  @regression
  Scenario: Transfer with missing amount field
    Given a user "user234" is authenticated
    And the user has two accounts:
      | account_id  | balance  |
      | acct-2006   | 100.00   |
      | acct-2007   | 50.00    |
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2006 |
      | targetAccount | acct-2007 |
      | amount        |           |
    Then the response status should be 400
    And the response should contain message "Transfer amount is required"

  @regression
  Scenario: Transfer with non-numeric amount
    Given a user "user234" is authenticated
    And the user has two accounts:
      | account_id  | balance  |
      | acct-2008   | 100.00   |
      | acct-2009   | 100.00   |
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2008 |
      | targetAccount | acct-2009 |
      | amount        | one hundred|
    Then the response status should be 400
    And the response should contain message "Amount must be a valid number"

  @regression
  Scenario: Transfer with unauthenticated user
    Given the user is not authenticated
    When the user sends a POST request to "/transact/transfer" with:
      | sourceAccount | acct-2010 |
      | targetAccount | acct-2011 |
      | amount        | 20.00     |
    Then the response status should be 401

  ########################################################################
  ## POST /transact/withdraw
  ########################################################################

  @smoke
  Scenario: Successful withdrawal from an account
    Given a user "user345" is authenticated
    And the user has an account with ID "acct-3001" and balance "1000.00"
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | 400.00   |
      | account_id        | acct-3001 |
    Then the response status should be 200
    And the response should contain message "Withdrawal successful"
    And the response should include account "acct-3001" with a balance of "600.00"

  @regression
  Scenario: Withdrawal with insufficient funds
    Given a user "user345" is authenticated
    And the user has an account with ID "acct-3002" and balance "50.00"
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | 100.00    |
      | account_id        | acct-3002 |
    Then the response status should be 400
    And the response should contain message "Insufficient funds"

  @regression
  Scenario: Withdrawal with non-numeric amount
    Given a user "user345" is authenticated
    And the user has an account with ID "acct-3003" and balance "0.00"
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | one hundred |
      | account_id        | acct-3003   |
    Then the response status should be 400
    And the response should contain message "Withdrawal amount must be a valid number"

  @regression
  Scenario: Withdrawal with negative amount
    Given a user "user345" is authenticated
    And the user has an account with ID "acct-3004" and balance "300.00"
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | -50.00     |
      | account_id        | acct-3004  |
    Then the response status should be 400
    And the response should contain message "Withdrawal amount must be positive"

  @regression
  Scenario: Withdrawal from non-existent account
    Given a user "user345" is authenticated
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | 20.00    |
      | account_id        | acct-nonexist |
    Then the response status should be 400
    And the response should contain message "Invalid account ID"

  @regression
  Scenario: Withdrawal with unauthenticated user
    Given the user is not authenticated
    When the user sends a POST request to "/transact/withdraw" with:
      | withdrawal_amount | 100.00   |
      | account_id        | acct-3005 |
    Then the response status should be 401

  ########################################################################
  ## POST /transact/payment
  ########################################################################

  @smoke
  Scenario: Successful payment to a beneficiary
    Given a user "user456" is authenticated
    And the user has an account with ID "acct-4001" and balance "2000.00"
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     | "John Doe"       |
      | account_number  | "0987654321"     |
      | account_id      | acct-4001        |
      | reference       | "Invoice #1234"  |
      | payment_amount  | 575.75           |
    Then the response status should be 200
    And the response should contain message "Payment processed successfully"
    And the response should include account "acct-4001" with a balance of "1424.25"

  @regression
  Scenario: Payment with insufficient funds
    Given a user "user456" is authenticated
    And the user has an account with ID "acct-4002" and balance "40.00"
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     | "Acme Corp"      |
      | account_number  | "1234567890"     |
      | account_id      | acct-4002        |
      | reference       | "Bill #987"      |
      | payment_amount  | 100.00           |
    Then the response status should be 400
    And the response should contain message "Insufficient funds"

  @regression
  Scenario: Payment with non-numeric payment amount
    Given a user "user456" is authenticated
    And the user has an account with ID "acct-4003" and balance "500.00"
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     | "Alice Smith"    |
      | account_number  | "1122334455"     |
      | account_id      | acct-4003        |
      | reference       | "Service"        |
      | payment_amount  | five hundred     |
    Then the response status should be 400
    And the response should contain message "Payment amount must be a valid number"

  @regression
  Scenario: Payment with missing beneficiary field
    Given a user "user456" is authenticated
    And the user has an account with ID "acct-4004" and balance "1000.00"
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     |                  |
      | account_number  | "5566778899"     |
      | account_id      | acct-4004        |
      | reference       | "Purchase"       |
      | payment_amount  | 150.00           |
    Then the response status should be 400
    And the response should contain message "Beneficiary is required"

  @regression
  Scenario: Payment with empty payment amount
    Given a user "user456" is authenticated
    And the user has an account with ID "acct-4005" and balance "200.00"
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     | "Bob White"      |
      | account_number  | "2233445566"     |
      | account_id      | acct-4005        |
      | reference       | "Order #1"       |
      | payment_amount  |                  |
    Then the response status should be 400
    And the response should contain message "Payment amount is required"

  @regression
  Scenario: Payment with unauthenticated user
    Given the user is not authenticated
    When the user sends a POST request to "/transact/payment" with:
      | beneficiary     | "Alice"          |
      | account_number  | "3344556677"     |
      | account_id      | acct-4006        |
      | reference       | "Test pay"       |
      | payment_amount  | 30.00            |
    Then the response status should be 401
