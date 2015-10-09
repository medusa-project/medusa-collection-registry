Feature: File Format Tests
  In order to track file quality
  As a librarian
  I want to record information about how cfs files fare when we try to operate on them in appropriate ways

  Background:
    Given each cfs file with name exists:
      | Ruthie | Buster |
    And each file format profile with name exists:
      | JPEG2000 | TIFF |
    And every file format test with fields exists:
      | tester_email      | date       | pass  | notes       |
      | sugar@example.com | 2015-10-06 | false | Sugie notes |

  Scenario: Add file format test to cfs file
    Given I am logged in as a manager
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    And I fill in fields:
      | Date  | 2015-10-08   |
      | Notes | Random stuff |
    And I select 'TIFF' from 'File format profile'
    And I check all of:
      | corrupt | software unavailable |
    And I choose 'Fail'
    And I click on 'Create'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see all of:
      | manager@example.com | 2015-10-08 | Fail | corrupt | software unavailable | Random stuff |
    And I should see none of:
      | saved with incorrect extension | Pass |
    And the cfs file with name 'Ruthie' should have an associated file format test

  Scenario: Edit file format test of existing cfs file
    Given I am logged in as a manager
    And the cfs file with name 'Ruthie' is associated with the file format test with tester email 'sugar@example.com'
    When I view the cfs file with name 'Ruthie'
    And I click on 'Edit File format test'
    And I fill in fields:
      | Tester email | fluffypuffy@example.com |
      | Date         | 2015-10-08              |
      | Notes        | Random stuff            |
    And I select 'TIFF' from 'File format profile'
    And I check all of:
      | corrupt | software unavailable |
    And I choose 'Fail'
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

  @javascript
  Scenario: User can add reasons when inputting a file format test
    Given I am logged in as a manager
    When I view the cfs file with name 'Ruthie'
    And I click on 'Create File format test'
    And I select 'TIFF' from 'File format profile'
    And I choose 'Fail'
    And I fill in fields:
      | new_reason_label | expired format |
    And I click on 'Add Reason'
    And I check 'expired format'
    And I click on 'Create'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see 'expired format'
