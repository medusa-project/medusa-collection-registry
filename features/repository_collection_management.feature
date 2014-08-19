Feature: Collection Management
  In order to manage collections
  As a librarian
  I want to be able to create and delete collections from repositories

  Background:
    Given I am logged in as an admin
    And the repository with title 'Sample Repo' has child collections with fields:
      | title             | external_id |
      | Sample Collection | external_id |

  Scenario: View collections of a repository
    When I view the repository with title 'Sample Repo'
    Then I should see the repository collection table
    And I should see 'Sample Collection'
    And I should see 'external_id'

  Scenario: Delete collection from a repository
    When I view the repository with title 'Sample Repo'
    And I click on 'Delete' in the collections table
    Then I should be on the view page for the repository with title 'Sample Repo'
    And I should not see 'Sample Collection'

  Scenario: Navigate to collection
    When I view the repository with title 'Sample Repo'
    And I click on 'Sample Collection'
    Then I should be on the view page for the collection with title 'Sample Collection'
