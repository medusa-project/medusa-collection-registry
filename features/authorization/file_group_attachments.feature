Feature: Attachment authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given I am logged in as an admin
    And the collection with title 'Animals' has child file groups with fields:
      | title |
      | Dogs |
    And I view the file group with title 'Dogs'
    And I click on 'Attachments'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | grass |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create'
    And I logout

  Scenario: Enforce permissions
    Then deny object permission on the attachment with description 'grass' to users for action with redirection:
      | public user | view, download, edit, update, delete | authentication |
      | user     | edit, update, delete                 | unauthorized   |
      | manager     | delete                               | unauthorized   |

  Scenario: Public user tries to start attachment
    Then a public user is unauthorized to start an attachment for the file group with title 'Dogs'

  Scenario: Public user tries to create attachment
    Then a public user is unauthorized to create an attachment for the file group with title 'Dogs'

  Scenario: user tries to start attachment
    Then a user is unauthorized to start an attachment for the file group with title 'Dogs'

  Scenario: user tries to create attachment
    Then a user is unauthorized to start an attachment for the file group with title 'Dogs'

