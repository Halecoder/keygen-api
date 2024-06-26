@api/v1
Feature: License users relationship
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
    And the current account has 1 "license"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "403"

  # Retrieval
  Scenario: Admin retrieves the users for a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "user" as "owner"
    And the current account has 4 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 5 "users"

  Scenario: Admin retrieves the users for a license by key
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "license"
    And the first "license" has the following attributes:
      """
      { "key": "example-license-key" }
      """
    And the current account has 5 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/example-license-key/users"
    Then the response status should be "200"
    And the response body should be an array with 5 "users"

  Scenario: Admin attempts to retrieve the users for a license of another account
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "401"

  @ee
  Scenario: Environment retrieves the users for an isolated license
    Given the current account is "test1"
    And the current account has 1 isolated "environment"
    And the current account has 1 isolated "license"
    And the current account has 3 isolated "license-users" for each "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "isolated" }
      """
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 3 "users"

  Scenario: Product retrieves the users for a license
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policies" for existing "products"
    And the current account has 1 "license" for existing "policies"
    And the current account has 3 "license-users" for existing "licenses"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 3 "users"

  Scenario: Product retrieves the users for a license of another product
    Given the current account is "test1"
    And the current account has 2 "products"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "productId": "$products[1]" }
      """
    And the current account has 1 "license"
    And the first "license" has the following attributes:
      """
      { "policyId": "$policies[0]" }
      """
    And the current account has 3 "license-users" for existing "licenses"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "404"

  Scenario: License retrieves their users (without permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for the last "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "403"

  Scenario: License retrieves their users (with permission)
    Given the current account is "test1"
    And the current account has 2 "users"
    And the current account has 1 "license" for the first "user" as "owner"
    And the last "license" has the following permissions:
      """
      ["user.read"]
      """
    And the current account has 3 "license-users" for the last "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 4 "users"

  Scenario: Owner attempts to retrieve the users for their license
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 3 "licenses" for the last "user" as "owner"
    And the current account has 2 "license-users" for the first "license"
    And the current account has 4 "license-users" for the second "license"
    And the current account has 6 "license-users" for the third "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 3 "users"

  Scenario: User attempts to retrieve the users for their license
    Given the current account is "test1"
    And the current account has 1 "licenses"
    And the current account has 2 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "200"
    And the response body should be an array with 2 "users"

  Scenario: User attempts to retrieve the users for another license
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users"
    Then the response status should be "404"

  Scenario: Admin retrieves a user for a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for the last "license"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$1"
    Then the response status should be "200"
    And the response body should be a "user"

  Scenario: Admin retrieves a user by email
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for the last "license"
    And the last "user" has the following attributes:
      """
      { "email": "test@keygen.example" }
      """
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/test@keygen.example"
    Then the response status should be "200"
    And the response body should be a "user"

  Scenario: Product retrieves a user for a license
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policies" for existing "products"
    And the current account has 1 "license" for existing "policies"
    And the current account has 3 "license-users" for existing "licenses"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$1"
    Then the response status should be "200"
    And the response body should be a "user"

  Scenario: Owner attempts to retrieve a user for their license
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "user" as "owner"
    And the current account has 5 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$1"
    Then the response status should be "200"
    And the response body should be an "user"

  Scenario: User attempts to retrieve themself for their license
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 5 "license-users" for existing "licenses"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$1"
    Then the response status should be "200"
    And the response body should be an "user"

  Scenario: User attempts to retrieve another user for their license
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 5 "license-users" for existing "licenses"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$2"
    Then the response status should be "200"
    And the response body should be an "user"

  Scenario: User attempts to retrieve users for a license they don't own
    Given the current account is "test1"
    And the current account has 2 "users"
    And the current account has 1 "license"
    And the first "license" has the following attributes:
      """
      { "userId": "$users[2]" }
      """
    And the current account has 3 "license-users" for existing "licenses"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$1"
    Then the response status should be "404"

  Scenario: License attempts to retrieve their user (without permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 5 "license-users" for existing "licenses"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$2"
    Then the response status should be "403"

  Scenario: License attempts to retrieve their user (with permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the last "license" has the following permissions:
      """
      ["user.read"]
      """
    And the current account has 5 "license-users" for existing "licenses"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a GET request to "/accounts/test1/licenses/$0/users/$2"
    Then the response status should be "200"
    And the response body should be an "user"

  # Attachment
  Scenario: Admin attaches users to a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "users"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response body should be an array with 1 "license-user" with the following relationships:
      """
      {
        "user": {
          "links": { "related": "/v1/accounts/$account/users/$users[1]" },
          "data": { "type": "users", "id": "$users[1]" }
        }
      }
      """
    And the response body should be an array with 1 "license-user" with the following relationships:
      """
      {
        "user": {
          "links": { "related": "/v1/accounts/$account/users/$users[2]" },
          "data": { "type": "users", "id": "$users[2]" }
        }
      }
      """
    And the response body should be an array with 1 "license-user" with the following relationships:
      """
      {
        "user": {
          "links": { "related": "/v1/accounts/$account/users/$users[3]" },
          "data": { "type": "users", "id": "$users[3]" }
        }
      }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALWAYS_ALLOW_OVERAGE, within limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALWAYS_ALLOW_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 1 "license-user" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALWAYS_ALLOW_OVERAGE, exceeds limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALWAYS_ALLOW_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_1_25X_OVERAGE, within limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_1_25X_OVERAGE",
        "maxUsers": 4
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 2 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_1_25X_OVERAGE, exceeds limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_1_25X_OVERAGE",
        "maxUsers": 4
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "user count has exceeded maximum allowed for license (4)",
        "code": "USER_LIMIT_EXCEEDED",
        "source": {
          "pointer": "/data/relationships/users"
        }
      }
      """
    And the response should contain a valid signature header for "test1"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_1_5X_OVERAGE, within limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_1_5X_OVERAGE",
        "maxUsers": 4
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 3 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 2 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_1_5X_OVERAGE, exceeds limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_1_5X_OVERAGE",
        "maxUsers": 4
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 3 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "user count has exceeded maximum allowed for license (4)",
        "code": "USER_LIMIT_EXCEEDED",
        "source": {
          "pointer": "/data/relationships/users"
        }
      }
      """
    And the response should contain a valid signature header for "test1"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_2X_OVERAGE, within limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_2X_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 4 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (ALLOW_2X_OVERAGE, exceeds limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "ALLOW_2X_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 6 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" },
          { "type": "user", "id": "$users[4]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "user count has exceeded maximum allowed for license (5)",
        "code": "USER_LIMIT_EXCEEDED",
        "source": {
          "pointer": "/data/relationships/users"
        }
      }
      """
    And the response should contain a valid signature header for "test1"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (NO_OVERAGE, within limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "NO_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 1 "license-user" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches users to a license with a max users limit (NO_OVERAGE, exceeds limit)
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 5 "users"
    And the current account has 1 "policy" with the following:
      """
      {
        "overageStrategy": "NO_OVERAGE",
        "maxUsers": 5
      }
      """
    And the current account has 1 "license" for the last "policy" and the last "user" as "owner"
    And the current account has 1 "license-user" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" },
          { "type": "user", "id": "$users[4]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "user count has exceeded maximum allowed for license (5)",
        "code": "USER_LIMIT_EXCEEDED",
        "source": {
          "pointer": "/data/relationships/users"
        }
      }
      """
    And the response should contain a valid signature header for "test1"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Admin attaches shared users to a global license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 shared "users"
    And the current account has 1 global "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "You do not have permission to complete the request (a record's environment is not compatible with the current environment)"
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Admin attaches shared users to a shared license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 2 shared "users"
    And the current account has 1 global "users"
    And the current account has 1 shared "license"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response should contain a valid signature header for "test1"
    And the response should contain the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Admin attaches mixed users to a shared license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 isolated "user"
    And the current account has 1 shared "user"
    And the current account has 1 global "user"
    And the current account has 1 shared "license"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "You do not have permission to complete the request (a record's environment is not compatible with the current environment)"
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin bulk attaches 100 users to a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 100 "users"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" },
          { "type": "user", "id": "$users[4]" },
          { "type": "user", "id": "$users[5]" },
          { "type": "user", "id": "$users[6]" },
          { "type": "user", "id": "$users[7]" },
          { "type": "user", "id": "$users[8]" },
          { "type": "user", "id": "$users[9]" },
          { "type": "user", "id": "$users[10]" },
          { "type": "user", "id": "$users[11]" },
          { "type": "user", "id": "$users[12]" },
          { "type": "user", "id": "$users[13]" },
          { "type": "user", "id": "$users[14]" },
          { "type": "user", "id": "$users[15]" },
          { "type": "user", "id": "$users[16]" },
          { "type": "user", "id": "$users[17]" },
          { "type": "user", "id": "$users[18]" },
          { "type": "user", "id": "$users[19]" },
          { "type": "user", "id": "$users[20]" },
          { "type": "user", "id": "$users[21]" },
          { "type": "user", "id": "$users[22]" },
          { "type": "user", "id": "$users[23]" },
          { "type": "user", "id": "$users[24]" },
          { "type": "user", "id": "$users[25]" },
          { "type": "user", "id": "$users[26]" },
          { "type": "user", "id": "$users[27]" },
          { "type": "user", "id": "$users[28]" },
          { "type": "user", "id": "$users[29]" },
          { "type": "user", "id": "$users[30]" },
          { "type": "user", "id": "$users[31]" },
          { "type": "user", "id": "$users[32]" },
          { "type": "user", "id": "$users[33]" },
          { "type": "user", "id": "$users[34]" },
          { "type": "user", "id": "$users[35]" },
          { "type": "user", "id": "$users[36]" },
          { "type": "user", "id": "$users[37]" },
          { "type": "user", "id": "$users[38]" },
          { "type": "user", "id": "$users[39]" },
          { "type": "user", "id": "$users[40]" },
          { "type": "user", "id": "$users[41]" },
          { "type": "user", "id": "$users[42]" },
          { "type": "user", "id": "$users[43]" },
          { "type": "user", "id": "$users[44]" },
          { "type": "user", "id": "$users[45]" },
          { "type": "user", "id": "$users[46]" },
          { "type": "user", "id": "$users[47]" },
          { "type": "user", "id": "$users[48]" },
          { "type": "user", "id": "$users[49]" },
          { "type": "user", "id": "$users[50]" },
          { "type": "user", "id": "$users[51]" },
          { "type": "user", "id": "$users[52]" },
          { "type": "user", "id": "$users[53]" },
          { "type": "user", "id": "$users[54]" },
          { "type": "user", "id": "$users[55]" },
          { "type": "user", "id": "$users[56]" },
          { "type": "user", "id": "$users[57]" },
          { "type": "user", "id": "$users[58]" },
          { "type": "user", "id": "$users[59]" },
          { "type": "user", "id": "$users[60]" },
          { "type": "user", "id": "$users[61]" },
          { "type": "user", "id": "$users[62]" },
          { "type": "user", "id": "$users[63]" },
          { "type": "user", "id": "$users[64]" },
          { "type": "user", "id": "$users[65]" },
          { "type": "user", "id": "$users[66]" },
          { "type": "user", "id": "$users[67]" },
          { "type": "user", "id": "$users[68]" },
          { "type": "user", "id": "$users[69]" },
          { "type": "user", "id": "$users[70]" },
          { "type": "user", "id": "$users[71]" },
          { "type": "user", "id": "$users[72]" },
          { "type": "user", "id": "$users[73]" },
          { "type": "user", "id": "$users[74]" },
          { "type": "user", "id": "$users[75]" },
          { "type": "user", "id": "$users[76]" },
          { "type": "user", "id": "$users[77]" },
          { "type": "user", "id": "$users[78]" },
          { "type": "user", "id": "$users[79]" },
          { "type": "user", "id": "$users[80]" },
          { "type": "user", "id": "$users[81]" },
          { "type": "user", "id": "$users[82]" },
          { "type": "user", "id": "$users[83]" },
          { "type": "user", "id": "$users[84]" },
          { "type": "user", "id": "$users[85]" },
          { "type": "user", "id": "$users[86]" },
          { "type": "user", "id": "$users[87]" },
          { "type": "user", "id": "$users[88]" },
          { "type": "user", "id": "$users[89]" },
          { "type": "user", "id": "$users[90]" },
          { "type": "user", "id": "$users[91]" },
          { "type": "user", "id": "$users[92]" },
          { "type": "user", "id": "$users[93]" },
          { "type": "user", "id": "$users[94]" },
          { "type": "user", "id": "$users[95]" },
          { "type": "user", "id": "$users[96]" },
          { "type": "user", "id": "$users[97]" },
          { "type": "user", "id": "$users[98]" },
          { "type": "user", "id": "$users[99]" },
          { "type": "user", "id": "$users[100]" }
        ]
      }
      """
    Then the response status should be "200"
    And the current account should have 100 "license-users"
    And the current account should have 100 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin bulk attaches 101 users to a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 101 "users"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" },
          { "type": "user", "id": "$users[4]" },
          { "type": "user", "id": "$users[5]" },
          { "type": "user", "id": "$users[6]" },
          { "type": "user", "id": "$users[7]" },
          { "type": "user", "id": "$users[8]" },
          { "type": "user", "id": "$users[9]" },
          { "type": "user", "id": "$users[10]" },
          { "type": "user", "id": "$users[11]" },
          { "type": "user", "id": "$users[12]" },
          { "type": "user", "id": "$users[13]" },
          { "type": "user", "id": "$users[14]" },
          { "type": "user", "id": "$users[15]" },
          { "type": "user", "id": "$users[16]" },
          { "type": "user", "id": "$users[17]" },
          { "type": "user", "id": "$users[18]" },
          { "type": "user", "id": "$users[19]" },
          { "type": "user", "id": "$users[20]" },
          { "type": "user", "id": "$users[21]" },
          { "type": "user", "id": "$users[22]" },
          { "type": "user", "id": "$users[23]" },
          { "type": "user", "id": "$users[24]" },
          { "type": "user", "id": "$users[25]" },
          { "type": "user", "id": "$users[26]" },
          { "type": "user", "id": "$users[27]" },
          { "type": "user", "id": "$users[28]" },
          { "type": "user", "id": "$users[29]" },
          { "type": "user", "id": "$users[30]" },
          { "type": "user", "id": "$users[31]" },
          { "type": "user", "id": "$users[32]" },
          { "type": "user", "id": "$users[33]" },
          { "type": "user", "id": "$users[34]" },
          { "type": "user", "id": "$users[35]" },
          { "type": "user", "id": "$users[36]" },
          { "type": "user", "id": "$users[37]" },
          { "type": "user", "id": "$users[38]" },
          { "type": "user", "id": "$users[39]" },
          { "type": "user", "id": "$users[40]" },
          { "type": "user", "id": "$users[41]" },
          { "type": "user", "id": "$users[42]" },
          { "type": "user", "id": "$users[43]" },
          { "type": "user", "id": "$users[44]" },
          { "type": "user", "id": "$users[45]" },
          { "type": "user", "id": "$users[46]" },
          { "type": "user", "id": "$users[47]" },
          { "type": "user", "id": "$users[48]" },
          { "type": "user", "id": "$users[49]" },
          { "type": "user", "id": "$users[50]" },
          { "type": "user", "id": "$users[51]" },
          { "type": "user", "id": "$users[52]" },
          { "type": "user", "id": "$users[53]" },
          { "type": "user", "id": "$users[54]" },
          { "type": "user", "id": "$users[55]" },
          { "type": "user", "id": "$users[56]" },
          { "type": "user", "id": "$users[57]" },
          { "type": "user", "id": "$users[58]" },
          { "type": "user", "id": "$users[59]" },
          { "type": "user", "id": "$users[60]" },
          { "type": "user", "id": "$users[61]" },
          { "type": "user", "id": "$users[62]" },
          { "type": "user", "id": "$users[63]" },
          { "type": "user", "id": "$users[64]" },
          { "type": "user", "id": "$users[65]" },
          { "type": "user", "id": "$users[66]" },
          { "type": "user", "id": "$users[67]" },
          { "type": "user", "id": "$users[68]" },
          { "type": "user", "id": "$users[69]" },
          { "type": "user", "id": "$users[70]" },
          { "type": "user", "id": "$users[71]" },
          { "type": "user", "id": "$users[72]" },
          { "type": "user", "id": "$users[73]" },
          { "type": "user", "id": "$users[74]" },
          { "type": "user", "id": "$users[75]" },
          { "type": "user", "id": "$users[76]" },
          { "type": "user", "id": "$users[77]" },
          { "type": "user", "id": "$users[78]" },
          { "type": "user", "id": "$users[79]" },
          { "type": "user", "id": "$users[80]" },
          { "type": "user", "id": "$users[81]" },
          { "type": "user", "id": "$users[82]" },
          { "type": "user", "id": "$users[83]" },
          { "type": "user", "id": "$users[84]" },
          { "type": "user", "id": "$users[85]" },
          { "type": "user", "id": "$users[86]" },
          { "type": "user", "id": "$users[87]" },
          { "type": "user", "id": "$users[88]" },
          { "type": "user", "id": "$users[89]" },
          { "type": "user", "id": "$users[90]" },
          { "type": "user", "id": "$users[91]" },
          { "type": "user", "id": "$users[92]" },
          { "type": "user", "id": "$users[93]" },
          { "type": "user", "id": "$users[94]" },
          { "type": "user", "id": "$users[95]" },
          { "type": "user", "id": "$users[96]" },
          { "type": "user", "id": "$users[97]" },
          { "type": "user", "id": "$users[98]" },
          { "type": "user", "id": "$users[99]" },
          { "type": "user", "id": "$users[100]" },
          { "type": "user", "id": "$users[101]" }
        ]
      }
      """
    Then the response status should be "400"
    And the first error should have the following properties:
      """
      {
        "title": "Bad request",
        "detail": "length must be between 1 and 100 (inclusive)",
        "source": {
          "pointer": "/data"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches empty users to a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      { "data": [] }
      """
    Then the response status should be "400"
    And the first error should have the following properties:
      """
      {
        "title": "Bad request",
        "detail": "length must be between 1 and 100 (inclusive)",
        "source": {
          "pointer": "/data"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches a user to a license that already exists as an owner
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "user" as "owner"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "already exists (user is attached through owner)",
        "code": "USER_CONFLICT",
        "source": {
          "pointer": "/data/relationships/user"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attaches a user to a license that already exists as a user
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "license"
    And the current account has 1 "license-user" for existing "licenses"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "already exists",
        "code": "USER_TAKEN",
        "source": {
          "pointer": "/data/relationships/user"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to attach users to a license with an invalid user ID
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 3 "users"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "d22692b1-0b4b-4cb7-9e3e-449e0fdf9cd8" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "must exist",
        "code": "USER_NOT_FOUND",
        "source": {
          "pointer": "/data/relationships/user"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to attach a user to a license for another account
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "license"
    And the account "test2" has 1 "user" with the following:
      """
      { "id": "116b82ab-763b-4dd7-9403-35f8257ae99e" }
      """
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "116b82ab-763b-4dd7-9403-35f8257ae99e" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "must exist",
        "code": "USER_NOT_FOUND",
        "source": {
          "pointer": "/data/relationships/user"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to attach a user while trialing a paid tier without card but has exceeded their max licensed user limit
    Given I am an admin of account "test1"
    And the account "test1" has a max license limit of 50
    And the account "test1" does not have a card on file
    And the account "test1" is trialing
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "policy"
    And the current account has 2 "users"
    And the current account has 9 "licenses"
    And the current account has 5 "license-users" for each "license"
    And the current account has 1 "license"
    And the current account has 4 "license-users" for the last "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "402"
    And the response body should be an array of 1 error
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable resource",
        "detail": "Your tier's active licensed user limit of 50 has been reached for your account. Please upgrade to a paid tier and add a payment method at https://app.keygen.sh/billing.",
        "code": "ACCOUNT_ALU_LIMIT_EXCEEDED",
        "source": {
          "pointer": "/data/relationships/account"
        }
      }
      """
    And the current account should have 10 "licenses"
    And the current account should have 49 "license-users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin of another account attempts to attach themself to a license
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 1 "license"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[0]" }
        ]
      }
      """
    Then the response status should be "401"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches isolated users to an isolated license
    Given the current account is "test1"
    And the current account has 1 isolated "environment"
    And the current account has 3 isolated "users"
    And the current account has 1 isolated "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "isolated" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response should contain a valid signature header for "test1"
    And the response should contain the following headers:
      """
      { "Keygen-Environment": "isolated" }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches shared users to an isolated license
    Given the current account is "test1"
    And the current account has 1 isolated "environment"
    And the current account has 3 shared "users"
    And the current account has 1 isolated "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "isolated" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "You do not have permission to complete the request (a record's environment is not compatible with the current environment)"
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches global users to a shared license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 3 global "users"
    And the current account has 1 shared "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response should contain a valid signature header for "test1"
    And the response should contain the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches shared users to a global license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 3 shared "users"
    And the current account has 1 global "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response should contain a valid signature header for "test1"
    And the response should contain the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches shared users to a shared license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 2 shared "users"
    And the current account has 1 global "users"
    And the current account has 1 shared "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 3 "license-users"
    And the response should contain a valid signature header for "test1"
    And the response should contain the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment attaches mixed users to a shared license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 1 isolated "user"
    And the current account has 1 shared "user"
    And the current account has 1 global "user"
    And the current account has 1 shared "license"
    And I am an environment of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "Keygen-Environment": "shared" }
      """
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" },
          { "type": "users", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "You do not have permission to complete the request (a record's environment is not compatible with the current environment)"
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Product attaches users to a license
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 4 "users"
    And the current account has 1 "product"
    And the current account has 1 "policies" for existing "products"
    And the current account has 1 "license" for existing "policies"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 2 "license-users"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Product attempts to attach users to a license it doesn't own
    Given the current account is "test1"
    And the current account has 1 "webhook-endpoint"
    And the current account has 2 "users"
    And the current account has 2 "products"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "productId": "$products[1]" }
      """
    And the current account has 1 "license"
    And the first "license" has the following attributes:
      """
      { "policyId": "$policies[0]" }
      """
    And I am a product of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "404"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: License attempts to attach users to themselves
    Given the current account is "test1"
    And the current account has 2 "users"
    And the current account has 1 "product"
    And the current account has 1 "policies" for existing "products"
    And the current account has 1 "license" for existing "policies"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Owner attempts to attach users to a license (default permissions)
    Given the current account is "test1"
    And the current account has 3 "users"
    And the current account has 1 "license" for the last "user" as "owner"
    And I am the last user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Owner attempts to attach users to a license (explicit permission, unprotected license)
    Given the current account is "test1"
    And the current account has 3 "users"
    And the last "user" has the following permissions:
      """
      ["license.users.attach"]
      """
    And the current account has 1 unprotected "license" for the last "user" as "owner"
    And I am the last user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "200"
    And the response body should be an array with 2 "license-users"
    And the response body should be an array with 1 "license-user" with the following relationships:
      """
      {
        "user": {
          "links": { "related": "/v1/accounts/$account/users/$users[1]" },
          "data": { "type": "users", "id": "$users[1]" }
        }
      }
      """
    And the response body should be an array with 1 "license-user" with the following relationships:
      """
      {
        "user": {
          "links": { "related": "/v1/accounts/$account/users/$users[2]" },
          "data": { "type": "users", "id": "$users[2]" }
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 1 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Owner attempts to attach users to a license (explicit permission, protected license)
    Given the current account is "test1"
    And the current account has 3 "users"
    And the last "user" has the following permissions:
      """
      ["license.users.attach"]
      """
    And the current account has 1 protected "license" for the last "user" as "owner"
    And I am the last user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User attempts to attach users to their license (default permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "user"
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User attempts to attach users to their license (explicit permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "user"
    And the last "user" has the following permissions:
      """
      ["license.users.attach"]
      """
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User attempts to attach users to a license
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a POST request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "404"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  # Detachment
  Scenario: Admin detaches users from a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "webhook-endpoints"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "204"
    And the current account should have 0 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 3 "webhook" jobs
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  Scenario: Admin detaches empty users from a license
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 3 "webhook-endpoints"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      { "data": [] }
      """
    Then the response status should be "400"
    And the first error should have the following properties:
      """
      {
        "title": "Bad request",
        "detail": "length must be between 1 and 100 (inclusive)",
        "source": {
          "pointer": "/data"
        }
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to detach users from a license with an invalid user ID
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "license"
    And the current account has 3 "license-users" for existing "licenses"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "d22692b1-0b4b-4cb7-9e3e-449e0fdf9cd8" },
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "422"
    And the first error should have the following properties:
      """
      {
        "title": "Unprocessable entity",
        "detail": "cannot detach user 'd22692b1-0b4b-4cb7-9e3e-449e0fdf9cd8' (user is not attached)",
        "source": {
          "pointer": "/data/0"
        }
      }
      """
    And the current account should have 3 "license-users"
    And the current account should have 3 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: Admin attempts to detach a user from a license that is the owner
    Given I am an admin of account "test1"
    And the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "user" as "owner"
    And the current account has 1 "license-user" for the last "license"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "cannot detach user '$users[1]' (user is attached through owner)",
        "source": {
          "pointer": "/data/0"
        }
      }
      """

  Scenario: Admin attempts to detach a user from a license for another account
    Given I am an admin of account "test2"
    And the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "license-user" for existing "licenses"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "401"

  @ee
  Scenario: Admin detaches shared users from a shared license
    Given the current account is "test1"
    And the current account has 1 global "webhook-endpoint"
    And the current account has 1 shared "webhook-endpoint"
    And the current account has 1 shared "license"
    And the current account has 2 shared "license-users" for the last "license"
    And I am an admin of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "keygen-environment": "shared" }
      """
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "204"
    And the current account should have 0 "license-users"
    And the current account should have 2 "users"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Admin detaches shared users from a global license
    Given the current account is "test1"
    And the current account has 1 global "webhook-endpoint"
    And the current account has 1 shared "webhook-endpoint"
    And the current account has 1 global "license"
    And the current account has 2 global "license-users" for the last "license"
    And the current account has 2 shared "license-users" for the last "license"
    And I am an admin of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "keygen-environment": "shared" }
      """
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[3]" },
          { "type": "users", "id": "$users[4]" }
        ]
      }
      """
    Then the response status should be "204"
    And the current account should have 2 "license-users"
    And the current account should have 4 "users"
    And sidekiq should have 1 "webhook" job
    And sidekiq should have 1 "metric" job
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Admin detaches global users from a global license
    Given the current account is "test1"
    And the current account has 1 global "webhook-endpoint"
    And the current account has 1 shared "webhook-endpoint"
    And the current account has 1 global "license"
    And the current account has 2 global "license-users" for the last "license"
    And the current account has 2 shared "license-users" for the last "license"
    And I am an admin of account "test1"
    And I use an authentication token
    And I send the following headers:
      """
      { "keygen-environment": "shared" }
      """
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"
    And the current account should have 4 "license-users"
    And the current account should have 4 "users"
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  @ee
  Scenario: Environment detaches isolated users from an isolated license
    Given the current account is "test1"
    And the current account has 1 isolated "environment"
    And the current account has 1 isolated "license"
    And the current account has 4 isolated "license-users" for the last "license"
    And I am an environment of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users?environment=isolated" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[2]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "204"

  @ee
  Scenario: Environment detaches shared users from a shared license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 1 shared "license"
    And the current account has 2 shared "license-users" for the last "license"
    And I am an environment of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users?environment=shared" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "204"

  @ee
  Scenario: Environment detaches shared users from a global license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 1 global "license"
    And the current account has 2 shared "license-users" for the last "license"
    And the current account has 2 global "license-users" for the last "license"
    And I am an environment of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users?environment=shared" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "204"

  @ee
  Scenario: Environment detaches global users from a global license
    Given the current account is "test1"
    And the current account has 1 shared "environment"
    And the current account has 1 global "license"
    And the current account has 2 shared "license-users" for the last "license"
    And the current account has 2 global "license-users" for the last "license"
    And I am an environment of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users?environment=shared" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[3]" },
          { "type": "user", "id": "$users[4]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: Product detaches users from a license
    Given the current account is "test1"
    And the current account has 1 "product"
    And the current account has 1 "policies" for existing "products"
    And the current account has 1 "license" for existing "policies"
    And the current account has 4 "license-users" for existing "licenses"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "user", "id": "$users[1]" },
          { "type": "user", "id": "$users[3]" }
        ]
      }
      """
    Then the response status should be "204"

  Scenario: Product attempts to detach users from a license it doesn't own
    Given the current account is "test1"
    And the current account has 2 "products"
    And the current account has 1 "policy"
    And the first "policy" has the following attributes:
      """
      { "productId": "$products[1]" }
      """
    And the current account has 1 "license"
    And the first "license" has the following attributes:
      """
      { "policyId": "$policies[0]" }
      """
    And the current account has 2 "license-users" for existing "licenses"
    And I am a product of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" },
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "404"

  Scenario: License attempts to detach users to themselves
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 2 "license-users" for the last "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: License attempts to detach users from another license
    Given the current account is "test1"
    And the current account has 2 "licenses"
    And the current account has 1 "license-user" for each "license"
    And I am a license of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$1/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "404"

  Scenario: Owner attempts to detach a user from their license (default permission)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license" for the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: Owner attempts to detach a user from their license (explicit permission, unprotected license)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the last "user" has the following permissions:
      """
      ["license.users.detach"]
      """
    And the current account has 1 unprotected "license" for the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "204"

  Scenario: Owner attempts to detach a user from their license (explicit permission, protected license)
    Given the current account is "test1"
    And the current account has 1 "user"
    And the last "user" has the following permissions:
      """
      ["license.users.detach"]
      """
    And the current account has 1 protected "license" for the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[2]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: Owner attempts to detach themself from their license
    Given the current account is "test1"
    And the current account has 1 "user"
    And the last "user" has the following permissions:
      """
      ["license.users.detach"]
      """
    And the current account has 1 "license" for the last "user" as "owner"
    And the current account has 2 "license-users" for the last "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"
    And the first error should have the following properties:
      """
      {
        "title": "Access denied",
        "detail": "cannot detach user '$users[1]' (user is attached through owner)"
      }
      """
    And sidekiq should have 0 "webhook" jobs
    And sidekiq should have 0 "metric" jobs
    And sidekiq should have 1 "request-log" job

  Scenario: User attempts to detach users from their license (default permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "user"
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: User attempts to detach users from their license (explicit permission)
    Given the current account is "test1"
    And the current account has 1 "license"
    And the current account has 1 "user"
    And the last "user" has the following permissions:
      """
      ["license.users.detach"]
      """
    And the current account has 1 "license-user" for the last "license" and the last "user"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "403"

  Scenario: User attempts to detach users from a license
    Given the current account is "test1"
    And the current account has 1 "user"
    And the current account has 1 "license"
    And I am a user of account "test1"
    And I use an authentication token
    When I send a DELETE request to "/accounts/test1/licenses/$0/users" with the following:
      """
      {
        "data": [
          { "type": "users", "id": "$users[1]" }
        ]
      }
      """
    Then the response status should be "404"
