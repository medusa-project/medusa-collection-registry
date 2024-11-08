Feature: Collection Registry Dashboard
  In order to view a summary of collection registry wide information
  As a librarian
  I want to have a dashboard view that shows it

  Scenario: Dashboard sections are present
    Given I am logged in as an admin
    When I go to the dashboard
    Then The dashboard should have a storage overview section
    And The dashboard should have a running processes section
    And The dashboard should have a file statistics section
    And The dashboard should have a red flags section

  Scenario: View the dashboard as a user
    Given I am logged in as a user
    When I go to the dashboard
    Then I should be on the dashboard page

  Scenario: Storage summary table
    Given I am logged in as an admin
    When I go to the dashboard
    Then I should see the storage summary table

  Scenario: Storage summary
    Given I am logged in as an admin
    Given the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title  | total_files | total_file_size | type              |
      | Hounds | 1000        | 10              | ExternalFileGroup |
      | Toys   | 2000        | 20              | ExternalFileGroup |
    And the collection with title 'Cats' has child file groups with fields:
      | title    | total_files | total_file_size | type              |
      | Wild     | 10000       | 100             | ExternalFileGroup |
      | Domestic | 20000       | 200             | BitLevelFileGroup |
      | Musical  | 40000       | 400             | BitLevelFileGroup |
    Given the repository with title 'Computers' has child collections with fields:
      | title   |
      | Laptops |
    And the collection with title 'Laptops' has child file groups with fields:
      | title | total_files | total_file_size | type              |
      | Dells | 500         | 70              | BitLevelFileGroup |
    When I go to the dashboard
    Then I should see all of:
      | 60,000 | 600 | Animals | 500 | 70 | Computers | 60,500 | 670 |



