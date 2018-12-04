#Split this into its own files so that we can have a background that
#nicely sets things up
Feature: File Group Deletion Part Two
  In order to delete file groups safely
  As an admin
  I want to have a workflow that very conservatively allows deletion of file groups

  Background:
    Given the main storage has a key '1/1/intro.txt' with contents 'anything'
    And the main storage has a key '1/1/pugs/picture.jpg' with contents 'anything'
    And the main storage has a key '1/1/pugs/description.txt' with contents 'anything'
    And the repository with title 'Things' has child collections with fields:
      | title   | id |
      | Animals | 1  |
    And every file group with fields exists:
      | title | type              | id | collection_id |
      | Dogs  | BitLevelFileGroup | 1  | 1             |
    And the file group titled 'Dogs' has cfs root '1/1' and delayed jobs are run
    And the user 'manager@example.com' has a file group deletion workflow with fields:
      | state                  | file_group_id |
      | initial_handle_content | 1             |

  Scenario: File group delete workflow in state initial_handle_content is run
    When I perform file group deletion workflows
    Then there should be 1 file group deletion workflow in state 'wait_delete_content'
    And there should be 1 file group deletion workflow delayed job
    And there should be no cfs directory with path '1/1'
    And there should be no file group with title 'Dogs'
    And there should be no cfs file with name 'intro.txt'
    And the delete notification file should exist for '1/1'
    And the collection with title 'Animals' should have an event with key 'file_group_delete_moved' performed by 'manager@example.com'
    And there should be file group delete backup tables:
      | fg_holding_1.file_groups | fg_holding_1.cfs_directories | fg_holding_1.cfs_files | fg_holding_1.rights_declarations | fg_holding_1.assessments | fg_holding_1.events |

  Scenario: File group delete workflow in state delete_content is run
    #This puts it into the delete_content state with everything set up
    When I perform file group deletion workflows
    #Then the real test - go from wait_delete_content to delete_content and run that
    And I perform file group deletion workflows
    And I perform file group deletion workflows
    Then there should not be file group delete backup tables:
      | fg_holding_1.file_groups | fg_holding_1.cfs_directories | fg_holding_1.cfs_files | fg_holding_1.rights_declarations | fg_holding_1.assessments | fg_holding_1.events |
    And the collection with title 'Animals' should have an event with key 'file_group_delete_final' performed by 'manager@example.com'
    And the delete notification file should not exist for '1/1'
    And the main storage should not have content under '1/1'
    And there should be 1 file group deletion workflow in state 'email_requester_final_removal'

  @javascript
  Scenario: File group delete workflow in state delete_content is restored
    #This puts it into the delete_content state with everything set up
    When I perform file group deletion workflows
    Given I am logged in as 'superadmin@example.com'
    When I go to the dashboard
    And I click on 'File Group Deletions'
    And I click on 'Restore'
    Then I should see 'Starting to restore content'
    And there should be 1 file group deletion workflow in state 'restore_content'
    And there should be 1 file group deletion workflow delayed job
    When I perform file group deletion workflows
    Then there should be 1 file group deletion workflow in state 'email_restored_content'
    And the delete notification file should not exist for '1/1'
    And the main storage should have content under '1/1'
    #the content should be restored in the database and the backup tables gone
    And there should not be file group delete backup tables:
      | fg_holding_1.file_groups | fg_holding_1.cfs_directories | fg_holding_1.cfs_files | fg_holding_1.rights_declarations | fg_holding_1.assessments | fg_holding_1.events |
    And the file groups with fields should exist:
      | title | total_files |
      | Dogs  | 3           |
    And the cfs directory with fields should exist:
      | path | tree_size | tree_count |
      | 1/1  | 24        | 3          |
      | pugs | 16        | 2          |
    And each cfs file with name exists:
      | intro.txt | picture.jpg | description.txt |
    And 0 cfs files should have fits attached
    And the collection with title 'Animals' should have an event with key 'file_group_delete_restored' performed by 'manager@example.com'
    And there should be 1 amazon backup delayed job
