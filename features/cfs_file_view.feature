Feature: Viewing CFS file information and content
  In order to work with bit level files
  As a librarian
  I want to be able to view cfs files through the interface

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the cfs directory 'dogs/places' contains cfs fixture file 'grass.jpg'
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs | BitLevelFileGroup |
    And the file group titled 'Dogs' has cfs root 'dogs/places' and delayed jobs are run

  Scenario: View cfs file
    Given the uuid of the cfs file with name 'grass.jpg' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    Then I should see all of:
      | grass.jpg | image/jpeg | b001b52b12fc80ef6145b7655de0b668 | 166 KB | 3da0fae0-e3fa-012f-ac10-005056b22849-8 |

  Scenario: Download cfs file
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should have downloaded the fixture file 'grass.jpg'

  Scenario: Download cfs file as a manager
    Given I relogin as a manager
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should have downloaded the fixture file 'grass.jpg'

  Scenario: View cfs file
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View'
    Then I should have viewed the fixture file 'grass.jpg'

  Scenario: View cfs file as a manager
    Given I relogin as a manager
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View'
    Then I should have viewed the fixture file 'grass.jpg'

  Scenario: Deny view to visitors
    Given I relogin as a visitor
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View'
    Then I should be unauthorized

  Scenario: Deny download to visitors
    Given I relogin as a visitor
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should be unauthorized

  Scenario: Deny download and view permissions to public and visitors
    Then deny object permission on the cfs file with name 'grass.jpg' to users for action with redirection:
      | public user | view, download | authentication |

  Scenario: Navigate to owning file group
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Dogs'
    Then I should be on the view page for the file group with title 'Dogs'

  Scenario: See red flags associated with file
    Given the file group titled 'Dogs' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message                          |
      | File format: incorrect extension |
      | File size: has changed           |
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    Then I should see all of:
      | File format: incorrect extension | File size: has changed |

  Scenario: Create FITS for file
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Create XML'
    Then the file group titled 'Dogs' should have a cfs file for the path 'grass.jpg' with fits attached
    And I should be viewing the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'

  Scenario: View FITS for file
    Given the cfs file at path 'grass.jpg' for the file group titled 'Dogs' has fits attached
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file at path 'grass.jpg' for the file group titled 'Dogs'