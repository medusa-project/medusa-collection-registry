Feature: Record structured rights data for collections and file groups
  In order to follow proper legal procedures and correctly restrict access
  As a librarian
  I want to be able to assign rights properties to collections and file groups

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | file_location |
      | Grainger      |

  Scenario: Every collection should have rights attached
    Then the collection titled 'Dogs' should have rights attached

  Scenario: Every file group should have rights attached
    Then The file group with location 'Grainger' for the collection titled 'Dogs' should have rights attached