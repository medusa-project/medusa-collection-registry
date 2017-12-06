Feature: File Format Tests
  In order to track file quality
  As a librarian
  I want to record information about how cfs files fare when we try to operate on them in appropriate ways

  Background:
    Given each attached cfs file with name exists:
      | Ruthie | Buster |
    And every file format profile with fields exists:
      | name     | status   |
      | JPEG2000 | active   |
      | TIFF     | active   |
      | GIF      | inactive |
    And every file format test with fields exists:
      | tester_email      | date       | pass  | notes       |
      | sugar@example.com | 2015-10-06 | false | Sugie notes |

  @javascript @poltergeist
  Scenario: Add file format test to cfs file
    Given I am logged in as a manager
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    And I select 'TIFF' from 'File format profile'
    And I choose 'Fail'
    And I check all of:
      | corrupt | software unavailable |
    And I fill in fields:
      | Notes | Random stuff |
      | Date  | 2015-10-08   |
    And I click on 'Create'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see all of:
      | manager@example.com | 2015-10-08 | Fail | corrupt | software unavailable | Random stuff |
    And I should see none of:
      | saved with incorrect extension | Pass |
    And the cfs file with name 'Ruthie' should have an associated file format test

  @javascript @poltergeist
  Scenario: Edit file format test of existing cfs file
    Given I am logged in as a manager
    And the cfs file with name 'Ruthie' is associated with the file format test with tester email 'sugar@example.com'
    When I view the cfs file with name 'Ruthie'
    And I click on 'Edit File format test'
    And I select 'TIFF' from 'File format profile'
    And I choose 'Fail'
    And I check all of:
      | corrupt | software unavailable |
    And I fill in fields:
      | Tester email | fluffypuffy@example.com |
      | Notes        | Random stuff            |
      | Date         | 2015-10-08              |
    And I click on 'Update'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see all of:
      | fluffypuffy@example.com | 2015-10-08 | Fail | corrupt | software unavailable | Random stuff |
    And I should see none of:
      | saved with incorrect extension | sugar@example.com | 2015-10-06 | false | Sugie notes | Pass |
    And the cfs file with name 'Ruthie' should have an associated file format test

  @javascript
  Scenario: Checking pass should clear and disable checked reasons
    Given I am logged in as a manager
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    And I choose 'Fail'
    And I check all of:
      | corrupt | software unavailable |
    And I choose 'Pass'
    Then the checkbox 'corrupt' should be disabled and unchecked
    And the checkbox 'software unavailable' should be disabled and unchecked

  @javascript @poltergeist
  Scenario: User can add reasons when inputting a file format test
    Given I am logged in as a manager
    #make sure this isn't left over after an error or something
    And I destroy the file format test reason with label 'ancient format'
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    And I select 'TIFF' from 'File format profile'
    And I choose 'Fail'
    And I fill in fields:
      | new_reason_label | ancient format |
    And I click on 'Add Reason'
    And I check 'ancient format'
    And I click on 'Create'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see 'ancient format'
    #This is just to clean up - database_cleaner won't get this otherwise
    And I destroy the file format test reason with label 'ancient format'

  Scenario: Inactive file format profiles should not show
    Given I am logged in as a manager
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    Then I should see all of:
      | JPEG2000 | TIFF |
    And I should not see 'GIF'

  Scenario: Navigate to index of file format tests
    Given I am logged in as a user
    When I go to the dashboard
    And I click on 'File Format Tests'
    Then I should be on the file format tests index page

  Scenario: View index of file format tests
    Given I am logged in as a user
    When I go to the file format tests index page
    Then I should see all of:
      | sugar@example.com | 2015-10-06 | Fail | Sugie notes |

  Scenario: CSV download of file format tests
    Given I am logged in as a user
    When I go to the file format tests index page
    And I click on 'CSV'
    Then I should receive a file 'file_format_tests.csv' of type 'text/csv' matching:
      | sugar@example.com | 2015-10-06 | Fail | Sugie notes |
