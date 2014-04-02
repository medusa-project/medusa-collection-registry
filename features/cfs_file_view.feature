Feature: Viewing CFS file information and content
  In order to work with bit level files
  As a librarian
  I want to be able to view cfs files through the interface

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And the cfs directory 'dogs/places' contains cfs fixture file 'grass.jpg'
    And the collection titled 'Animals' has file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
    And the file group named 'Dogs' has cfs root 'dogs/places'

  Scenario: View cfs file
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    Then I should see all of:
      | grass.jpg | image/jpeg | b001b52b12fc80ef6145b7655de0b668 | 166 KB |

  Scenario: Download cfs file
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'

  Scenario: View cfs file
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    And I click on 'View'

  Scenario: Navigate to owning file group
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    And I click on 'Dogs'
    Then I should be on the view page for the file group named 'Dogs'

  Scenario: See red flags associated with file
    Given the file group named 'Dogs' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message                          |
      | File format: incorrect extension |
      | File size: has changed           |
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    Then I should see all of:
      | File format: incorrect extension | File size: has changed |

  Scenario: Create FITS for file
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    And I click on 'Create XML'
    Then the file group named 'Dogs' should have a cfs file for the path 'grass.jpg' with fits attached
    And I should be viewing the cfs file for the file group named 'Dogs' for the path 'grass.jpg'

  Scenario: View FITS for file
    Given the cfs file at path 'grass.jpg' for the file group named 'Dogs' has fits attached
    When I view the cfs file for the file group named 'Dogs' for the path 'grass.jpg'
    And I click on 'View XML'
    Then I should be on the fits info page for the cfs file at path 'grass.jpg' for the file group named 'Dogs'