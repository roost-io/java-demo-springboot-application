Feature: JIRA API and UI Interaction Testing on Roost.ai Platform

  # API Test Scenarios
  @api
  Scenario Outline: Fetch JIRA Details with Valid Credentials
    Given the API base URL is "https://roost.ai/api"
    And valid JIRA credentials are configured
    When I trigger the test suite to fetch JIRA details
    Then the response status should be 200
    And the response should contain "JIRA details"

  @api
  Scenario Outline: Handle 404 Error on JIRA API Request
    Given the API base URL is "https://roost.ai/api"
    And valid JIRA credentials are configured
    When I trigger the test suite with a non-existent JIRA ID
    Then the response status should be 404
    And the system displays a clear error message indicating a 404 error

  @api
  Scenario Outline: Data Validation for JIRA Credentials
    Given the API base URL is "https://roost.ai/api"
    When I input JIRA credentials and trigger the test suite
    Then the system validates the credentials
    And proceeds only if they are correct

  @api
  Scenario Outline: Boundary Value Analysis for API Request Parameters
    Given the API base URL is "https://roost.ai/api"
    And I configure API request parameters with boundary values
    When I trigger the test suite
    Then the system handles boundary values correctly without errors

  @api
  Scenario Outline: Error Classification for HTTP Errors
    Given the API base URL is "https://roost.ai/api"
    And error simulation capabilities are available
    When I simulate different HTTP errors and trigger the test suite
    Then the system correctly classifies and handles each HTTP error

  @api
  Scenario Outline: Data Integrity Check for JIRA Response Handling
    Given the API base URL is "https://roost.ai/api"
    And valid JIRA credentials are configured
    When I trigger the test suite to fetch JIRA details
    Then data integrity is maintained in JIRA responses

  @api
  Scenario Outline: Error Logging for Failed JIRA API Requests
    Given the API base URL is "https://roost.ai/api"
    And logging is enabled
    When I trigger a test suite with a failing JIRA API request
    Then errors are logged with sufficient detail to diagnose the issue

  @api
  Scenario Outline: Retry Mechanism for JIRA API Requests
    Given the API base URL is "https://roost.ai/api"
    And a retry mechanism is configured
    When I trigger a test suite with a JIRA API request expected to fail initially
    Then the system retries the JIRA API request and succeeds after initial failure

  @api
  Scenario Outline: Security Check for JIRA API Credentials
    Given the API base URL is "https://roost.ai/api"
    When I input JIRA credentials and trigger the test suite
    Then JIRA credentials are securely handled and stored, preventing unauthorized access

  @api
  Scenario Outline: Performance Testing for JIRA API Integration
    Given the API base URL is "https://roost.ai/api"
    And performance monitoring tools are available
    When I trigger multiple test suites with JIRA API requests
    Then the system maintains acceptable performance levels during JIRA API integration

  # UI Test Scenarios
  @ui
  Scenario Outline: UI Interaction for Triggering Test Suites
    Given I am on the Roost.ai platform
    When I select a test suite to trigger
    And I execute the test suite
    Then I should see the results displayed on the UI

  @ui
  Scenario Outline: UI Feedback for Error Handling
    Given I am on the Roost.ai platform
    When I trigger a test suite known to produce errors
    Then the UI provides clear and actionable feedback for errors

  @ui
  Scenario Outline: Workflow State Transitions for Test Execution
    Given I am on the Roost.ai platform
    When I trigger the test suite
    Then the workflow transitions through all expected states
    And results are accurately retrieved

  @ui
  Scenario Outline: User Notification for JIRA API Failures
    Given I am on the Roost.ai platform
    When I trigger a test suite with a failing JIRA API request
    Then users receive clear and timely notifications of JIRA API request failures

  @ui
  Scenario Outline: State Transition Testing for Workflow Stages
    Given I am on the Roost.ai platform
    When I trigger the test suite
    Then the workflow transitions through all defined stages correctly
