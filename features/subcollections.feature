Feature: Subcollections
  In order to group related content
  As a librarian
  I want to be able to record that some collections are subcollections of others

  Background:
    Given the repository with title 'Animals' has child collections with fields:
      | title  | id  |
      | Dogs   | 101 |
      | Cats   | 102 |
      | Toys   | 103 |
      | Hounds | 104 |
    And the repository with title 'Instruments' has child collections with field title:
      | Accordion | Stick |
    And the collection titled 'Dogs' has a subcollection titled 'Toys'

  Scenario: Add subcollection relationship between collections
    Given I am logged in as a manager
    When I edit the collection with title 'Dogs'
    And I check 'Hounds'
    And I click on 'Update'
    Then the collection titled 'Dogs' should have a subcollection titled 'Hounds'

  Scenario: Delete subcollection relationship between collections
    Given I am logged in as a manager
    When I edit the collection with title 'Dogs'
    And I uncheck 'Toys'
    And I click on 'Update'
    Then the collection titled 'Dogs' should not have a subcollection titled 'Toys'

  Scenario: No option to add collections from different repository
    Given I am logged in as a manager
    When I edit the collection with title 'Dogs'
    Then I should see none of:
      | Accordion | Stick |

  Scenario: See parent collections from child
    Given I am logged in as a manager
    When I view the collection with title 'Dogs'
    Then I should see 'Toys'
    And I should not see 'Hounds'

  Scenario: See child collections from parent
    Given I am logged in as a manager
    When I view the collection with title 'Toys'
    Then I should see 'Dogs'
    And I should not see 'Hounds'

  Scenario: See parent collections in child JSON
    Given I provide basic authentication
    When I view JSON for the collection with title 'Dogs'
    Then the JSON at "child_collection_ids" should have 1 entry
    And the JSON at "child_collection_ids/0" should be 103

  Scenario: See child collections in parent JSON
    Given I provide basic authentication
    When I view JSON for the collection with title 'Toys'
    Then the JSON at "parent_collection_ids" should have 1 entry
    And the JSON at "parent_collection_ids/0" should be 101

