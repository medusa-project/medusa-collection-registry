Feature: Access Systems
  In order to facilitate preservation
  As a librarian
  I want to track the access systems used by a collection

  Background:
    Given I am logged in as an admin
    And every access system with fields exists:
      | name      | service_owner | application_manager |
      | ContentDM | Timothy       | Mike                |
      | Dspace    | Sarah         | Seth                |

  Scenario: View index
    When I go to the access system index page
    Then I should be on the access system index page
    And I should see all of:
      | ContentDM | Timothy | Mike | Dspace | Sarah | Seth |

  Scenario: View an access system
    When I view the access system with name 'ContentDM'
    Then I should be on the view page for the access system with name 'ContentDM'
    And I should see all of:
      | Name | Service Owner | Application Manager | ContentDM | Timothy | Mike |

  Scenario: Edit an access system
    When I edit the access system with name 'ContentDM'
    And I fill in fields:
      | Name                | Blacklight |
      | Service owner       | Cole       |
      | Application manager | Tang       |
    And I press 'Update'
    Then I should be on the view page for the access system with name 'Blacklight'
    And there should be no access system with name 'ContentDB'
    And I should see all of:
      | Cole | Tang | Blacklight |
    And I should see none of:
      | Timothy | Mike | ContentDB |

  Scenario: Invalid edit of an access system
    When I edit the access system with name 'ContentDM'
    And I fill in fields:
      | Name |  |
    And I press 'Update'
    Then I should be on the update page for the access system with name 'ContentDM'
    And I should see 'can't be blank'

  Scenario: Delete access system from edit page
    When I edit the access system with name 'ContentDM'
    And I click on 'Delete'
    Then I should be on the access system index page
    And I should not see 'ContentDM'

  Scenario: Create from index page
    When I go to the access system index page
    And I click on 'New Access System'
    Then I should be on the new access system page

  Scenario: Create an access system
    When I go to the access system index page
    And I click on 'New Access System'
    And I fill in fields:
      | Name | New System |
    And I click on 'Create'
    Then I should be on the view page for the access system with name 'New System'
    And I should see 'New System'

  Scenario: Invalid create of an access system
    When I go to the access system index page
    And I click on 'New Access System'
    And I fill in fields:
      | Name |  |
    And I click on 'Create'
    Then I should be on the create access system page
    And I should see 'can't be blank'

  Scenario: Navigate from view page to index page
    When I view the access system with name 'ContentDM'
    And I click on 'Index'
    Then I should be on the access system index page

  Scenario: Navigate from view page to edit page
    When I view the access system with name 'ContentDM'
    And I click on 'Edit'
    Then I should be on the edit page for the access system with name 'ContentDM'

  Scenario: View collections associated with an access system
    Given the collection with title 'Dogs' has child access system with field name:
      | ContentDM |
    And the collection with title 'Cats' has child access systems with field name:
      | Dspace | ContentDM |
    And the collection with title 'Bats' has child access system with field name:
      | Dspace |
    When I go to the access system index page
    And I click on 'ContentDM'
    Then I should see all of:
      | Dogs | Cats | Collections | ContentDM |
    And I should not see 'Bats'

  Scenario: View collections associated with an access system as a manager
    Given I relogin as a manager
    Given the collection with title 'Dogs' has child access system with field name:
      | ContentDM |
    And the collection with title 'Cats' has child access systems with field name:
      | Dspace | ContentDM |
    And the collection with title 'Bats' has child access system with field name:
      | Dspace |
    When I go to the access system index page
    And I click on 'ContentDM'
    Then I should see all of:
      | Dogs | Cats | Collections | ContentDM |
    And I should not see 'Bats'

  Scenario: View collections associated with an access system as a user
    Given I relogin as a user
    Given the collection with title 'Dogs' has child access system with field name:
      | ContentDM |
    And the collection with title 'Cats' has child access systems with field name:
      | Dspace | ContentDM |
    And the collection with title 'Bats' has child access system with field name:
      | Dspace |
    When I go to the access system index page
    And I click on 'ContentDM'
    Then I should see all of:
      | Dogs | Cats | Collections | ContentDM |
    And I should not see 'Bats'
