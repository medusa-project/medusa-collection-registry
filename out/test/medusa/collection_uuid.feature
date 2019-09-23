Feature: Collection UUID
  In order to permanently identify collections
  As a librarian
  I want to assign a permanent UUID to each collection

  Background:
    Given I am logged in as an admin
    And the collection with title 'Dogs' exists

  Scenario: Collection should have UUID
    Then The collection with title 'Dogs' should have a valid uuid

  Scenario: Collection uuid should be shown in interface
    When I view the collection with title 'Dogs'
    Then I should see 'UUID'
    And I should see the uuid of the collection with title 'Dogs'