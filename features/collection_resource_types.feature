Feature: Collection Resource types
  In order to facilitate preservation
  As a librarian
  I want to be able to track the types of resources in a collection

  Background:
    Given I am logged in as an admin
    And each resource type with name exists:
      | notated music | mixed material | text | cartographic |
    And the collection titled 'Dogs' has resource types named:
      | text | cartographic |

  Scenario: View resource types
    When I view the collection with title 'Dogs'
    Then I should see all of:
      | text | cartographic |
    And I should not see 'notated music'

  Scenario: Edit resource types
    When I edit the collection with title 'Dogs'
    And I uncheck resource type 'text'
    And I check resource type 'notated music'
    And I click on 'Update Collection'
    Then I should see 'notated music'
    And I should not see 'text'

  Scenario: Resource types are seeded with common values
  #this is just a spot check - see seed file for all values - note we need to use some not in the background
    Then each resource type with name should exist:
      | still image | moving image |


