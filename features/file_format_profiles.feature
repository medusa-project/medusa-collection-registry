Feature: File Format Profiles
  In order to facilitate preservation
  As a librarian
  I want to be able to create and maintain profiles associating file types with preservation software

  Background:
    Given every file format profile with fields exists:
      | name   | software  | software_version | os_environment | os_version | notes              | status |
      | images | Fotostore | 1.2.3            | Linux          | 3.2        | Photo manipulation | active |
    And there are cfs directories with fields:
      | path |
      | root |
    And there are cfs files of the cfs directory with path 'root' with fields:
      | name          | size | content_type_name |
      | chihuahua.jpg | 567  | image/jpeg        |
      | pit_bull.xml  | 789  | application/xml   |
      | long_hair.JPG | 4000 | image/jpeg        |
    And I am logged in as an admin

  Scenario: Go to index from global nav
    When I go to the dashboard
    And I click on 'File Format Profiles'
    Then I should be on the file format profiles index page

  Scenario: Public can see file format profiles
    Given I logout
    When I go to the file format profiles index page
    Then I should be on the file format profiles index page

  Scenario: Index of file format profiles
    When I go to the file format profiles index page
    Then I should see all of:
      | images | Fotostore | (1.2.3) | Linux | (3.2) | active |

  Scenario: Go from index of file format profiles to show view of one
    When I go to the file format profiles index page
    And I click on 'images'
    Then I should be on the view page for the file format profile with name 'images'

  Scenario: View file format profile
    When I view the file format profile with name 'images'
    Then I should see all of:
      | images | Fotostore | 1.2.3 | Linux | 3.2 | Photo manipulation | active |

  Scenario: Go from index of file format profiles to edit one
    When I go to the file format profiles index page
    And I click on 'Edit'
    Then I should be on the edit page for the file format profile with name 'images'

  Scenario: Go from show of file format profile to edit|
    When I view the file format profile with name 'images'
    And I click on 'Edit'
    Then I should be on the edit page for the file format profile with name 'images'

  Scenario: Edit file format profile
    When I edit the file format profile with name 'images'
    And I fill in fields:
      | Name             | pictures         |
      | Software         | Picturemart      |
      | Software version | 4.5              |
      | OS environment   | Windows          |
      | OS version       | XP2000           |
      | Notes            | Picture changing |
    And I select 'inactive' from 'Status'
    And I click on 'Update'
    Then I should be on the view page for the file format profile with name 'pictures'
    Then I should see none of:
      | images | Fotostore | 1.2.3 | Linux | 3.2 | Photo manipulation |
    And I should see all of:
      | pictures | Picturemart | 4.5 | Windows | XP2000 | Picture changing | inactive |

  Scenario: Delete file format profile from edit view
    When I edit the file format profile with name 'images'
    And I click on 'Delete'
    Then I should be on the file format profiles index page
    And there should be no file format profile with name 'images'

  Scenario: Delete file format profile from edit view
    When I edit the file format profile with name 'images'
    And I click on 'Delete'
    Then I should be on the file format profiles index page
    And there should be no file format profile with name 'images'

  Scenario: Go from show view back to index
    When I view the file format profile with name 'images'
    And I click on 'Index'
    Then I should be on the file format profiles index page

  Scenario: Go from edit view back to index
    When I edit the file format profile with name 'images'
    And I click on 'Index'
    Then I should be on the file format profiles index page

  Scenario: Create file format profile from index
    When I go to the file format profiles index page
    And I click on 'Add File Format Profile'
    And I fill in fields:
      | Name             | pictures         |
      | Software         | Picturemart      |
      | Software version | 4.5              |
      | OS environment   | Windows          |
      | OS version       | XP2000           |
      | Notes            | Picture changing |
    And I click on 'Create'
    Then I should be on the view page for the file format profile with name 'pictures'
    And I should see all of:
      | pictures | Picturemart | 4.5 | Windows | XP2000 | Picture changing |

  Scenario: Associate with content types
    When I edit the file format profile with name 'images'
    And I check 'image/jpeg'
    And I click on 'Update'
    Then I should see 'image/jpeg'
    And I should not see 'application/xml'
    When I go to the file format profiles index page
    Then I should see 'image/jpeg'

  Scenario: Associate with file extensions
    When I edit the file format profile with name 'images'
    And I check 'jpg'
    And I check 'xml'
    And I click on 'Update'
    Then I should see all of:
      | jpg | xml |
    When I go to the file format profiles index page
    Then I should see all of:
      | jpg | xml |

  Scenario: Enforce permissions
    Then deny object permission on the file format profile with name 'images' to users for action with redirection:
      | public user      | view, edit, update, delete | authentication |
      | visitor, manager | view, edit, update, delete | unauthorized   |
    And deny permission on the file format profile collection to users for action with redirection:
      | public user      | new, create | authentication |
      | visitor, manager | new, create | unauthorized   |

  Scenario: Clone file format profile from index
    When I go to the file format profiles index page
    And I click on 'Clone'
    Then I should be on the edit page for the file format profile with name 'images (new)'

  Scenario: Clone file format profile from show
    When I view the file format profile with name 'images'
    And I click on 'Clone'
    Then I should be on the edit page for the file format profile with name 'images (new)'
