@api/v1
Feature: Delete machine component
  Background:
    Given the following "accounts" exist:
      | Name    | Slug  |
      | Test 1  | test1 |
      | Test 2  | test2 |
    And I send and accept JSON

  Scenario: Endpoint should be inaccessible when account is disabled
    Given the account "test1" is canceled
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "component"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "403"

  Scenario: Admin deletes one of their components
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$2"
    Then the response status should be "204"
    And the response should contain a valid signature header for "test1"
    And the current account should have 2 "components"
    And sidekiq should have 2 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Developer deletes one of their components
    Given the current account is "test1"
    And the current account has 1 "developer"
    And I am a developer of account "test1"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$2"
    Then the response status should be "204"
    And the current account should have 2 "components"

  Scenario: Sales deletes one of their components
    Given the current account is "test1"
    And the current account has 1 "sales-agent"
    And I am a sales agent of account "test1"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$2"
    Then the response status should be "204"
    And the current account should have 2 "components"

  Scenario: Support deletes one of their components
    Given the current account is "test1"
    And the current account has 1 "support-agent"
    And I am a support agent of account "test1"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$2"
    Then the response status should be "403"
    And the current account should have 3 "components"

  Scenario: Read-only deletes one of their components
    Given the current account is "test1"
    And the current account has 1 "read-only"
    And I am a read only of account "test1"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$2"
    Then the response status should be "403"
    And the current account should have 3 "components"

  @ee
  Scenario: Environment deletes one of their components
    Given the current account is "test1"
    And the current account has 2 isolated "webhook-endpoints"
    And the current account has 1 isolated "environment"
    And the current account has 1 isolated "component"
    And I am an environment of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0?environment=isolated"
    Then the response status should be "204"
    And sidekiq should have 2 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Product deletes one of their components
    Given the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 1 "product"
    And the current account has 1 "policy" for the last "product"
    And the current account has 1 "license" for the last "policy"
    And the current account has 1 "machine" for the last "license"
    And the current account has 1 "component" for the last "machine"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "204"
    And sidekiq should have 2 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Product deletes a component for a different product
    Given the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 2 "products"
    And the current account has 1 "policy" for the second "product"
    And the current account has 1 "license" for the last "policy"
    And the current account has 1 "machine" for the last "license"
    And the current account has 1 "component" for the last "machine"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "404"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User attempts to delete a component that belongs to another user
    Given the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 3 "components"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$1"
    Then the response status should be "404"
    And the response body should be an array of 1 error
    And the current account should have 3 "components"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User deletes a component for their unprotected license (license owner)
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "protected": false }
      """
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "policy"
    And the first "license" has the following attributes:
      """
      { "userId": "$users[1]" }
      """
    And the current account has 1 "machine" for the last "license"
    And the current account has 1 "component" for the last "machine"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "204"
    And the current account should have 0 "components"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: User deletes a component for their unprotected license (license user, as owner)
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "protected": false }
      """
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "policy"
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And the current account has 1 "machine" for the last "license" and the last "user" as "owner"
    And the current account has 1 "component" for the last "machine"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "204"
    And the current account should have 0 "components"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: User deletes a component for their unprotected license (license user, no owner)
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "protected": false }
      """
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "policy"
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And the current account has 1 "machine" for the last "license"
    And the current account has 1 "component" for the last "machine"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "403"
    And the current account should have 1 "component"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User deletes a component for their protected license
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "protected": true }
      """
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "policy"
    And the first "license" has the following attributes:
      """
      { "userId": "$users[1]" }
      """
    And the current account has 1 "machine" for the last "license"
    And the current account has 1 "component" for the last "machine"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "403"
    And the current account should have 1 "component"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: License deletes a component for one of their machines
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "license"
    And the current account has 3 "machines" for the last "license"
    And the current account has 2 "components" for the last "machine"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "204"
    And the current account should have 1 "component"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: License deletes a component for a different license
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "license"
    And the current account has 1 "component"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$0"
    Then the response status should be "404"
    And the current account should have 1 "component"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Anonymous user attempts to delete a component for their account
    Given the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 3 "components"
    When I send a DELETE request to "/accounts/test1/components/$1"
    Then the response status should be "401"
    And the response body should be an array of 1 error
    And the current account should have 3 "components"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to delete a component for another account
    Given I am an admin of account "test2"
    But the current account is "test1"
    And the current account has 2 "webhook-endpoints"
    And the current account has 3 "components"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/components/$1"
    Then the response status should be "401"
    And the response body should be an array of 1 error
    And the current account should have 3 "components"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job
