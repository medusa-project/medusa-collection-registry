Feature: Events index
  In order to be able to see what has happened in Medusa
  As a librarian
  I want to be have an index of all medusa events

  Background:
    Given I am logged in as an admin
    And the file group named 'Dogs' has events with fields:
      | note          |
      | Current Event |
    And the file group named 'Dogs' has events with fields:
      | note      | updated_at |
      | Old Event | 2010-01-01 |

  Scenario: View index
    When I go to the event index page
    Then I should see all of:
      | Current Event | Old Event |

  Scenario: Public cannot view index
    Given I logout
    When I go to the event index page
    Then I should be on the login page