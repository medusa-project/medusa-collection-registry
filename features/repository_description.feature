Feature: Repository description
  In order to track information about repositories
  As a librarian
  I want to be able to create repositories and edit descriptive information about them

  Background:
    Given the institution with name 'UIUC' has child repositories with fields:
      | title    | notes                                                     |
      | Sample 1 | Some notes                                                |
      | Sample 2 | Some other notes. http://animals.example.com. More notes. |

  Scenario: Create repository
    Given I am logged in as an admin
    When I view the institution with name 'UIUC'
    And I click on 'Create Repository'
    And I fill in fields:
      | Title | Sample Repo                              |
      | URL   | http://repo.example.com                  |
      | Notes | This is a sample repository for the test |
    And I press 'Create Repository'
    And the institution with name 'UIUC' should have 1 repository with title 'Sample Repo'
    And I should see 'This is a sample repository for the test'
    And I should see 'http://repo.example.com'

  Scenario: View all repository fields
    Given I am logged in as an admin
    When I view the repository with title 'Sample 1'
    Then I should see all repository fields

  Scenario: Edit all repository fields
    Given I am logged in as an admin
    When I edit the repository with title 'Sample 1'
    Then I should see all repository fields

  Scenario: View index
    Given I am logged in as an admin
    When I go to the repository index page
    Then I should see 'Sample 1'
    And I should see 'Sample 2'
    And I should see the repository definition

  Scenario: View index as a manager
    Given I am logged in as a manager
    When I go to the repository index page
    Then I should be on the repository index page

  Scenario: View index as a visitor
    Given I am logged in as a visitor
    When I go to the repository index page
    Then I should be on the repository index page

  Scenario: Get CSV list of all repositories
    Given I am logged in as a visitor
    When I go to the repository index page
    And I click on 'CSV'
    Then I should receive a file 'repositories.csv' of type 'text/csv' matching:
      | Sample 1 | Some notes | Sample 2 | Some other notes. http://animals.example.com. More notes. |

  Scenario: View repository
    Given I am logged in as an admin
    When I view the repository with title 'Sample 1'
    Then I should see 'Sample 1'
    And I should see 'Some notes'

  Scenario: View repository as a manager
    Given I am logged in as a manager
    When I view the repository with title 'Sample 1'
    Then I should be on the view page for the repository with title 'Sample 1'

  Scenario: View repository as a visitor
    Given I am logged in as a visitor
    When I view the repository with title 'Sample 1'
    Then I should be on the view page for the repository with title 'Sample 1'

  Scenario: Edit repository
    Given I am logged in as an admin
    When I edit the repository with title 'Sample 1'
    And I fill in fields:
      | Notes | New Notes Value |
    And I press 'Update Repository'
    Then I should see 'New Notes Value'
    And I should not see 'This is a sample repository for the test'

  Scenario: Edit repository as a manager
    Given I am logged in as a manager
    When I edit the repository with title 'Sample 1'
    And I fill in fields:
      | Notes | New Notes Value |
    And I press 'Update Repository'
    Then I should see 'New Notes Value'
    And I should not see 'This is a sample repository for the test'

  Scenario: Edit repository show definition
    Given I am logged in as an admin
    When I edit the repository with title 'Sample 1'
    Then I should see the repository definition

  Scenario: Delete repository from edit page
    Given I am logged in as an admin
    When I edit the repository with title 'Sample 1'
    And I click on 'Delete'
    Then I should not see 'Sample 1'

  Scenario: Navigate from index page to view page
    Given I am logged in as an admin
    When I go to the repository index page
    And I click on 'Sample 1'
    Then I should be on the view page for the repository with title 'Sample 1'

  Scenario: Navigate from index page to edit page
    Given I am logged in as an admin
    When I destroy the repository with title 'Sample 2'
    And I go to the repository index page
    And I click on 'Edit'
    Then I should be on the edit page for the repository with title 'Sample 1'

  Scenario: Navigate from view page to edit page
    Given I am logged in as an admin
    When I view the repository with title 'Sample 1'
    And I click on 'Edit'
    Then I should be on the edit page for the repository with title 'Sample 1'

  Scenario: Navigate from view page to institution
    Given I am logged in as an admin
    When I view the repository with title 'Sample 1'
    And I click on 'UIUC'
    Then I should be on the view page for the institution with name 'UIUC'

  Scenario: Associate contact with repository
    Given I am logged in as an admin
    When I edit the repository with title 'Sample 1'
    And I fill in fields:
      | Contact Person Email | hding2@example.com |
    And I press 'Update Repository'
    Then I should see 'hding2@example.com'
    And a person with email 'hding2@example.com' should exist

  Scenario: Automatically convert things that look like links in notes to links in show view
    Given I am logged in as an admin
    When I view the repository with title 'Sample 2'
    Then I should see a link to 'http://animals.example.com'