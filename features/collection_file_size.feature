Feature: Collection File Size
  In order to manage preservation
  As a librarian
  I want to be able to see the total size of collections

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection titled 'Dogs' has file groups with fields:
      | total_file_size |
      | 10              |
      | 11              |
      | 35              |
    And the collection titled 'Cats' has file groups with fields:
      | total_file_size |
      | 500             |

  Scenario: Collection index should show file size
    When I go to the collection index page
    Then I should see 'Total Size (GB)'
    And I should see '56'
    And I should see '500'

  Scenario: Collection view page should show file size
    When I view the collection with title 'Dogs'
    Then I should see 'Total Size (GB)'
    And I should see '56'

  Scenario: Repository view page should show file size of collections
    When I view the repository with title 'Animals'
    Then I should see 'Size (GB)'
    And I should see '56'
    And I should see '500'

  Scenario: Repository view page should show file size over all collections
    When I view the repository with title 'Animals'
    Then I should see 'Total Size (GB)'
    And I should see '556'

  Scenario: Repository index page shows file size of repositories.
    When I go to the repository index page
    Then I should see 'Total Size (GB)'
    And I should see '556'


