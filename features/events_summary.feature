Feature: Events Summary
  In order to track events
  As a librarian
  I want to be able to view events at a variety of levels

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
      | Hot  | BitLevelFileGroup |
    And the collection titled 'Cats' has file groups with fields:
      | name | type              |
      | Cool | BitLevelFileGroup |
    And the file group named 'Toys' has events with fields:
      | note       |
      | toy note 1 |
      | toy note 2 |
    And the file group named 'Toys' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_to_bit | Buster      | 2012-02-02  | scheduled |
    And the file group named 'Hot' has events with fields:
      | note       |
      | hot note 1 |
    And the file group named 'Hot' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_to_bit | Oscar       | 2011-07-08  | scheduled |
    And the file group named 'Cool' has events with fields:
      | note        |
      | cool note 1 |
    And the file group named 'Cool' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_to_bit | Coltrane    | 2011-09-10  | scheduled |
    And the repository titled 'Plants' has collections with fields:
      | title |
      | Crops |
    And the collection titled 'Crops' has file groups with fields:
      | name | type              |
      | Corn | BitLevelFileGroup |
    And the file group named 'Corn' has events with fields:
      | note        |
      | corn note 1 |
    And the file group named 'Corn' has scheduled events with fields:
      | key             | actor_netid | action_date | state     |
      | external_to_bit | Del Monte   | 2010-10-11  | scheduled |

  Scenario: View collection events
    When I view the collection titled 'Dogs'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | Buster | Oscar |
    And I should see none of:
      | cool note 1 | corn note 1 | Coltrane | Del Monte |

  Scenario: View repository events
    When I view the repository titled 'Animals'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | cool note 1 | Buster | Oscar | Coltrane |
    And I should see none of:
      | corn note 1 | Del Monte |
