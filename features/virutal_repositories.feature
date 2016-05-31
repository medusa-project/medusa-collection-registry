Feature: Virtual repositories
  In order to study subsets of a repository collection
  As a librarian
  I want to be able to select subsets of a repository and get stats on them

  Background:
    #Given the repository with title 'Animals' exists
    Given the repository with title 'Animals' has child collections with field title:
      | Dogs | Cats | Zebras |
    And the repository with title 'Animals' has child virtual repository with field title:
      | Pets |
    And the virtual repository with title 'Pets' has associated collections with title:
      | Dogs | Cats |
    And I am logged in as a manager

  Scenario: See virtual repositories belonging to a repository
    When I view the repository with title 'Animals'
    Then I should see 'Pets'

  Scenario: Navigate from repository to virtual repository
    When I view the repository with title 'Animals'
    And I click on 'Pets'
    Then I should be on the view page for the virtual repository with title 'Pets'

  Scenario: Navigate from virtual repository to repository
    When I view the virtual repository with title 'Pets'
    And I click on 'Animals'
    Then I should be on the view page for the repository with title 'Animals'

  Scenario: Create virtual repository from existing repository
    When I view the repository with title 'Animals'
    And I click on 'Add Virtual Repository'
    And I fill in fields:
      | Title | Wild |
    And I check 'Zebras'
    And I click on 'Create'
    Then I should be on the view page for the virtual repository with title 'Wild'
    And I should see all of:
      | Wild | Zebras |
    And I should see none of:
      | Cats | Dogs | Pets |

  Scenario: Edit virtual repository title
    When I edit the virtual repository with title 'Pets'
    And I fill in fields:
      | Title | Housepets |
    And I click on 'Update'
    Then I should be on the view page for the virtual repository with title 'Housepets'
    And I should see 'Housepets'
    And I should not see 'Pets'

  Scenario: Edit virtual repository collections
    When I edit the virtual repository with title 'Pets'
    And I uncheck 'Cats'
    And I check 'Zebras'
    And I click on 'Update'
    Then I should be on the view page for the virtual repository with title 'Pets'
    And I should see all of:
      | Dogs | Zebras |
    And I should not see 'Cats'

  Scenario: Virtual repository overview
    Given the collection with title 'Dogs' has child file group with fields:
      | type              | title  | total_file_size | total_files |
      | BitLevelFileGroup | Boxers | 1.3             | 123         |
    And the collection with title 'Cats' has child file group with fields:
      | type              | title            | total_file_size | total_files |
      | BitLevelFileGroup | Some kind of cat | 2.5             | 456         |
    When I view the virtual repository with title 'Pets'
    Then I should see the collections table
    And I should see all of:
      | 1.3 | 2.5 | 3.8 | 579 |

  Scenario: Virtual repository stats
    When PENDING

  Scenario: Virtual repository random sampler
    When PENDING

  Scenario: Destroy virtual repository
    When PENDING