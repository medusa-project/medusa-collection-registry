Feature: File Group related file groups
  In order to track information about file groups
  As a librarian
  I want to track relationships between various file groups

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection titled 'Dogs' has file groups with fields:
      | name              |
      | texts             |
      | access_images     |
      | production_images |
    And the collection titled 'Cats' has file groups with fields:
      | name       |
      | cat_images |

  Scenario: Editing a collection shows potential related file groups
    Given PENDING
    When I edit the file group named 'texts'
    Then I should see all of:
      | access_images | production_images |
    And I should not see 'texts' in the related file groups section
    And I should not see 'cat_images' in the related file groups section

  Scenario: Adding a related file group
    Given PENDING
    When I edit the file group named 'texts'
    And I check 'access_images'
    And I click on 'Update File group'
    Then I should see 'access_images'
    And I should not see 'production_images'
    And the file groups named 'texts' and 'access_images' should be related

  Scenario: Deleting a related file group
    Given PENDING
    And the file groups named 'texts' and 'access_images' are related
    When I edit the file group named 'texts'
    And I uncheck 'access_images'
    And I click on 'Update File group'
    Then I should not see 'access_images'
    And the file groups named 'texts' and 'access_images' should not be related

  Scenario: We can attach a comment to a related file group
    Given PENDING
    When I edit the file group named 'texts'
    And I check 'access_images'
    And I fill in fields:
      |Note|How these are related|
    And I click on 'Update File group'
    Then I should see 'How these are related'
    And the file groups named 'texts' and 'access_images' should have relation note 'How these are related'

