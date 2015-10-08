Feature: Project attachments
  In order to organize documents created outside of the system
  As a librarian
  I want to attach files to projects

  Scenario: Attach file as manager
    Given I am logged in as a manager
    And the project with title 'Dogs' exists
    And I view the project with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create'
    When I view the project with title 'Dogs'
    And I click on 'Attachments'
    Then I should see 'What the attachment is.'
    And the project with title 'Dogs' should have 1 attachment
