Feature: Attachment authorization
  In order to protect the attachments
  As the system
  I want to enforce proper authorization

  Background:
    Given I am logged in as an admin
    And There is a collection titled 'Dogs'
    And I view the collection titled 'Dogs'
    And I click on 'Add Attachment'
    And I fill in fields:
      | Description | grass |
    And I attach fixture file 'grass.jpg' to 'Attachment'
    And I click on 'Create Attachment'
    And I logout

  Scenario: Public user tries to view attachment
    Then trying to view the attachment with description 'grass' as a public user should redirect to authentication

  Scenario: Public user tries to download attachment
    Then trying to download the attachment with description 'grass' as a public user should redirect to authentication

  Scenario: Public user tries to edit attachment
    Then trying to edit the attachment with description 'grass' as a public user should redirect to authentication

  Scenario: Public user tries to update attachment
    Then trying to update the attachment with description 'grass' as a public user should redirect to authentication

  Scenario: Public user tries to start attachment
    Then a public user is unauthorized to start an attachment for the collection titled 'Dogs'

  Scenario: Public user tries to create attachment
    Then a public user is unauthorized to create an attachment for the collection titled 'Dogs'

  Scenario: Visitor tries to edit attachment
    Then trying to edit the attachment with description 'grass' as a visitor should redirect to unauthorized

  Scenario: Visitor tries to update attachment
    Then trying to update the attachment with description 'grass' as a visitor should redirect to unauthorized

  Scenario: Visitor tries to start attachment
    Then a visitor is unauthorized to start an attachment for the collection titled 'Dogs'

  Scenario: Visitor tries to create attachment
    Then a visitor is unauthorized to start an attachment for the collection titled 'Dogs'

  Scenario: Manager tries to delete attachment
    Then trying to delete the attachment with description 'grass' as a manager should redirect to unauthorized
