Feature: Collection hide private fields
  In order to display the proper information about collections
  As the system
  I want to hide some fields unless a user is logged in

  Background:
    Given I am not logged in
    And the repository titled 'Animals' has collections with fields:
      | title | private_description | notes         |
      | dogs  | Private information | Private notes |

  Scenario: I view the dogs collection
    When I view the collection titled 'dogs'
    Then I should see none of:
      | Private information | Private notes |