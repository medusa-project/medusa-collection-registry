Feature: File group attachments
  In order to organize documents created outside of the system
  As a librarian
  I want to attach files to file groups

  Scenario: Attach file as admin
    Given I am logged in as an admin
    And the collection with title 'Animals' has child file groups with fields:
      | title |
      | Dogs |
    And I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create'
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    Then I should see 'What the attachment is.'
    And the file group with title 'Dogs' should have 1 attachment

  Scenario: Attach file as manager
    Given I am logged in as a manager
    And the collection with title 'Animals' has child file groups with fields:
      | title |
      | Dogs |
    And I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create'
    When I view the file group with title 'Dogs'
    And I click on 'Attachments'
    Then I should see 'What the attachment is.'
    And the file group with title 'Dogs' should have 1 attachment

