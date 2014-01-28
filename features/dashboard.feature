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

  Scenario: View the dashboard as a visitor
    Given I am logged in as a visitor
    When I go to the dashboard
    Then I should be on the dashboard page

  Scenario: External storage summary table
    Given I am logged in as an admin
    When I go to the dashboard
    Then The dashboard should have an external storage table

  Scenario: External storage summary
    Given I am logged in as an admin
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection titled 'Dogs' has file groups with fields:
      | name   | total_files | total_file_size | type              |
      | Hounds | 1000        | 10              | ExternalFileGroup |
      | Toys   | 2000        | 20              | ExternalFileGroup |
    And the collection titled 'Cats' has file groups with fields:
      | name     | total_files | total_file_size | type              |
      | Wild     | 10000       | 100             | ExternalFileGroup |
      | Domestic | 20000       | 200             | ExternalFileGroup |
      | Musical  | 40000       | 400             | BitLevelFileGroup |
    Given the repository titled 'Computers' has collections with fields:
      | title   |
      | Laptops |
    And the collection titled 'Laptops' has file groups with fields:
      | name  | total_files | total_file_size | type              |
      | Dells | 500         | 50              | ExternalFileGroup |
    When I go to the dashboard
    Then I should see all of:
      | 33000 | 330.0 | Animals | 500 | 50.0 | Computers | 33500 | 380.0 |



