Feature: Hide cfs directory field for non-cfs file group types
  In order to not accidentally set the cfs directory of a file group
  As an editor of a file group
  I want to not see it on the editing form

  Background:
    Given I am logged in as an admin

  Scenario: Hide for existing external file group
    Given the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs | ExternalFileGroup |
    When I edit the file group with title 'Dogs'
    Then I should not see 'Cfs Root'
