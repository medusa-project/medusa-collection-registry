#Split this into its own files so that we can have a background that
#nicely sets things up
Feature: File Group Deletion Part Two
  In order to delete file groups safely
  As an admin
  I want to have a workflow that very conservatively allows deletion of file groups

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has a file 'intro.txt' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'picture.jpg' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'description.txt' with contents 'anything'
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              | id |
      | Dogs  | BitLevelFileGroup | 1  |
    And the file group titled 'Dogs' has cfs root 'dogs' and delayed jobs are run
    And the user 'manager@example.com' has a file group deletion workflow with fields:
      | state        | file_group_id |
      | move_content | 1             |


  Scenario: File group delete workflow in state move_content is run
    When I perform file group deletion workflows
    Then there should be 1 file group deletion workflow in state 'delete_content'
    And there should be 1 file group deletion workflow delayed job
    And there should be no cfs directory with path 'dogs'
    And there should be no file group with title 'Dogs'
    And there should be no cfs file with name 'intro.txt'
    And there should be no physical cfs directory 'dogs'
    And there should be a physical file group delete holding directory '1' with 3 files
    And the collection with title 'Animals' should have an event with key 'file_group_delete_moved' performed by 'manager@example.com'
    And there should be file group delete backup tables:
      | fg_holding_1.file_groups | fg_holding_1.cfs_directories | fg_holding_1.cfs_files | fg_holding_1.rights_declarations | fg_holding_1.assessments | fg_holding_1.events |

  Scenario: File group delete workflow in state delete_content is run
    #This puts it into the delete_content state with everything set up
    When I perform file group deletion workflows
    And I perform file group deletion workflows
    Then there should not be file group delete backup tables:
      | fg_holding_1.file_groups | fg_holding_1.cfs_directories | fg_holding_1.cfs_files | fg_holding_1.rights_declarations | fg_holding_1.assessments | fg_holding_1.events |
    And the collection with title 'Animals' should have an event with key 'file_group_delete_final' performed by 'manager@example.com'
    And there should not be a physical file group delete holding directory '1'
    And there should be 1 file group deletion workflow in state 'email_requester_final_removal'

  Scenario: File group delete workflow in state delete_content is restored
    #This puts it into the delete_content state with everything set up
    When I perform file group deletion workflows
    #Do the reversion
    #Check that the right things are present, and that the backups are gone, and that we're in the right state
    #Notably, we need to cascade all the event stuff after restoring it - or would it be better to just back that
    #up too? It might actually be simpler to do it that way and also restore it with SQL.
    #Note however, that this _does_ run the risk of having cascaded events that refer to objects that have
    #been deleted
    When PENDING

