Feature: Project description
  In order to track ongoing digitization and content production projects
  As a librarian
  I want to create and edit descriptive information about projects

  Background:
    Given every project with fields exists:
      | title            | manager_email       | owner_email         | start_date | status    | specifications | summary          |
      | Book Scanning    | scanman@example.com | scanown@example.com | 2015-09-16 | active    | Scanning specs | Scanning summary |
      | Image Conversion | convman@example.com | convown@example.com | 2015-06-29 | completed | Image specs    | Image summary    |

  Scenario: Navigate to project index from header links
    Given I am logged in as a visitor
    When I go to the site home
    And I click on 'Projects'
    Then I should be on the projects index page

  Scenario: View index of projects
    Given I am logged in as a visitor
    When I go to the projects index page
    Then I should see all of:
      | scanman@example.com | scanown@example.com | convman@example.com | convown@example.com | 2015-09-16 | 2015-06-29 | active | completed |
    And I should see none of:
      | Scanning specs | Image specs | Scanning summary | Image summary |

  Scenario: Create project
    When PENDING

  Scenario: Edit and update project
    When PENDING

  Scenario: Delete project
    When PENDING

  Scenario: View project
    When PENDING

  Scenario: Navigate from index page to edit page
    When PENDING

  Scenario: Navigate from index page to view page
    When PENDING

  Scenario: CSV export of project table
    When PENDING

  Scenario: Enforce permissions
    When PENDING