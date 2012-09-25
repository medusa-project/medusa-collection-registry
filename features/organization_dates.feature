Feature: Track organization active dates
  In order to know when organizations were operating
  As a librarian
  I want to track their active start and end dates

  Background:
    Given I am logged in as an admin
    And I have repositories with fields:
      | title   | active_start_date | active_end_date |
      | Animals | 2012-09-13        | 2012-10-14      |
    And I have producers with fields:
      | title    | active_start_date | active_end_date |
      | Scanning | 2012-11-15        | 2012-12-16      |

  Scenario: View repository active dates
    When I view the repository titled 'Animals'
    Then I should see all of:
      | Active Start Date | Active End Date | 2012-09-13 | 2012-10-14 |

  Scenario: View producer active dates
    When I view the producer titled 'Scanning'
    Then I should see all of:
      | Active Start Date | Active End Date | 2012-11-15 | 2012-12-16 |

  Scenario: Edit repository active dates
    When I edit the repository titled 'Animals'
    And I fill in fields:
      | Active Start Date | 2011-01-20 |
      | Active End Date   | 2011-02-21 |
    And I click on 'Update Repository'
    Then I should see all of:
      | 2011-01-20 | 2011-02-21 |
    And I should not see '2012-09-13'

  Scenario: Edit producer active dates
    When I edit the producer titled 'Scanning'
    And I fill in fields:
      | Active Start Date | 2011-01-20 |
      | Active End Date   | 2011-02-21 |
    And I click on 'Update Producer'
    Then I should see all of:
      | 2011-01-20 | 2011-02-21 |
    And I should not see '2012-12-16'

  Scenario: Incorrectly edit repository active dates
    When I edit the repository titled 'Animals'
    And I fill in fields:
      | Active Start Date | 2020-01-01 |
    And I click on 'Update Repository'
    Then I should not see '2020-01-01'
    And I should see 'Start date must not be later than end date.'

  Scenario: Incorrectly edit producer active dates
    When I edit the producer titled 'Scanning'
    And I fill in fields:
      | Active End Date | 1990-01-01 |
    And I click on 'Update Producer'
    Then I should not see '1990-01-01'
    And I should see 'Start date must not be later than end date.'
