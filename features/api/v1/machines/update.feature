@api/v1
Feature: Update machine

  Background:
    Given the following accounts exist:
      | Name  | Subdomain |
      | Test1 | test1     |
      | Test2 | test2     |
    And I send and accept JSON

  Scenario: Admin updates a machine
    Given I am an admin of account "test1"
    And I am on the subdomain "test1"
    And the current account has 1 "machine"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "Home iMac" } }
      """
    Then the response status should be "200"
    And the JSON response should be a "machine" with the name "Home iMac"

  Scenario: Admin attempts to update a machine's fingerprint
    Given I am an admin of account "test1"
    And I am on the subdomain "test1"
    And the current account has 1 "machine"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "fingerprint": "b7:WE:YV:oR:jU:Bc:d6:Wk:Yo:Po:Mu:oN:4Q:bC:pi" } }
      """
    Then the response status should be "400"

  Scenario: Product updates a machine for their product
    Given I am on the subdomain "test1"
    And the current account has 1 "product"
    And I am a product of account "test1"
    And I use my auth token
    And the current account has 1 "machine"
    And the current product has 1 "machine"
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "Work MacBook Pro" } }
      """
    Then the response status should be "200"
    And the JSON response should be a "machine" with the name "Work MacBook Pro"

  Scenario: Product attempts to update a machine for another product
    Given I am on the subdomain "test1"
    And the current account has 1 "product"
    And I am a product of account "test1"
    And I use my auth token
    And the current account has 1 "machine"
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "Office PC" } }
      """
    Then the response status should be "403"

  Scenario: User updates a machine's name for their license
    Given I am on the subdomain "test1"
    And the current account has 1 "user"
    And the current account has 1 "license"
    And all "licenses" have the following attributes:
      """
      { "userId": $users[1].id }
      """
    And the current account has 1 "machine"
    And all "machines" have the following attributes:
      """
      { "licenseId": $licenses[0].id }
      """
    And I am a user of account "test1"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "Office Mac" } }
      """
    Then the response status should be "200"
    And the JSON response should be a "machine" with the name "Office Mac"

  Scenario: User updates a machine's fingerprint for their license
    Given I am on the subdomain "test1"
    And the current account has 1 "user"
    And the current account has 1 "license"
    And all "licenses" have the following attributes:
      """
      { "userId": $users[1].id }
      """
    And the current account has 1 "machine"
    And all "machines" have the following attributes:
      """
      { "licenseId": $licenses[0].id }
      """
    And I am a user of account "test1"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "fingerprint": "F8:2B:DV:tH:Tm:AY:uG:QG:VJ:ct:N6:nK:WF:tq:vr" } }
      """
    Then the response status should be "400"

  Scenario: User attempts to update a machine for their account
    Given I am on the subdomain "test1"
    And the current account has 3 "machines"
    And the current account has 1 "user"
    And I am a user of account "test1"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "Office Mac" } }
      """
    Then the response status should be "403"

  Scenario: Anonymous user attempts to update a machine for their account
    Given I am on the subdomain "test1"
    And the current account has 3 "machines"
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "iPad 4" } }
      """
    Then the response status should be "401"

  Scenario: Admin attempts to update a machine for another account
    Given I am an admin of account "test2"
    But I am on the subdomain "test1"
    And the current account has 3 "machines"
    And I use my auth token
    When I send a PATCH request to "/machines/$0" with the following:
      """
      { "machine": { "name": "PC" } }
      """
    Then the response status should be "401"
