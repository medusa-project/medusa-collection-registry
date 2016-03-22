Feature: Cfs directory export
  In order to work with archived content
  As a user
  I want to be able to export my content

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has a file 'intro.txt' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'picture.jpg' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'description.txt' with contents 'anything'
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs | BitLevelFileGroup |
    And the file group titled 'Dogs' has cfs root 'dogs' and delayed jobs are run

  Scenario: Request an export of a directory
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    And I click on 'Download Files'
    Then I should see 'Your directory has been scheduled for export. You will be notified by email when the export is complete.'
    And there should be a simple download request for the export of the cfs directory for the file group titled 'Dogs' for the path '.'

  Scenario: Request an export of a directory tree
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    And I click on 'Download Files and All Subdirectories'
    Then I should see 'Your directory tree has been scheduled for export. You will be notified by email when the export is complete.'
    And there should be a recursive download request for the export of the cfs directory for the file group titled 'Dogs' for the path '.'

  Scenario: Error message is received
    When PENDING

  Scenario: Request received message is received
    When PENDING

  Scenario: Request completed message is received
    When PENDING

  Scenario: Deny exports to public and users
    Then deny object permission on the cfs directory with path 'dogs' to users for action with redirection:
      | public user | export(post), export_tree(post) | authentication |
      | user     | export(post), export_tree(post) | unauthorized   |
