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
      | state   | staff          | date       | notes               |
      | started | staff1, staff2 | 2012-08-28 | Ingest status notes |
    When I view the collection titled 'Dogs'
    Then I should see all of:
      | started | 2012-08-28 | Ingest status notes |
    And I should see an external link 'staff1' to the UIUC Net ID search
    And I should see an external link 'staff2' to the UIUC Net ID search

  Scenario: Edit ingest status
    Given the collection titled 'Dogs' has ingest status with fields:
      | state   | staff          | date       | notes               |
      | started | staff1, staff2 | 2012-08-28 | Ingest status notes |
    When I edit the collection titled 'Dogs'
    And I select ingest state 'complete'
    And I fill in ingest status fields:
      | Notes                                  | Revised notes |
    And I click on 'Update Ingest status'
    Then I should see all of:
      | complete | Revised notes |

  Scenario: Link to staff in ingest status
    Given the collection titled 'Dogs' has ingest status with fields:
          | state   | staff          | date       | notes               |
          | started | staff1, staff2 | 2012-08-28 | Ingest status notes |
    When I view the collection titled 'Dogs'
    Then I should see an external link 'staff1' to the UIUC Net ID search
    Then I should see an external link 'staff2' to the UIUC Net ID search