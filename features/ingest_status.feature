Feature: Medusa ingest status
  In order to track the progress of an ingest
  As a librarian
  I want to record information about the ingest in parallel with the corresponding collection

  Background:
    Given I am logged in
    And There is a collection titled 'Dogs'

  Scenario: Every collection has an ingest status after creation
    Then the collection titled 'Dogs' has an associated ingest status

  Scenario: View ingest status along with collection
    Given the collection titled 'Dogs' has ingest status with fields:
      | state   | staff          | date         | notes               |
      | started | staff1, staff2 | 2012-08-28 | Ingest status notes |
    When I view the collection titled 'Dogs'
    Then I should see all of:
      | started | 2012-08-28 | Ingest status notes |
    And There should be an external link 'staff1' to the UIUC Net ID search
    And There should be an external link 'staff2' to the UIUC Net ID search