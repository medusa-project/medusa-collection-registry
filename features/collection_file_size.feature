Feature: Collection File Size
  In order to manage preservation
  As a librarian
  I want to be able to see the total size of collections

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection with title 'Dogs' has child file groups with fields:
      | total_file_size | type              |
      | 10              | BitLevelFileGroup |
      | 11              | BitLevelFileGroup |
      | 35              | BitLevelFileGroup |
    And the collection with title 'Cats' has child file groups with fields:
      | total_file_size | type              |
      | 500             | BitLevelFileGroup |

  Scenario: Collection index should show file size
    When I go to the collection index page
    And I should see '56'
    And I should see '500'

  Scenario: Collection view page should show file size
    When I view the collection with title 'Dogs'
    And I should see '56'

  Scenario: Repository view page should show file size of collections
    When I view the repository with title 'Animals'
    Then I should see 'Size (GB)'
    And I should see '56'
    And I should see '500'

  Scenario: Repository view page should show file size over all collections
    When I view the repository with title 'Animals'
    And I should see '556'

  Scenario: Repository index page shows file size of repositories.
    When I go to the repository index page
    And I should see '556'


