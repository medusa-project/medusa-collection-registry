Feature: Project description
  In order to track ongoing digitization and content production projects
  As a librarian
  I want to create and edit descriptive information about projects

  Background:
    Given every project with fields exists:
      | title            | manager_email       | owner_email         | start_date | status    | specifications | summary          | external_id |
      | Book Scanning    | scanman@example.com | scanown@example.com | 2015-09-16 | active    | Scanning specs | Scanning summary | Buch001    |
      | Image Conversion | convman@example.com | convown@example.com | 2015-06-29 | completed | Image specs    | Image summary    | Bild002    |

  Scenario: Navigate to project index from header links
    Given I am logged in as a user
    When I go to the site home
    And I click on 'Projects'
    Then I should be on the project index page

  Scenario: View index of projects
    Given I am logged in as a user
    When I go to the project index page
    Then I should see all of:
      | scanman@example.com | scanown@example.com | convman@example.com | convown@example.com | 2015-09-16 | 2015-06-29 | active | completed | Buch001 | Bild002 |
    And I should see none of:
      | Scanning specs | Image specs | Scanning summary | Image summary |

  Scenario: Get CSV dump of all projects
    Given I am logged in as a user
    When I go to the project index page
    And I click on 'CSV'
    Then I should receive a file 'projects.csv' of type 'text/csv' matching:
      | Book Scanning | scanman@example.com | scanown@example.com | 2015-09-16 | active | Scanning specs | Scanning summary | Image Conversion | convman@example.com | convown@example.com | 2015-06-29 | completed | Image specs | Image summary | Buch001 | Bild002 |

  Scenario: Create project
    Given I am logged in as an admin
    And the collection with title 'Dogs' exists
    When I view the collection with title 'Dogs'
    And I click on 'Add Project'
    And I fill in fields:
      | Title          | Audio                            |
      | Manager email  | audioman@example.com             |
      | Owner email    | audioowner@example.com           |
      | Start date     | 2015-09-15                       |
      | Specifications | Audio conversion specs           |
      | Summary        | Audio conversion project summary |
      | External id    | Klingen003                       |
    And I select 'inactive' from 'Status'
    And I click on 'Create'
    And I should be on the view page for the project with title 'Audio'
    And I should see all of:
      | Audio | audioman@example.com | audioowner@example.com | 2015-09-15 | inactive | Audio conversion specs | Audio conversion project summary | Klingen003 |
    And the collection with title 'Dogs' should have 1 project with title 'Audio'

  Scenario: Edit and update project
    Given I am logged in as an admin
    When I edit the project with title 'Image Conversion'
    And I fill in fields:
      | Specifications | New specs  |
      | Start date     | 2017-01-04 |
    And I select 'active' from 'Status'
    And I click on 'Update'
    Then I should see all of:
      | New specs | 2017-01-04 | active |
    And I should see none of:
      | 2015-06-29 | completed | Image specs |

  Scenario: Delete project
    Given I am logged in as an admin
    When I edit the project with title 'Book Scanning'
    And I click on 'Delete'
    Then I should be on the project index page
    And I should not see 'Book Scanning'

  Scenario: View project
    Given I am logged in as a user
    When I view the project with title 'Book Scanning'
    Then I should see all of:
      | Book Scanning | scanman@example.com | scanown@example.com | 2015-09-16 | active | Scanning specs | Scanning summary | Buch001 |

  Scenario: Navigate from index page to edit page
    Given I am logged in as an admin
    When I go to the project index page
    And I click on 'Edit'
    Then I should be on the edit page for the project with title 'Book Scanning'

  Scenario: Navigate from index page to view page
    Given I am logged in as a user
    When I go to the project index page
    And I click on 'Book Scanning'
    Then I should be on the view page for the project with title 'Book Scanning'
