Feature: File Group Deletion
  In order to delete file groups safely
  As an admin
  I want to have a workflow that very conservatively allows deletion of file groups

  #When I perform file group deletion workflows

  Scenario: Delete external file group
    When PENDING

  Scenario: Delete pristine bit level file group
    When PENDING

  Scenario: Start delete process for non-pristine bit level file group
    When PENDING

  Scenario: File group delete workflow moves from start to email_admins
    When PENDING

  Scenario: File group delete workflow in wait_decision is accepted by admin
    When PENDING

  Scenario: File group delete workflow in state email_requester_accept is run
    When PENDING

  Scenario: File group delete workflow in state move_content is run
    When PENDING

  Scenario: File group delete workflow in state delete_content is run
    When PENDING

  Scenario: File group delete workflow in state email_requester_final_delete is run
    When PENDING

  Scenario: File group delete workflow in state end is run
    When PENDING

  Scenario: File group delete workflow in wait_decision is rejected by admin
    When PENDING

  Scenario: File group delete workflow in state email_requester_reject is run
    When PENDING
