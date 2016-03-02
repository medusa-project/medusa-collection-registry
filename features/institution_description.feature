Feature: Institution description
  In order to allow different institutions to manage content repositories
  As a medusa admin
  I want to be able to create and manage institutions

  Background:
    Given every institution with fields exists:
      | name    |
      | UIUC    |
      | SUNY-SB |

  Scenario: As a medusa admin I can see a list of institutions
    Given I am logged in as a medusa admin
    When I go to the institution index page
    Then I should see the institutions table
    And I should see all of:
      | UIUC | SUNY-SB |

  Scenario: As a medusa admin I can create a new institution
    Given I am logged in as a medusa admin
    When I go to the institution index page
    And I click on 'New Institution'
    And I fill in fields:
      | Name | Cal |
    And I click on 'Create Institution'
    Then I should be on the view page for the institution with name 'Cal'

  Scenario: As a non-medusa admin I cannot do certain actions on institutions
    Then deny permission on the institution collection to users for action with redirection:
      | public user      | view_index, new, create | authentication |
      | user, manager | view_index, new, create | unauthorized   |

  Scenario: As a medusa admin I can see an individual institution
    Given I am logged in as a medusa admin
    And the institution with name 'UIUC' has child repositories with field title:
      | Animals | Plants |
    When I view the institution with name 'UIUC'
    Then I should see all of:
      | UIUC | Animals | Plants |
    And I should not see 'SUNY-SB'
    And I should see the repositories table

  Scenario: As a medusa admin I can edit an individual institution
    Given I am logged in as a medusa admin
    When I view the institution with name 'UIUC'
    And I click on 'Edit'
    And I fill in fields:
      | Name | University of Illinois |
    And I click on 'Update Institution'
    Then I should be on the view page for the institution with name 'University of Illinois'
    And there should be no institution with name 'UIUC'

  Scenario: As a medusa admin I can delete an individual institution
    Given I am logged in as a medusa admin
    When I edit the institution with name 'UIUC'
    And I click on 'Delete'
    Then I should be on the institution index page
    And there should be no institution with name 'UIUC'

  Scenario: As a non medusa admin I cannot do certain actions an individual institution
    Then deny object permission on the institution with name 'UIUC' to users for action with redirection:
      | public user      | view, edit, update, delete | authentication |
      | user, manager | view, edit, update, delete | unauthorized   |