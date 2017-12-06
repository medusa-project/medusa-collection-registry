Feature: Repository dashboard
  In order to have an overview of my repository
  As a librarian
  I want to have a dashboard for individual repositories

  Background:
    Given I am logged in as an admin
    And the repository with title 'Sample Repo' has child collections with fields:
      | title             | external_id |
      | Sample Collection | external_id |
      | Dogs              | dogtag      |
    And the collection with title 'Sample Collection' has child file groups with fields:
      | title    | total_file_size | total_files | type              |
      | examples | 10              | 100         | ExternalFileGroup |
      | stuff    | 20              | 200         | BitLevelFileGroup |
    And the collection with title 'Dogs' has child file groups with fields:
      | title  | total_file_size | total_files | type              |
      | Toys   | 30              | 444         | BitLevelFileGroup |
      | Hounds | 66              | 777         | BitLevelFileGroup |

  Scenario: Dashboard includes a collections table
    When I view the repository with title 'Sample Repo'
    Then I should see the collections table
    And I should see all of:
      | Sample Collection | external_id | 20 | 96 |

  Scenario: Navigate to collection from collections table
    When I view the repository with title 'Sample Repo'
    And I click on 'Sample Collection'
    Then I should be on the view page for the collection with title 'Sample Collection'

  Scenario: Dashboard includes an overall storage summary table
    When I view the repository with title 'Sample Repo'
    Then I should see the storage summary table
    And I should see all of:
      | 116 | 1,421 |

  @javascript
  Scenario: Dashboard includes running processes tables
    When I view the repository with title 'Sample Repo'
    And I click on 'Running Processes'
    Then I should see the running virus scans table
    And I should see the running fits scans table
    And I should see the running initial assessment scans table

  @javascript @poltergeist
  Scenario: Get CSV version of file statistics
    When I view the repository with title 'Sample Repo'
    And I click on 'File Statistics'
    And within '#file-statistics' I click on 'CSV'
    Then I should receive a file 'file-statistics.csv' of type 'text/csv'