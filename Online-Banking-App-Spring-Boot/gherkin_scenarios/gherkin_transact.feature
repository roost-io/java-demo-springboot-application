Feature: Transaction API Endpoints - Deposit, Withdraw, Transfer, and Payment

  Comprehensive tests for core transaction actions under TransactController.
  Covers happy paths, validation, authentication, and edge cases.
  All endpoints require an authenticated user session.

  Background:
    Given a user with valid credentials is authenticated
    And the user has an account with id "ACC123" and a balance of 1000.00
    And another valid account with id "ACC456"
    And the system accepts decimal amounts up to two places

  #---------------------- DEPOSIT ENDPOINT TESTS ---------------------------

  @smoke
  Scenario: Successful deposit to an account
    When the user sends a POST request to /transact/deposit with:
      | deposit_amount | account_id |
      | 150.50        | ACC123     |
    Then the response status should be 200
    And the response should contain a success message
    And the account "ACC123" balance should increase by 150.50

  @regression
  Scenario Outline: Deposit with missing or invalid amount or account_id
    When the user sends a POST request to /transact/deposit with:
      | deposit_amount | account_id |
      | <amount>       | <account>  |
    Then the response status should be 400
    And the error message should indicate "<error>"

    Examples:
      | amount | account   | error                                 |
      |        | ACC123    | deposit_amount is required            |
      | 0      | ACC123    | deposit_amount must be greater than 0 |
      | -50    | ACC123    | deposit_amount must be greater than 0 |
      | 200    |           | account_id is required                |
      |        |           | deposit_amount and account_id required|
      | abc    | ACC123    | deposit_amount is not a valid number  |
      | 1e9    | ACC123    | deposit_amount exceeds allowed limit  |

  @regression
  Scenario: Deposit when unauthenticated
    Given the user is not authenticated
    When the user sends a POST request to /transact/deposit with:
      | deposit_amount | account_id |
      | 100            | ACC123     |
    Then the response status should be 401
    And the error message should indicate authentication is required

  @regression
  Scenario Outline: Deposit with edge/boundary values for amount or account_id
    When the user sends a POST request to /transact/deposit with:
      | deposit_amount | account_id |
      | <amount>       | <account>  |
    Then the response status should be 400
    And the error message should indicate "<error>"

    Examples:
      | amount       | account   | error                                      |
      | 0.0001       | ACC123    | deposit_amount must be greater than 0      |
      | 1000000000   | ACC123    | deposit_amount exceeds allowed limit        |
      | 50           |           | account_id is required                     |
      | 100          | "   "     | account_id cannot be blank or whitespace    |


  #---------------------- WITHDRAW ENDPOINT TESTS ---------------------------

  @smoke
  Scenario: Successful withdrawal from an account
    When the user sends a POST request to /transact/withdraw with:
      | withdrawal_amount | account_id |
      | 200.00           | ACC123     |
    Then the response status should be 200
    And the response should contain a success message
    And the account "ACC123" balance should decrease by 200.00

  @regression
  Scenario Outline: Withdraw with insufficient funds, missing, or invalid amount
    When the user sends a POST request to /transact/withdraw with:
      | withdrawal_amount | account_id |
      | <amount>          | <account>  |
    Then the response status should be 400
    And the error message should indicate "<error>"

    Examples:
      | amount | account   | error                                               |
      | 0      | ACC123    | withdrawal_amount must be greater than 0            |
      | -10    | ACC123    | withdrawal_amount must be greater than 0            |
      | 2000   | ACC123    | insufficient funds                                  |
      |        | ACC123    | withdrawal_amount is required                       |
      | 50     |           | account_id is required                              |
      | abc    | ACC123    | withdrawal_amount is not a valid number             |
      | 100    | "   "     | account_id cannot be blank or whitespace            |

  #----------------------- TRANSFER ENDPOINT TESTS ---------------------------

  @smoke
  Scenario: Successful transfer between two accounts
    When the user sends a POST request to /transact/transfer with:
      | source_account_id | target_account_id | amount  |
      | ACC123            | ACC456            | 300.00  |
    Then the response status should be 200
    And the response should contain a success message
    And the account "ACC123" balance should decrease by 300.00
    And the account "ACC456" balance should increase by 300.00

  @regression
  Scenario Outline: Transfer with insufficient funds, invalid account IDs, or amounts
    When the user sends a POST request to /transact/transfer with:
      | source_account_id | target_account_id | amount |
      | <source>          | <target>          | <amt>  |
    Then the response status should be 400
    And the error message should indicate "<error>"

    Examples:
      | source  | target  | amt   | error                                         |
      | ACC123  | ACC456  | 0     | amount must be greater than 0                 |
      | ACC123  | ACC456  | -100  | amount must be greater than 0                 |
      | ACC123  | ACC456  | 5000  | insufficient funds                            |
      | ACC999  | ACC456  | 100   | invalid source_account_id                     |
      | ACC123  | ACC999  | 100   | invalid target_account_id                     |
      |         | ACC456  | 100   | source_account_id is required                 |
      | ACC123  |         | 100   | target_account_id is required                 |
      | ACC123  | ACC456  | abc   | amount is not a valid number                  |
      | ACC123  | ACC123  | 100   | source and target accounts must be different  |
      | "   "   | ACC456  | 100   | source_account_id cannot be blank/whitespace  |

  #------------------------ PAYMENT ENDPOINT TESTS ---------------------------

  @smoke
  Scenario: Successful payment to a beneficiary
    When the user sends a POST request to /transact/payment with:
      | beneficiary | account_number | account_id | payment_amount | reference  |
      | "John Doe"  | "98765432"     | ACC123     | 250.00        | "INVOICE1" |
    Then the response status should be 200
    And the response should contain a success message
    And the account "ACC123" balance should decrease by 250.00
    And a Payment record should be created for "John Doe", "98765432", and 250.00

  @regression
  Scenario Outline: Payment with missing, zero, or invalid fields or insufficient funds
    When the user sends a POST request to /transact/payment with:
      | beneficiary | account_number | account_id | payment_amount | reference |
      | <benef>     | <accno>        | <aid>      | <amt>          | <ref>     |
    Then the response status should be 400
    And the error message should indicate "<error>"

    Examples:
      | benef      | accno     | aid     | amt   | ref     | error                                  |
      |            | 98765432  | ACC123  | 100   | REF1    | beneficiary is required                |
      | John Doe   |           | ACC123  | 100   | REF1    | account_number is required             |
      | John Doe   | 98765432  |         | 100   | REF1    | account_id is required                 |
      | John Doe   | 98765432  | ACC123  | 0     | REF1    | payment_amount must be > 0             |
      | John Doe   | 98765432  | ACC123  | -50   | REF1    | payment_amount must be > 0             |
      | John Doe   | 98765432  | ACC123  | 1200  | REF1    | insufficient funds                     |
      | John Doe   | 98765432  | ACC123  | abc   | REF1    | payment_amount is not a valid number   |
      | John Doe   | 98765432  | ACC123  | 100   |         | reference is required                  |
      | John Doe   | 98765432  | "   "   | 100   | REF1    | account_id cannot be blank/whitespace  |

  @regression
  Scenario: Payment with very large amount
    When the user sends a POST request to /transact/payment with:
      | beneficiary | account_number | account_id | payment_amount | reference  |
      | John Doe    | 98765432       | ACC123     | 1000000000     | REF2       |
    Then the response status should be 400
    And the error message should indicate payment_amount exceeds allowed limit
