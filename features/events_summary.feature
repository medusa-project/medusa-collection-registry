Feature: Events Summary
  In order to track events
  As a librarian
  I want to be able to view events at a variety of levels

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys | BitLevelFileGroup |
      | Hot  | BitLevelFileGroup |
    And the collection with title 'Cats' has child file groups with fields:
      | title | type              |
      | Cool | BitLevelFileGroup |
    And the file group with title 'Toys' has events with fields:
      | note       |
      | toy note 1 |
      | toy note 2 |
    And the file group with title 'Hot' has events with fields:
      | note       |
      | hot note 1 |
    And the file group with title 'Cool' has events with fields:
      | note        |
      | cool note 1 |
    And the repository with title 'Plants' has child collections with fields:
      | title |
      | Crops |
    And the collection with title 'Crops' has child file groups with fields:
      | title | type              |
      | Corn | BitLevelFileGroup |
    And the file group with title 'Corn' has events with fields:
      | note        |
      | corn note 1 |

  Scenario: View collection events
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 |
    And I should see none of:
      | cool note 1 | corn note 1 |

  Scenario: View collection events as a manager
    Given I relogin as a manager
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 |
    And I should see none of:
      | cool note 1 | corn note 1 |

  Scenario: View collection events as a visitor
    Given I relogin as a visitor
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 |
    And I should see none of:
      | cool note 1 | corn note 1 |

  Scenario: Navigate from events list to owning object of an event
    When I view the collection with title 'Dogs'
    And I click on 'Events'
    And I click on 'Toys'
    Then I should be on the view page for the file group with title 'Toys'
    
  Scenario: View repository events
    When I view the repository with title 'Animals'
    And I click on 'Events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | cool note 1 |
    And I should see none of:
      | corn note 1|

  @javascript
  Scenario: View all events
    When I go to the dashboard
    And I click on 'Events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | cool note 1 | corn note 1  | Dogs | Cats |
