Feature: JIRA Issue Fetch API Tests
  As a system that fetches JIRA issue details
  I want to verify the fetch functionality under various conditions
  So that I can ensure robust error handling and reliable operation

  # Background: Common valid setup (will be overridden in specific scenarios)
  Background:
    Given the API base URL is set from environment variable "JIRA_BASE_URL"
    And the JIRA user is set from environment variable "JIRA_USER"
    And the JIRA token is set from environment variable "JIRA_TOKEN"
    And the content type is "application/json"
    And the default timeout is 5000 milliseconds

  # Test case: TC-JIRA-001 - Successful fetch of existing issue
  @TC-JIRA-001 @positive
  Scenario: Successful fetch of an existing JIRA issue
    Given a valid JIRA issue ID "ZBIO-7718" exists in the system
    When I send a GET request to "/issue/ZBIO-7718"
    Then the response status should be 200
    And the response body should contain fields: "id", "key", "summary", "status"
    And the log should contain an INFO entry with "JIRA-ID: ZBIO-7718" and "HTTP 200"

  # Test case: TC-JIRA-002 - Non-existent ID returns 404 with exact error message
  # Also covers scenario for any non-existent ID with valid creds
  # Combined with TC-JIRA-019 (forbidden due to permissions)
  @TC-JIRA-002 @TC-JIRA-019 @error-handling
  Scenario Outline: Fetch with non-existent or forbidden issue returns appropriate HTTP error
    Given a valid JIRA issue ID "<issue_id>" <condition> in the system
    And the credentials have <credential_permission>
    When I send a GET request to "/issue/<issue_id>"
    Then the response status should be <status>
    And the error log should contain "Failed to get details for JIRA-ID: <issue_id> with error: AxiosError: Request failed with status code <status>"
    Examples:
      | issue_id    | condition          | credential_permission                     | status |
      | ZBIO-99999  | does not exist     | valid                                       | 404    |
      | SECRET-1    | exists but user has no browse permission | valid but insufficient permissions | 403    |

  # Test case: TC-JIRA-003 - Invalid credentials returns 401/403
  # Combined with TC-JIRA-023 (wrong auth scheme)
  @TC-JIRA-003 @TC-JIRA-023 @negative
  Scenario Outline: Fetch with invalid authentication returns 401
    Given a valid JIRA issue ID "<issue_id>" exists in the system
    And the authentication header is set to "<auth_header>"
    When I send a GET request to "/issue/<issue_id>"
    Then the response status should be 401
    And the error log should contain "Failed to get details for JIRA-ID: <issue_id> with error: AxiosError: Request failed with status code 401"
    Examples:
      | issue_id   | auth_header           |
      | ZBIO-7718  | invalid token         |
      | ZBIO-7718  | Basic base64(user:token) (wrong scheme) |

  # Test case: TC-JIRA-015 - Missing JIRA_TOKEN environment variable
  @TC-JIRA-015 @negative
  Scenario: Fetch with missing JIRA_TOKEN environment variable fails with configuration error
    Given the JIRA_TOKEN environment variable is not set
    And a JIRA issue ID "PROJ-123"
    When I attempt to fetch the issue
    Then no HTTP request should be made
    And the log should contain an ERROR entry with "Missing required environment variable: JIRA_TOKEN"

  # Test case: TC-JIRA-005 - Concurrent fetch race condition
  @TC-JIRA-005 @end-to-end @concurrency
  Scenario: Concurrent fetch of the same existing JIRA ID should not produce false 404s
    Given a valid JIRA issue ID "ZBIO-7718" exists
    When I send 10 simultaneous GET requests to "/issue/ZBIO-7718"
    Then all responses should have status 200
    And no response should have status 404
    And the log should contain INFO entries for each successful request

  # Test case: TC-JIRA-006 - Network timeout and retry
  @TC-JIRA-006 @error-handling
  Scenario: Fetch with network timeout triggers timeout error and retry logic
    Given the API base URL points to a mock server that delays response beyond the configured timeout
    And the timeout is set to 5000 milliseconds
    When I send a GET request to "/issue/ZBIO-7718"
    Then the request should timeout after 5000 milliseconds
    And the log should contain "AxiosError: timeout of 5000ms exceeded"
    And if retry is configured, the log should show retry attempts
    And the test should fail gracefully without crash

  # Test case: TC-JIRA-007 - Malformed base URL (connection error)
  @TC-JIRA-007 @integration
  Scenario: Fetch with malformed JIRA_BASE_URL results in connection error
    Given the API base URL is set to "http://invalid-domain.nonexistent"
    And a valid JIRA issue ID "PROJ-123"
    When I send a GET request to "/issue/PROJ-123"
    Then the request should fail with a network error
    And the log should contain "Failed to get details for JIRA-ID: PROJ-123 with error: AxiosError: request failed" and include "ENOTFOUND" or similar
    And no HTTP status code should be logged

  # Test case: TC-JIRA-008 - Credential expires mid-suite
  @TC-JIRA-008 @state-transition
  Scenario: Credential expiry mid-suite is handled and suite continues
    Given I have a test suite with three sequential fetches
    And the first fetch uses valid token T1
    And the second fetch uses an expired token T2
    And the third fetch uses valid token T1 again
    When the test suite runs
    Then the first fetch should succeed with INFO log
    And the second fetch should fail with 401 and ERROR log
    And the third fetch should succeed with INFO log
    And the suite should not abort and report one failure

  # Test case: TC-JIRA-009 - Audit log for successful fetch (log content)
  @TC-JIRA-009 @positive @audit
  Scenario: Successful fetch log contains required fields for audit trail
    Given a valid JIRA issue ID "ZBIO-7718" exists
    When I send a GET request to "/issue/ZBIO-7718"
    Then the log should contain an INFO entry with the JIRA ID, HTTP 200, timestamp in ISO 8601 format, and optionally a correlation ID

  # Test case: TC-JIRA-010 - Cross-stack environment configuration drift
  @TC-JIRA-010 @integration
  Scenario Outline: Fetches from different stacks use correct JIRA_BASE_URL
    Given the system runs on stack "<stack_name>" with JIRA_BASE_URL "<base_url>"
    And a known existing issue ID "PROJ-123" exists in that JIRA instance
    When I send a GET request to "/issue/PROJ-123"
    Then the actual HTTP request URL should start with "<base_url>"
    Examples:
      | stack_name | base_url                                 |
      | stack1     | https://jira-stack1.atlassian.net        |
      | stack2     | https://jira-stack2.atlassian.net        |

  # Test case: TC-JIRA-011 - Retry on HTTP 500
  @TC-JIRA-011 @error-handling @retry
  Scenario: Fetch with transient HTTP 500 triggers retry and eventual success
    Given the API base URL points to a mock server that returns HTTP 500 for first 2 requests and HTTP 200 for the third
    And the retry policy is configured with 3 retries
    When I send a GET request to "/issue/ZBIO-7718"
    Then the request should succeed after retries
    And the log should contain ERROR entries for the first two attempts with status code 500
    And the log should contain an INFO entry for the third attempt with status 200

  # Test case: TC-JIRA-012 - API version mismatch
  @TC-JIRA-012 @integration
  Scenario: Fetch using incorrect JIRA API version returns appropriate error
    Given the API base URL includes "/rest/api/3" instead of "/rest/api/2"
    And a valid JIRA issue ID "ZBIO-7718" exists
    When I send a GET request to "/rest/api/3/issue/ZBIO-7718"
    Then the response status should be 404 (or 405)
    And the error log should contain the received status code

  # Test case: TC-JIRA-013, TC-JIRA-017, also covers TC-JIRA-004 (boundary for special characters and max length)
  @TC-JIRA-013 @TC-JIRA-017 @TC-JIRA-004 @boundary @negative
  Scenario Outline: Fetch with invalid JIRA ID formats fails gracefully
    Given the system has valid credentials
    And the JIRA ID is set to "<jira_id>"
    When I send a GET request to "/issue/<jira_id>"
    Then the request should either be rejected before HTTP call with a validation error
    Or if sent, the log should contain an error with the exact ID format
    And the test suite should not crash
    Examples:
      | jira_id        | expected_behavior |
      | (empty string) | validation error: "Invalid JIRA ID: empty" or similar; no HTTP request |
      | null           | validation error or Axios error with malformed URL |
      | " ZBIO-7718 "  | either trimmed and successful fetch, or validation error about whitespace |
      | "PROJ_123"     | if JIRA does not accept underscore, error logged with full ID; if exists, success |
      | "PROJ-123456789012345" (30 chars) | if non-existent, error log contains full ID without truncation; if exists, success |

  # Test case: TC-JIRA-014 - HTTP 429 rate limiting
  @TC-JIRA-014 @error-handling @rate-limit
  Scenario: Fetch with HTTP 429 rate limiting response is handled
    Given the API base URL points to a mock server that returns HTTP 429 with Retry-After: 5
    When I send a GET request to "/issue/ZBIO-7718"
    Then the system should either wait 5 seconds and retry, or fail immediately
    And if retry occurs, log should show "Retrying after 5000ms due to 429"
    If no retry, log should contain "Request failed with status code 429"
    And the test should not crash

  # Test case: TC-JIRA-016 - Decision table for combinations of credential validity and ID existence
  @TC-JIRA-016 @decision-table
  Scenario Outline: Systematic test of credential validity vs JIRA ID existence
    Given the credentials are "<credential_type>"
    And the JIRA ID "<jira_id>" <existence>
    When I send a GET request to "/issue/<jira_id>"
    Then the response status should be <expected_status>
    And the log should contain <log_type> entry with appropriate message
    Examples:
      | credential_type | jira_id     | existence        | expected_status | log_type |
      | valid           | ZBIO-7718   | exists           | 200             | INFO     |
      | valid           | ZBIO-99999  | does not exist   | 404             | ERROR    |
      | invalid/expired | ZBIO-7718   | exists           | 401/403         | ERROR    |
      | invalid/expired | ZBIO-99999  | does not exist   | 401/403         | ERROR    |

  # Test case: TC-JIRA-018 - Log format consistency across error types
  @TC-JIRA-018 @regression @log-format
  Scenario Outline: Error log format consistency for different error types
    Given the API base URL points to a mock server that returns <http_status> for a valid issue ID "ZBIO-7718"
    When I send a GET request to "/issue/ZBIO-7718"
    Then the error log should exactly match "Failed to get details for JIRA-ID: ZBIO-7718 with error: AxiosError: Request failed with status code <http_status>"
    Examples:
      | http_status |
      | 401         |
      | 403         |
      | 404         |
      | 500         |

  # Test case: TC-JIRA-020 - Credential rotation mid-suite
  @TC-JIRA-020 @state-transition
  Scenario: Sequential fetches with credential rotation between requests
    Given a test suite that performs two fetches consecutively
    And the first fetch uses valid token T1
    And between fetches, the token is changed to another valid token T2
    When the first fetch is for issue "ZBIO-7718" and the second fetch is for the same issue
    Then both fetches should succeed with HTTP 200
    And the logs should reflect that each request used the correct token (if discernible)

  # Test case: TC-JIRA-021 - Redirect handling
  @TC-JIRA-021 @integration
  Scenario: HTTP redirect from JIRA API is followed correctly
    Given the API base URL points to a mock server that returns HTTP 301 with Location: <real_endpoint>
    And the real JIRA server is accessible
    When I send a GET request to "/issue/ZBIO-7718"
    Then the system should follow the redirect and eventually receive HTTP 200
    And the log should contain an INFO entry with final HTTP 200

  # Test case: TC-JIRA-022 - HTTP 200 with error body
  @TC-JIRA-022 @error-handling
  Scenario: HTTP 200 with error body in response is treated as failure
    Given the API base URL points to a mock server that returns HTTP 200 with body containing error messages (e.g., {"errorMessages":["Issue does not exist"]})
    When I send a GET request to "/issue/ZBIO-99999"
    Then the fetch should be considered a failure
    And the log should contain an ERROR entry with "Invalid response: issue not found" or similar
    And no INFO success log should be present

  # Test case: TC-JIRA-024 - Eventual consistency (newly created issue)
  @TC-JIRA-024 @end-to-end @eventual-consistency
  Scenario: Fetch a newly created JIRA issue immediately to test eventual consistency
    Given I create a new JIRA issue via API with project "ZBIO" and summary "Test eventual consistency"
    And I immediately issue a GET request for the new issue ID
    Then the first request may return HTTP 404 or 200
    When I retry after 2 seconds
    Then the second request should return HTTP 200 (if issue propagated)
    And error logs should not cause crash
    And the newly created issue should be deleted after test

  # Test case: TC-JIRA-025 - Error log audit trail verification
  @TC-JIRA-025 @audit
  Scenario: Error log contains mandatory audit fields
    Given a non-existent JIRA issue ID "ZBIO-99999"
    When I send a GET request to "/issue/ZBIO-99999"
    Then the error log should contain: timestamp in ISO 8601, JIRA ID "ZBIO-99999", HTTP status 404, and optionally a correlation ID

  # Test case: TC-JIRA-026 - HTTP 204 No Content
  @TC-JIRA-026 @error-handling
  Scenario: Fetch receives HTTP 204 No Content and logs error
    Given the API base URL points to a mock server that returns HTTP 204 for issue "ZBIO-7718"
    When I send a GET request to "/issue/ZBIO-7718"
    Then the fetch should fail
    And the log should contain an ERROR entry with "Empty response with status 204" or "Unexpected HTTP status: 204"
    And the system should not crash

  # Test case: TC-JIRA-027 - HTTP 200 with missing required fields
  @TC-JIRA-027 @error-handling
  Scenario: HTTP 200 response missing mandatory fields is treated as failure
    Given the API base URL points to a mock server that returns HTTP 200 with JSON body missing "id" field for issue "ZBIO-7718"
    When I send a GET request to "/issue/ZBIO-7718"
    Then the fetch should fail
    And the log should contain an ERROR entry with "Response missing required field: id"
    And no success log

  # Test case: TC-JIRA-028 - SSL certificate error
  @TC-JIRA-028 @error-handling @ssl
  Scenario: SSL certificate validation failure logs connection error
    Given the API base URL points to a server with a self-signed certificate (SSL reject enabled)
    When I send a GET request to "/issue/ZBIO-7718"
    Then the request should fail with an SSL error
    And the log should contain "Failed to get details for JIRA-ID: ZBIO-7718 with error: AxiosError: self signed certificate" (or similar)

  # Test case: TC-JIRA-029 - Sequential fetches of multiple IDs
  @TC-JIRA-029 @functional @independence
  Scenario: Sequential fetches of different JIRA IDs are independent
    Given I have three JIRA IDs: existing "ZBIO-7718", existing "PROJ-123", non-existing "ZBIO-99999"
    When I fetch each ID sequentially
    Then the first fetch returns 200 with INFO log for "ZBIO-7718"
    And the second fetch returns 200 with INFO log for "PROJ-123"
    And the third fetch returns 404 with ERROR log for "ZBIO-99999"
    And each log entry contains the correct JIRA ID

  # Test case: TC-JIRA-030 - Extremely short timeout
  @TC-JIRA-030 @error-handling @timeout
  Scenario: Extremely short timeout (1ms) causes immediate timeout error
    Given the timeout is set to 1 millisecond
    And a valid JIRA issue ID "ZBIO-7718"
    When I send a GET request to "/issue/ZBIO-7718"
    Then the request should timeout immediately
    And the log should contain "AxiosError: timeout of 1ms exceeded"
    And the test should not hang
