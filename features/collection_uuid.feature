Feature: Collection UUID
  In order to permanently identify collections
  As a librarian
  I want to assign a permanent UUID to each collection

  Background:
    Given I am logged in as an admin
    And There is a collection titled 'Dogs'

  Scenario: Collection should have UUID
    Then The collection titled 'Dogs' should have a valid UUID

  Scenario:
    When I view the collection with title 'Dogs'
    Then I should see 'UUID'
    And I should see the UUID of the collection titled 'Dogs'