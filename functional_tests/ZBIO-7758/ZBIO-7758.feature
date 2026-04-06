Feature: JIRA Integration Testing

  # API Test Scenarios
  @api
  Scenario Outline: Handle API Response Codes
    Given the API base URL is '/api/jira/details'
    And the authorization token is set
    When I send a GET request to fetch JIRA details
    Then the response status should be <status>
    And the response should contain <expected_message>

    Examples:
      | status | expected_message                                      |
      | 200    | "JIRA details fetched successfully"                   |
      | 404    | "AxiosError: Request failed with status code 404"     |
      | 500    | "Internal server error"                               |

  @api
  Scenario Outline: Validate JIRA Credentials Before API Call
    Given the API base URL is '/api/jira/validate'
    When I send a POST request with credentials <username> and <password>
    Then the response status should be <status>
    And the response should contain <expected_message>

    Examples:
      | username | password | status | expected_message                  |
      | valid    | valid    | 200    | "Credentials validated"           |
      | invalid  | valid    | 401    | "Invalid credentials"             |
      | valid    | invalid  | 401    | "Invalid credentials"             |

  @api
  Scenario Outline: Simulate Network Failure
    Given the API base URL is '/api/jira/details'
    And the authorization token is set
    When I simulate a network failure during the GET request
    Then the system should log the network error
    And the response should contain "Network error occurred"

    Examples:
      | network_status |
      | "disconnected" |

  @api
  Scenario Outline: Simulate API Timeout
    Given the API base URL is '/api/jira/details'
    And the authorization token is set
    When I simulate a timeout during the GET request
    Then the system should log the timeout error
    And the response should contain "Request timed out"

    Examples:
      | timeout_duration |
      | "30 seconds"     |

  @api
  Scenario Outline: Simulate API Rate Limiting
    Given the API base URL is '/api/jira/details'
    And the authorization token is set
    When I trigger multiple API requests rapidly
    Then the system should log the rate limit error
    And the response should contain "Rate limit exceeded"

    Examples:
      | request_count |
      | 100           |

  # UI Test Scenarios
  @ui
  Scenario Outline: UI Interaction for Triggering Test Suites
    Given I am on the 'Test Suite' page
    When I enter <credentials> in the login form
    And I click the 'Trigger Test Suite' button
    Then I should see <expected_result>

    Examples:
      | credentials | expected_result                  |
      | valid       | "Test suite initiated"           |
      | invalid     | "Invalid credentials"            |

  @ui
  Scenario Outline: UI Validation for Error Messages
    Given I am on the 'Test Suite' page
    When I trigger a test suite with <api_error>
    Then I should see an error message <ui_error_message>

    Examples:
      | api_error | ui_error_message                      |
      | 404       | "JIRA details not found"              |
      | 500       | "Internal server error occurred"      |

  @ui
  Scenario Outline: User Feedback for Invalid JIRA ID
    Given I am on the 'Test Suite' page
    When I enter a non-existent JIRA ID <jira_id>
    And I click the 'Fetch Details' button
    Then I should see a message <feedback_message>

    Examples:
      | jira_id | feedback_message                  |
      | 12345   | "JIRA ID not found"               |
      | 67890   | "JIRA ID not found"               |

  @ui
  Scenario Outline: Authorization Check for Accessing JIRA Details
    Given I am logged in as a user with <access_level>
    When I attempt to access JIRA details
    Then I should see <access_message>

    Examples:
      | access_level | access_message                   |
      | unauthorized | "Access denied"                  |
      | authorized   | "Access granted"                 |
