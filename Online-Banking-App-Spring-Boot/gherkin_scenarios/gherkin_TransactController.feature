Feature: TransactController API Endpoints Functional Testing

  Background:
    Given the API base URL is "https://api.example.com"
    And I have valid user credentials as "user1" with password "password123"

  @smoke
  Scenario: Successful deposit to an account
    Given I am authorized as "user1"
    When I POST to "/transact/deposit" with body:
      | deposit_amount | 500            |
      | account_id     | ACC123456      |
    Then the response status should be 200
    And the response body should contain:
      | message         | Deposit successful      |
      | account_id      | ACC123456              |
      | deposit_amount  | 500                    |

  @regression
  Scenario: Deposit with invalid amount (missing deposit_amount)
    Given I am authorized as "user1"
    When I POST to "/transact/deposit" with body:
      | account_id      | ACC123456      |
    Then the response status should be 400
    And the response body should contain "deposit_amount is required"

  @regression
  Scenario: Deposit with non-numeric deposit_amount
    Given I am authorized as "user1"
    When I POST to "/transact/deposit" with body:
      | deposit_amount  | fifty          |
      | account_id      | ACC123456      |
    Then the response status should be 400
    And the response body should contain "deposit_amount must be a number"

  @regression
  Scenario: Deposit when unauthorized
    Given I am not authorized
    When I POST to "/transact/deposit" with body:
      | deposit_amount  | 500            |
      | account_id      | ACC123456      |
    Then the response status should be 401
    And the response body should contain "Unauthorized"

  @smoke
  Scenario: Successful withdrawal from an account
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 1000
    When I POST to "/transact/withdraw" with body:
      | withdrawal_amount | 250               |
      | account_id        | ACC123456         |
    Then the response status should be 200
    And the response body should contain:
      | message           | Withdrawal successful    |
      | account_id        | ACC123456               |
      | withdrawn_amount  | 250                     |

  @regression
  Scenario: Withdrawal with insufficient funds
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 100
    When I POST to "/transact/withdraw" with body:
      | withdrawal_amount | 200               |
      | account_id        | ACC123456         |
    Then the response status should be 400
    And the response body should contain "Insufficient funds"

  @regression
  Scenario: Withdrawal with invalid account_id (missing)
    Given I am authorized as "user1"
    When I POST to "/transact/withdraw" with body:
      | withdrawal_amount | 100       |
    Then the response status should be 400
    And the response body should contain "account_id is required"

  @regression
  Scenario: Withdrawal when unauthorized
    Given I am not authorized
    When I POST to "/transact/withdraw" with body:
      | withdrawal_amount | 100            |
      | account_id        | ACC123456      |
    Then the response status should be 401
    And the response body should contain "Unauthorized"

  @smoke
  Scenario: Successful transfer between accounts
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 2000
    When I POST to "/transact/transfer" with body:
      | source_account_id      | ACC123456         |
      | destination_account_id | ACC654321         |
      | transfer_amount        | 300               |
    Then the response status should be 200
    And the response body should contain:
      | message                | Transfer successful |
      | source_account_id      | ACC123456          |
      | destination_account_id | ACC654321          |
      | transferred_amount     | 300                |

  @regression
  Scenario: Transfer to same account fails
    Given I am authorized as "user1"
    When I POST to "/transact/transfer" with body:
      | source_account_id      | ACC123456         |
      | destination_account_id | ACC123456         |
      | transfer_amount        | 100               |
    Then the response status should be 400
    And the response body should contain "Source and destination accounts must be different"

  @regression
  Scenario: Transfer with insufficient funds
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 50
    When I POST to "/transact/transfer" with body:
      | source_account_id      | ACC123456         |
      | destination_account_id | ACC654321         |
      | transfer_amount        | 100               |
    Then the response status should be 400
    And the response body should contain "Insufficient funds"

  @regression
  Scenario: Transfer with missing fields
    Given I am authorized as "user1"
    When I POST to "/transact/transfer" with body:
      | source_account_id      | ACC123456         |
      | transfer_amount        | 100               |
    Then the response status should be 400
    And the response body should contain "destination_account_id is required"

  @regression
  Scenario: Transfer when unauthorized
    Given I am not authorized
    When I POST to "/transact/transfer" with body:
      | source_account_id      | ACC123456         |
      | destination_account_id | ACC654321         |
      | transfer_amount        | 100               |
    Then the response status should be 401
    And the response body should contain "Unauthorized"

  @smoke
  Scenario: Successful payment from an account
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 1000
    When I POST to "/transact/payment" with body:
      | payer_account_id   | ACC123456         |
      | payee              | VendorXYZ         |
      | amount             | 150               |
      | reference          | INV-9001          |
    Then the response status should be 200
    And the response body should contain:
      | message            | Payment successful |
      | payer_account_id   | ACC123456          |
      | payee              | VendorXYZ          |
      | amount             | 150                |
      | reference          | INV-9001           |

  @regression
  Scenario: Payment with insufficient funds
    Given I am authorized as "user1"
    And account "ACC123456" has a balance of 50
    When I POST to "/transact/payment" with body:
      | payer_account_id   | ACC123456         |
      | payee              | VendorXYZ         |
      | amount             | 200               |
      | reference          | INV-9001          |
    Then the response status should be 400
    And the response body should contain "Insufficient funds"

  @regression
  Scenario: Payment with missing payee
    Given I am authorized as "user1"
    When I POST to "/transact/payment" with body:
      | payer_account_id   | ACC123456         |
      | amount             | 100               |
      | reference          | INV-9001          |
    Then the response status should be 400
    And the response body should contain "payee is required"

  @regression
  Scenario: Payment when unauthorized
    Given I am not authorized
    When I POST to "/transact/payment" with body:
      | payer_account_id   | ACC123456         |
      | payee              | VendorXYZ         |
      | amount             | 150               |
      | reference          | INV-9001          |
    Then the response status should be 401
    And the response body should contain "Unauthorized"
