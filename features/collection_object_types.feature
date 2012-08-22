Feature: Collection Object types
  In order to facilitate preservation
  As a librarian
  I want to be able to track the types of objects in a collection

  Background:
    Given I am logged in
    And there are object types named:
      | Music | Artifacts | Periodicals | Newspapers |
    And the collection titled 'Dogs' has object types named:
      | Periodicals | Newspapers |

  Scenario: View object types
    When I view the collection titled 'Dogs'
    Then I should see all of:
      | Periodicals | Newspapers |
    And I should not see 'Music'

  Scenario: Edit object types
    When I edit the collection titled 'Dogs'
    And I uncheck object type 'Periodicals'
    And I check object type 'Music'
    And I click on 'Update Collection'
    Then I should see 'Music'
    And I should not see 'Periodicals'

  Scenario: Create new object type
    When I edit the collection titled 'Dogs'
    And I create an object type named 'Code type'
    Then there should be an object type named 'Code type'
    And I should see 'Code type'

  Scenario: Object types are seeded with common values
  #this is just a spot check - see seed file for all values
    Then there should be object types named:
      | Music (audio files) | Newspapers | Periodicals |


