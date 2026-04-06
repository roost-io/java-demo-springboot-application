Feature: Deposit Funds
  As an authenticated user
  I want to deposit funds into my bank account
  So that I can increase my account balance

  @smoke
  Scenario: Successful deposit to valid account
    Given an authenticated user with account_id "ACC123"
    When the user deposits 100.00 into account "ACC123"
    Then the response should contain updated account information with increased balance

  @regression
  Scenario: Deposit without authentication
    Given an unauthenticated user
    When the user attempts to deposit 50.00 into account "ACC123"
    Then the response should be an authentication error

  @regression
  Scenario: Deposit to a non-existent account
    Given an authenticated user
    When the user deposits 100.00 into account "INVALID_ACC"
    Then the response should be an error indicating the account does not exist

  @edge
  Scenario: Deposit a negative amount
    Given an authenticated user with account_id "ACC123"
    When the user deposits -10.00 into account "ACC123"
    Then the response should be an error indicating invalid amount

  @edge
  Scenario: Deposit a very large amount
    Given an authenticated user with account_id "ACC123"
    When the user deposits 1000000000.00 into account "ACC123"
    Then the response should contain updated account information or a limit exceeded error


Feature: Money Transfer
  As an authenticated user
  I want to transfer funds between accounts
  So that I can move my money as needed

  @smoke
  Scenario: Successful transfer between two existing accounts
    Given an authenticated user with accounts "ACC001" and "ACC002"
    And "ACC001" has sufficient balance
    When the user transfers 200.00 from "ACC001" to "ACC002"
    Then the response should show the updated balances for both accounts

  @regression
  Scenario: Transfer with invalid authentication
    Given an unauthenticated user
    When the user attempts to transfer 20.00 from "ACC001" to "ACC002"
    Then the response should be an authentication error

  @regression
  Scenario: Transfer with insufficient funds
    Given an authenticated user with account "ACC001" having 10.00 balance
    When the user transfers 50.00 from "ACC001" to "ACC002"
    Then the response should be an error indicating insufficient funds

  @edge
  Scenario: Transfer negative amount
    Given an authenticated user with accounts "ACC001" and "ACC002"
    When the user attempts to transfer -100.00 from "ACC001" to "ACC002"
    Then the response should be an error indicating invalid amount

  @edge
  Scenario: Transfer very large amount
    Given an authenticated user with account "ACC001" having 2,000,000,000.00 balance
    When the user transfers 1,500,000,000.00 from "ACC001" to "ACC002"
    Then the response should show updated balances or a limit exceeded error


Feature: Withdraw Funds
  As an authenticated user
  I want to withdraw money from my bank account
  So that I can access my funds

  @smoke
  Scenario: Successful withdrawal from an account with sufficient funds
    Given an authenticated user with account_id "ACC123" and balance 500.00
    When the user withdraws 100.00 from account "ACC123"
    Then the response should contain account info with reduced balance

  @regression
  Scenario: Withdrawal without authentication
    Given an unauthenticated user
    When the user attempts to withdraw 20.00 from account "ACC123"
    Then the response should be an authentication error

  @regression
  Scenario: Withdraw amount exceeding account balance
    Given an authenticated user with account_id "ACC123" and balance 50.00
    When the user withdraws 100.00 from account "ACC123"
    Then the response should be an error indicating insufficient funds

  @edge
  Scenario: Withdraw negative amount
    Given an authenticated user with account_id "ACC123"
    When the user withdraws -50.00 from account "ACC123"
    Then the response should be an error indicating invalid amount

  @edge
  Scenario: Withdraw a very large amount
    Given an authenticated user with account_id "ACC123" and large balance
    When the user withdraws 1000000000.00 from account "ACC123"
    Then the response should contain updated account information or a limit exceeded error


Feature: Make Payment
  As an authenticated user
  I want to make a payment from my account
  So that I can pay bills or merchants

  @smoke
  Scenario: Successful payment to a valid payee
    Given an authenticated user with account_id "ACC789" and sufficient funds
    And a valid PaymentRequest to payee "MERCHANT123" for 250.00
    When the user submits the payment
    Then the response should contain updated account information with payment deducted

  @regression
  Scenario: Payment with invalid authentication
    Given an unauthenticated user
    When the user submits a PaymentRequest
    Then the response should be an authentication error

  @regression
  Scenario: Payment with insufficient funds
    Given an authenticated user with account_id "ACC789" and balance 10.00
    And a PaymentRequest to payee "MERCHANT123" for 100.00
    When the user submits the payment
    Then the response should be an error indicating insufficient funds

  @edge
  Scenario: Payment with negative amount
    Given an authenticated user with account_id "ACC789"
    And a PaymentRequest to payee "MERCHANT123" for -50.00
    When the user submits the payment
    Then the response should be an error indicating invalid amount

  @edge
  Scenario: Payment with very large amount
    Given an authenticated user with account_id "ACC789" and large balance
    And a PaymentRequest to payee "MERCHANT123" for 2000000000.00
    When the user submits the payment
    Then the response should contain updated account information or a limit exceeded error

