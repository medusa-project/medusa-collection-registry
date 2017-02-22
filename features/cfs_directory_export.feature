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
      | Dogs  | BitLevelFileGroup |
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
    And I click on 'Download Files - Include Subfolders'
    Then I should see 'Your directory tree has been scheduled for export. You will be notified by email when the export is complete.'
    And there should be a recursive download request for the export of the cfs directory for the file group titled 'Dogs' for the path '.'

  Scenario: Request a TSV representation of a directory tree
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    And I click on 'TSV'
    Then I should receive a file 'dogs.tsv' of type 'text/tab-separated-values' matching:
      | intro.txt | picture.jpg | description.txt | dogs | pugs |

  Scenario: Request a JSON representation of a directory tree
    Given I am logged in as a manager
    When I view the cfs directory for the file group titled 'Dogs' for the path '.'
    And I click on 'JSON Tree'
    And the JSON at "name" should be "dogs"
    And the JSON at "relative_pathname" should be "dogs"
    And the JSON at "files/0/name" should be "intro.txt"
    And the JSON at "files/0/size" should be 8
    And the JSON at "files/0/relative_pathname" should be "dogs/intro.txt"
    And the JSON at "subdirectories" should have 1 entries
    And the JSON at "subdirectories/0/files" should have 2 entries
    And the JSON at "subdirectories/0/files/0/size" should be 8

  Scenario: Error message is received
    Given there is a downloader request for the export of the cfs directory for the file group titled 'Dogs' for the path '.' with fields:
      | email            | status  | downloader_id |
      | user@example.com | pending | 123abc        |
    When a downloader error message is received with id '123abc'
    Then the downloader request with id '123abc' should have status 'error'
    And 'user@example.com' should receive an email with subject 'Medusa Download error'
    And 'medusa-admin@example.com' should receive an email with subject 'Medusa Download error'

  Scenario: Request received message is received
    Given there is a downloader request for the export of the cfs directory for the file group titled 'Dogs' for the path '.' with fields:
      | email            | status  | downloader_id |
      | user@example.com | pending | 123abc        |
    When a downloader request received message is received with id '123abc'
    Then the downloader request with id '123abc' should have status 'request_received'

  Scenario: Request completed message is received
    Given there is a downloader request for the export of the cfs directory for the file group titled 'Dogs' for the path '.' with fields:
      | email            | status           | downloader_id |
      | user@example.com | request_received | 123abc        |
    When a downloader request completed message is received with id '123abc'
    Then the downloader request with id '123abc' should have status 'request_completed'
    And 'user@example.com' should receive an email with subject 'Medusa Download ready'

  Scenario: Deny exports to public and users
    Then deny object permission on the cfs directory with path 'dogs' to users for action with redirection:
      | public user | export(post), export_tree(post) | authentication |
      | user        | export(post), export_tree(post) | unauthorized   |
