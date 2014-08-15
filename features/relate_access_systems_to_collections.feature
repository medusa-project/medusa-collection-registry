Feature: Relate access systems to collections
  In order to manage preservation
  As a librarian
  I want to be able to record relationships between collections and access systems

  Background:
    Given I am logged in as an admin
    And There is a collection titled 'Dogs'
    And There are access systems named:
      | ContentDM | Dspace    | Olive     |

  Scenario: Set and view access systems for a collection
    When I edit the collection with title 'Dogs'
    And I check access system 'ContentDM'
    And I check access system 'Olive'
    And I press 'Update Collection'
    Then I should see 'ContentDM'
    And I should see 'Olive'
    And The collection titled 'Dogs' should have 2 access systems
    And The collection titled 'Dogs' should have access system named 'ContentDM'
    And The collection titled 'Dogs' should have access system named 'Olive'