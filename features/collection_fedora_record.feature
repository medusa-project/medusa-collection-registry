Feature: Persist collection record into Fedora
  In order to preserve collections
  As a librarian
  I want to store collection information as a Fedora object

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title | description          | private_description          |
      | Dogs  | Original description | Original private description |

  Scenario: Creating a collection creates a Fedora record with a MODS datastream
    Then The collection titled 'Dogs' should have a matching collection record in fedora

  Scenario: Modifying a collection field that changes the mods output updates a Fedora record
    When I edit the collection titled 'Dogs'
    And I fill in fields:
      | Description | New Description |
    And I click on 'Update Collection'
    Then The collection titled 'Dogs' should have 2 MODS versions in fedora

  Scenario: Modifying a collection field that does not change the mods output does not update the Fedora record
    When I edit the collection titled 'Dogs'
    And I fill in fields:
      | Private description | New private description |
    And I click on 'Update Collection'
    Then The collection titled 'Dogs' should have 1 MODS version in fedora

  Scenario: Destroying a collection should destroy its fedora collection record
    Given PENDING