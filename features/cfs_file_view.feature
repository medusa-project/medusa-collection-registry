Feature: Viewing CFS file information and content
  In order to work with bit level files
  As a librarian
  I want to be able to view cfs files through the interface

  Background:
    Given I am logged in as an admin
    And the main storage directory key 'dogs/places' contains cfs fixture content 'grass.jpg'
    And every collection with fields exists:
      | title   | id |
      | Animals | 1  |
    And the collection with title 'Animals' has child file groups with fields:
      | title | type              |
      | Dogs  | BitLevelFileGroup |
    And the file group titled 'Dogs' has cfs root 'dogs/places' and delayed jobs are run

  Scenario: View cfs file
    Given the uuid of the cfs file with name 'grass.jpg' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    And the cfs file with name 'grass.jpg' has child fixity check results with fields:
      | status |
      | ok     |
      | bad    |
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    Then I should see all of:
      | grass.jpg | image/jpeg | b001b52b12fc80ef6145b7655de0b668 | 166 KB | 3da0fae0-e3fa-012f-ac10-005056b22849-8 |
    And I should see the fixity_check_results table
    And I should see all of:
      | ok | bad |

  Scenario: Download cfs file
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should have downloaded the fixture file 'grass.jpg'

  Scenario: Download cfs file as a manager
    Given I relogin as a manager
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should have downloaded the fixture file 'grass.jpg'

  Scenario: Download cfs file as a configured downloader
    Given I logout
    And I am logged in as 'joe_downloader_user@example.com'
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should have downloaded the fixture file 'grass.jpg'

  Scenario: Download cfs file as a basic auth user
    Given I logout
    And I provide basic authentication
    When I download the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
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

  Scenario: Deny view to users
    Given I relogin as a user
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View'
    Then I should be unauthorized

  Scenario: Deny download to users
    Given I relogin as a user
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'Download'
    Then I should be unauthorized

  Scenario: Deny download and view permissions to public and users
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
    And I click on 'Create FITS'
    Then the file group titled 'Dogs' should have a cfs file for the path 'grass.jpg' with fits attached
    And I should be viewing the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And the cfs file with name 'grass.jpg' should have fits data matching:
      | file_format              | JPEG File Interchange Format                              |
      | file_format_version      | 1.01                                                      |
      | file_size                | 169804.0                                                  |
      | creating_application     | CREATOR: gd-jpeg v1.0 (using IJG JPEG v62), quality = 100 |
      | well_formed              | true                                                      |
      | is_valid                 | true                                                      |
      | image_byte_order         | big endian                                                |
      | image_compression_scheme | JPEG                                                      |
      | image_color_space        | YCbCr                                                     |


  Scenario: View FITS for file
    Given the cfs file at path 'grass.jpg' for the file group titled 'Dogs' has fits attached
    When I view the cfs file for the file group titled 'Dogs' for the path 'grass.jpg'
    And I click on 'View' in the cfs file metadata
    Then I should be on the fits info page for the cfs file at path 'grass.jpg' for the file group titled 'Dogs'

  Scenario: Reset fixity/FITS information for a file
    Given the cfs file at path 'grass.jpg' for the file group titled 'Dogs' has fits attached
    When I reset fixity and FITS information for the cfs file named 'grass.jpg'
    Then the cfs file at path 'grass.jpg' for the file group titled 'Dogs' should have been fixity and fits reset
