Feature: Repository description
  In order to track information about repositories
  As a librarian
  I want to be able to create repositories and edit descriptive information about them

  Background:
    Given I am logged in
    And I have repositories with fields:
      | title    | notes            |
      | Sample 1 | Some notes       |
      | Sample 2 | Some other notes |

  Scenario: Create repository
    When I go to the repository creation page
    And I fill in fields:
      | Title | Sample Repo                              |
      | URL   | http://repo.example.com                  |
      | Notes | This is a sample repository for the test |
    And I press 'Create Repository'
    Then A repository with title 'Sample Repo' should exist
    And I should see 'This is a sample repository for the test'
    And I should see 'http://repo.example.com'

  Scenario: View all repository fields
    When I view the repository titled 'Sample 1'
    Then I should see all repository fields

  Scenario: Edit all repository fields
    When I edit the repository titled 'Sample 1'
    Then I should see all repository fields

  Scenario: View index
    When I go to the repository index page
    Then I should see 'Sample 1'
    And I should see 'Sample 2'

  Scenario: View repository
    When I view the repository titled 'Sample 1'
    Then I should see 'Sample 1'
    And I should see 'Some notes'

  Scenario: Edit repository
    When I edit the repository titled 'Sample 1'
    And I fill in fields:
      | Notes | New Notes Value |
    And I press 'Update Repository'
    Then I should see 'New Notes Value'
    And I should not see 'This is a sample repository for the test'

  Scenario: Delete repository from view page
    When I view the repository titled 'Sample 1'
    And I click on 'Delete Repository'
    Then I should not see 'Sample 1'

  Scenario: Navigate from index page to view page
    When I go to the repository index page
    And I click on 'Sample 1'
    Then I should be on the view page for the repository titled 'Sample 1'

  Scenario: Navigate from index page to edit page
    When I go to the repository index page
    And I click on 'Edit'
    Then I should be on the edit page for the repository titled 'Sample 1'

  Scenario: Delete from index page
    When I go to the repository index page
    And I click on 'Delete'
    Then I should be on the repository index page
    And I should not see 'Sample 1'

  Scenario: Create from index page
    When I go to the repository index page
    And I click on 'New Repository'
    Then I should be on the repository creation page

  Scenario: Navigate from view page to edit page
    When I view the repository titled 'Sample 1'
    And I click on 'Edit'
    Then I should be on the edit page for the repository titled 'Sample 1'

  Scenario: Associate contact with repository
    When I edit the repository titled 'Sample 1'
    And I fill in fields:
      | Contact Person Net ID | hding2 |
    And I press 'Update Repository'
    Then I should see 'hding2'
    And There should be a person with net ID 'hding2'