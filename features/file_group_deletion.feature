Feature: File Group Deletion
  In order to delete file groups safely
  As an admin
  I want to have a workflow that very conservatively allows deletion of file groups

  Scenario: Delete external file group
    When PENDING

  Scenario: Delete pristine bit level file group
    When PENDING

  Scenario: Start delete process for non-pristine bit level file group
    When PENDING
    #visit fg, click, get redirected to make new workflow, fill in form, submit, check
    #that workflow exists in the start state

  Scenario: File group delete workflow moves from start to email_superusers
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state |
      | start |
    When I perform file group deletion workflows
    Then there should be 1 file group deletion workflow in state 'email_superusers'
    And there should be 1 file group deletion workflow delayed job

  Scenario: File group delete workflow in state email_superusers is run
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state            | requester_reason |
      | email_superusers | No longer needed |
    When I perform file group deletion workflows
    Then 'superadmin@example.com' should receive an email with subject 'Medusa File Group deletion requested' containing all of:
      | No longer needed |
    And there should be 1 file group deletion workflow in state 'wait_decision'
    And there should be 0 file group deletion workflow delayed jobs

  @javascript
  Scenario: File group delete workflow in wait_decision is accepted by admin
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state         | requester_reason |
      | wait_decision | No longer needed |
    And I am logged in as 'superadmin@example.com'
    When I go to the dashboard
    And I click on 'File Group Deletions'
    And I click on 'Decide'
    And I fill in fields:
      | Approver reason | Time for this to go |
    And I click on 'Approve'
#    When I admin decide on the file group delete workflow
#    And I click on 'Approve'
    And there should be 1 file group deletion workflow in state 'email_requester_accept'
    And there should be 1 file group deletion workflow delayed job

  Scenario: File group delete workflow in state email_requester_accept is run
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state                  |
      | email_requester_accept |
    When I perform file group deletion workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa File Group deletion approved'
    And there should be 1 file group deletion workflow in state 'move_content'
    And there should be 1 file group deletion workflow delayed job

  Scenario: File group delete workflow in state move_content is run
    When PENDING

  Scenario: File group delete workflow in state delete_content is run
    When PENDING

  Scenario: File group delete workflow in state email_requester_final_delete is run
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state                         | cached_file_group_title |
      | email_requester_final_removal | My File Group Title     |
    When I perform file group deletion workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa File Group final deletion completed' containing all of:
      | My File Group Title |
    And there should be 1 file group deletion workflow in state 'end'
    And there should be 1 file group deletion workflow delayed job

  Scenario: File group delete workflow in state end is run
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state |
      | end   |
    When I perform file group deletion workflows
    Then there should be 0 file group deletion workflows

  @javascript
  Scenario: File group delete workflow in wait_decision is rejected by admin
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state         | requester_reason |
      | wait_decision | No longer needed |
    And I am logged in as 'superadmin@example.com'
    When I go to the dashboard
    And I click on 'File Group Deletions'
    And I click on 'Decide'
    And I fill in fields:
      | Approver reason | Still needed |
    And I click on 'Reject'
#    When I admin decide on the file group delete workflow
#    And I click on 'Reject'
    And there should be 1 file group deletion workflow in state 'email_requester_reject'
    And there should be 1 file group deletion workflow delayed job

  Scenario: File group delete workflow in state email_requester_reject is run
    Given the user 'manager@example.com' has a file group deletion workflow with fields:
      | state                  | approver_reason |
      | email_requester_reject | Still using     |
    When I perform file group deletion workflows
    Then 'manager@example.com' should receive an email with subject 'Medusa File Group deletion rejected' containing all of:
      | Still using |
    And there should be 1 file group deletion workflow in state 'end'
    And there should be 1 file group deletion workflow delayed job
