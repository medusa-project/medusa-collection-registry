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
      | Tester email | fluffypuffy@example.com |
      | Date         | 2015-10-08              |
      | Notes        | Random stuff            |
    And I select 'TIFF' from 'File format profile'
    And I check all of:
      | corrupt | software unavailable |
    And I choose 'Pass'
    And I click on 'Create'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see all of:
      | fluffypuffy@example.com | 2015-10-08 | Pass | corrupt | software unavailable | Random stuff |
    And I should see none of:
      | saved with incorrect extension |
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
    And I choose 'Pass'
    And I click on 'Update'
    Then I should be on the view page for the cfs file with name 'Ruthie'
    And I should see all of:
      | fluffypuffy@example.com | 2015-10-08 | Pass | corrupt | software unavailable | Random stuff |
    And I should see none of:
      | saved with incorrect extension | sugar@example.com | 2015-10-06 | false | Sugie notes |
    And the cfs file with name 'Ruthie' should have an associated file format test

