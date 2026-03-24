Feature: Money Transactions API

  As a user of the banking application,
  I want to be able to deposit, withdraw, transfer, and make payments,
  So that I can manage my funds easily and securely.

  Background:
    Given the API is available

  ########################## DEPOSIT ##########################

  @smoke
  Scenario: Successful deposit to an account
    Given a valid session token "valid-session"
    And an account exists with ID "ACC123"
    When I POST /transact/deposit with body:
      | deposit_amount | account_id | session        |
      | 100.00        | ACC123     | valid-session  |
    Then the response code should be 200
    And the response body should include "deposited": true

  @regression
  Scenario: Attempt to deposit with missing required field (amount)
    Given a valid session token "valid-session"
    And an account exists with ID "ACC123"
    When I POST /transact/deposit with body:
      | account_id | session        |
      | ACC123     | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Missing deposit_amount"

  @regression
  Scenario: Attempt to deposit zero amount
    Given a valid session token "valid-session"
    And an account exists with ID "ACC123"
    When I POST /transact/deposit with body:
      | deposit_amount | account_id | session        |
      | 0              | ACC123     | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Deposit amount must be greater than zero"

  @regression
  Scenario: Attempt to deposit with invalid session
    Given an account exists with ID "ACC123"
    When I POST /transact/deposit with body:
      | deposit_amount | account_id | session         |
      | 100.00         | ACC123     | invalid-session |
    Then the response code should be 401
    And the response body should include "error": "Unauthorized"

  ########################## WITHDRAW ##########################

  @smoke
  Scenario: Successful withdrawal from account
    Given a valid session token "valid-session"
    And an account "ACC123" has balance 500.00
    When I POST /transact/withdraw with body:
      | withdrawal_amount | account_id | session        |
      | 200.00           | ACC123     | valid-session  |
    Then the response code should be 200
    And the response body should include "withdrawn": true

  @regression
  Scenario: Withdraw more than available balance
    Given a valid session token "valid-session"
    And an account "ACC123" has balance 150.00
    When I POST /transact/withdraw with body:
      | withdrawal_amount | account_id | session        |
      | 500.00           | ACC123     | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Insufficient funds"

  @regression
  Scenario: Withdraw zero or negative amount
    Given a valid session token "valid-session"
    And an account "ACC123" has balance 100.00
    When I POST /transact/withdraw with body:
      | withdrawal_amount | account_id | session        |
      | 0                 | ACC123     | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Withdrawal amount must be greater than zero"

  @regression
  Scenario: Withdraw with no session (unauthorized)
    And an account exists with ID "ACC123"
    When I POST /transact/withdraw with body:
      | withdrawal_amount | account_id | session |
      | 20.00            | ACC123     |         |
    Then the response code should be 401
    And the response body should include "error": "Unauthorized"

  ########################## TRANSFER ##########################

  @smoke
  Scenario: Successful fund transfer between two accounts
    Given a valid session token "valid-session"
    And an account "SRC123" has balance 500.00
    And an account "DST456" exists
    When I POST /transact/transfer with body:
      | sourceAccount | targetAccount | amount | session        |
      | SRC123        | DST456        | 150.00 | valid-session  |
    Then the response code should be 200
    And the response body should include "transferred": true

  @regression
  Scenario: Attempt transfer with insufficient funds
    Given a valid session token "valid-session"
    And an account "SRC123" has balance 100.00
    And an account "DST456" exists
    When I POST /transact/transfer with body:
      | sourceAccount | targetAccount | amount  | session        |
      | SRC123        | DST456        | 200.00  | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Insufficient funds"

  @regression
  Scenario: Transfer to the same account
    Given a valid session token "valid-session"
    And an account "SRC123" has balance 500.00
    When I POST /transact/transfer with body:
      | sourceAccount | targetAccount | amount | session        |
      | SRC123        | SRC123        | 50.00  | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Cannot transfer to the same account"

  @regression
  Scenario: Attempt to transfer zero or negative amount
    Given a valid session token "valid-session"
    And an account "SRC123" has balance 1000.00
    And an account "DST456" exists
    When I POST /transact/transfer with body:
      | sourceAccount | targetAccount | amount | session        |
      | SRC123        | DST456        | 0      | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Transfer amount must be greater than zero"

  @regression
  Scenario: Attempt transfer with invalid session
    And an account "SRC123" has balance 200.00
    And an account "DST456" exists
    When I POST /transact/transfer with body:
      | sourceAccount | targetAccount | amount | session         |
      | SRC123        | DST456        | 50.00  | invalid-session |
    Then the response code should be 401
    And the response body should include "error": "Unauthorized"

  ########################## PAYMENT ##########################

  @smoke
  Scenario: Successful payment to a beneficiary
    Given a valid session token "valid-session"
    And an account "PAYACC123" has balance 500.00
    When I POST /transact/payment with body:
      | beneficiary         | account_id  | account_number | payment_amount | session        |
      | Alice & Co. Ltd.    | PAYACC123   | 789654123      | 120.00        | valid-session  |
    Then the response code should be 200
    And the response body should include "processed": true

  @regression
  Scenario: Payment with insufficient funds
    Given a valid session token "valid-session"
    And an account "PAYACC124" has balance 10.00
    When I POST /transact/payment with body:
      | beneficiary  | account_id  | account_number | payment_amount | session        |
      | Widgets Inc. | PAYACC124   | 654321987      | 100.00        | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Insufficient funds"

  @regression
  Scenario: Payment with zero payment amount
    Given a valid session token "valid-session"
    And an account "PAYACC125" has balance 1000.00
    When I POST /transact/payment with body:
      | beneficiary | account_id  | account_number | payment_amount | session        |
      | Jane Roe    | PAYACC125   | 111222333      | 0             | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Payment amount must be greater than zero"

  @regression
  Scenario: Payment with missing required beneficiary field
    Given a valid session token "valid-session"
    And an account "PAYACC127" has balance 200.00
    When I POST /transact/payment with body:
      | account_id  | account_number | payment_amount | session        |
      | PAYACC127   | 789456123      | 50.00         | valid-session  |
    Then the response code should be 400
    And the response body should include "error": "Missing beneficiary"

  @regression
  Scenario: Payment with unauthorized session
    And an account "PAYACC128" has balance 200.00
    When I POST /transact/payment with body:
      | beneficiary | account_id  | account_number | payment_amount | session         |
      | John Black  | PAYACC128   | 123456789      | 25.00         | invalid-session |
    Then the response code should be 401
    And the response body should include "error": "Unauthorized"
