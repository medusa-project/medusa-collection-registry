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
      | key             | actor_email | action_date | state     |
      | external_to_bit | Buster@example.com      | 2012-02-02  | scheduled |
      | external_to_bit | Ruthie@example.com      | 2014-02-02  | completed |
    And the file group named 'Hot' has events with fields:
      | note       |
      | hot note 1 |
    And the file group named 'Hot' has scheduled events with fields:
      | key             | actor_email | action_date | state     |
      | external_to_bit | Oscar@example.com       | 2011-07-08  | scheduled |
    And the file group named 'Cool' has events with fields:
      | note        |
      | cool note 1 |
    And the file group named 'Cool' has scheduled events with fields:
      | key             | actor_email | action_date | state     |
      | external_to_bit | Coltrane@example.com    | 2011-09-10  | scheduled |
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
      | key             | actor_email | action_date | state     |
      | external_to_bit | delmonte@example.com    | 2010-10-11  | scheduled |

  Scenario: View collection events
    When I view the collection with title 'Dogs'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | Buster | Oscar |
    And I should see none of:
      | cool note 1 | corn note 1 | Coltrane | delmonte | Ruthie |

  Scenario: View collection events as a manager
    Given I relogin as a manager
    When I view the collection with title 'Dogs'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | Buster | Oscar |
    And I should see none of:
      | cool note 1 | corn note 1 | Coltrane | delmonte | Ruthie |

  Scenario: View collection events as a visitor
    Given I relogin as a visitor
    When I view the collection with title 'Dogs'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | Buster | Oscar |
    And I should see none of:
      | cool note 1 | corn note 1 | Coltrane | delmonte |


  Scenario: View repository events
    When I view the repository with title 'Animals'
    And I click on 'View events'
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | cool note 1 | Buster | Oscar | Coltrane |
    And I should see none of:
      | corn note 1 | delmonte | Ruthie |

  Scenario: View all events
    When I go to the dashboard
    Then I should see the events table
    And I should see all of:
      | toy note 1 | toy note 2 | hot note 1 | cool note 1 | Buster | Oscar | Coltrane | corn note 1 | delmonte | Dogs | Cats |
    And I should see none of:
      | Ruthie |