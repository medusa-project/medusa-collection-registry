Feature: order to organize documents created outside of the system
  As a librarian
  I want to attach files to file groups

  Scenario: Attach file as admin
    Given I am logged in as an admin
    And the collection titled 'Animals' has file groups with fields:
      | name |
      | Dogs |
    And I view the file group named 'Dogs'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create Attachment'
    When I view the file group named 'Dogs'
    Then I should see 'What the attachment is.'
    And the file group named 'Dogs' should have 1 attachment

  Scenario: Attach file as manager
    Given I am logged in as a manager
    And the collection titled 'Animals' has file groups with fields:
      | name |
      | Dogs |
    And I view the file group named 'Dogs'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | What the attachment is. |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create Attachment'
    When I view the file group named 'Dogs'
    Then I should see 'What the attachment is.'
    And the file group named 'Dogs' should have 1 attachment

