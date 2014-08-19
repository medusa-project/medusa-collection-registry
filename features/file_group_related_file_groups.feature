Feature: File Group related file groups
  In order to track information about file groups
  As a librarian
  I want to track relationships between various file groups

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection with title 'Dogs' has child file groups with fields:
      | name              | type                 |
      | texts             | ExternalFileGroup    |
      | access_images     | BitLevelFileGroup    |
      | production_images | ObjectLevelFileGroup |
    And the collection with title 'Cats' has child file groups with fields:
      | name       | type                 |
      | cat_images | ObjectLevelFileGroup |

  Scenario: Editing a file group shows potential related file groups
    When I edit the file group with name 'texts'
    Then I should see all of:
      | access_images | production_images |
    And I should not see 'texts' in the related file groups section
    And I should not see 'cat_images' in the related file groups section

  Scenario: Editing a file group does not show file groups lower on the ingest path
    When I edit the file group with name 'access_images'
    Then I should see 'production_images'
    And I should not see 'texts' in the related file groups section

  Scenario: Adding a related file group
    When I edit the file group with name 'texts'
    And I check 'access_images'
    And I click on 'Update File group'
    Then I should see 'access_images'
    And I should not see 'production_images'
    And the file group with name 'texts' should have 1 target file group with name 'access_images'

  Scenario: Deleting a related file group
    And the file group named 'texts' has a target file group named 'access_images'
    When I edit the file group with name 'texts'
    And I uncheck 'access_images'
    And I click on 'Update File group'
    Then I should not see 'access_images'
    And the file group with name 'texts' should have 0 target file groups with name 'access_images'

  Scenario: We can attach a comment to a related file group
    When I edit the file group with name 'texts'
    And I check 'access_images'
    And I fill in fields:
      | Note | How these are related |
    And I click on 'Update File group'
    Then I should see 'How these are related'
    And the file group named 'texts' should have relation note 'How these are related' for the target file group 'access_images'

