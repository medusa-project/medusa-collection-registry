Feature: Archived Accrual Jobs
  In order to be able to investigate past accruals
  As a librarian
  I want to be able to view archived versions of accrual jobs

  Background:
    Given every archived accrual job with fields exists:
      | staging_path   | state     | report           |
      | staging/path/1 | completed | Staging Report 1 |
      | staging/path/2 | aborted   | Staging Report 2 |

  Scenario: View archived accrual job
    Given I am logged in as an admin
    When I view the archived accrual job with state 'completed'
    Then I should see all of:
      | staging/path/1 | completed | Staging Report 1 |
    And I should see none of:
      | staging/path/2 | aborted | Staging Report 2 |

  Scenario: View index of archived accrual jobs
    Given I am logged in as an admin
    When I go to the archived accrual job index page
    Then I should see all of:
      | staging/path/1 | completed | staging/path/2 | aborted |

  Scenario: Navigate to archived accrual jobs index from navbar
    Given I am logged in as an admin
    When I go to the dashboard
    And I click on 'Archived Accrual Jobs'
    Then I should be on the archived accrual jobs index page

