Feature: File Group description
  In order to track information about file groups
  As a librarian
  I want to edit file group information

  Background:
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | file_format | total_file_size | total_files | summary          | provenance_note     | name   | staged_file_location | external_id              |
      | Main Library           | image/jpeg  | 100             | 1200        | main summary     | main provenance     | images | staging_dir/images   | external-main-library-id |
      | Grainger               | text/xml    | 4               | 2400        | grainger summary | grainger provenance | texts  | staging_dir/texts    |                          |
    And every producer with fields exists:
      | title    |
      | Scanning |

  Scenario: View a file group
    Given I am logged in as an admin
    When I view the file group with name 'images'
    Then I should see all of:
      | image/jpeg | 1,200 | main summary | main provenance | images | external | staging_dir/images | external-main-library-id |

  Scenario: View a file group as a manager
    Given I am logged in as a manager
    When I view the file group with name 'images'
    Then I should be on the view page for the file group with name 'images'

  Scenario: View a file group as a visitor
    Given I am logged in as a visitor
    When I view the file group with name 'images'
    Then I should be on the view page for the file group with name 'images'

  Scenario: Edit a file group
    Given I am logged in as an admin
    When I edit the file group with name 'images'
    And I fill in fields:
      | Total files          | 1300               |
      | Summary              | Changed summary    |
      | Provenance Note      | Changed provenance |
      | Name                 | pictures           |
      | Staged file location | staging_dir/pics   |
      | External ID          | external-dogs-id   |
    And I press 'Update File group'
    Then I should be on the view page for the file group with name 'pictures'
    And I should see all of:
      | 1,300 | Changed summary | Changed provenance | pictures | staging_dir/pics | external-dogs-id |
    And I should see none of:
      | 1,200 | main summary | main provenance | images | staging_dir/pictures | external-main-library-id |

  Scenario: Edit a file group as a manager
    Given I am logged in as a manager
    When I edit the file group with name 'images'
    And I fill in fields:
      | Total files | 1300 |
    And I press 'Update File group'
    Then I should be on the view page for the file group with name 'images'
    And I should see all of:
      | 1,300 |
    And I should see none of:
      | 1,200 |

  Scenario: Edit a file group and see owning repository and collection
    Given I am logged in as an admin
    When I edit the file group with name 'images'
    Then I should see 'Dogs'
    And I should see 'Animals'

  Scenario: Navigate from the file group view page to owning collection
    Given I am logged in as an admin
    When I view the file group with name 'images'
    And I click on 'Dogs'
    Then I should be on the view page for the collection with title 'Dogs'

  Scenario: Navigate from file group view page to its edit page
    Given I am logged in as an admin
    When I view the file group with name 'images'
    And I click on 'Edit'
    Then I should be on the edit page for the file group with name 'images'

  Scenario: Delete file group from view page
    Given I am logged in as an admin
    When I view the file group with name 'images'
    And I click on 'Delete'
    Then I should be on the view page for the collection with title 'Dogs'
    And the collection with title 'Dogs' should have 0 file groups with name 'images'

  Scenario: Create a new file group as an admin
    Given I am logged in as an admin
    When I view the collection with title 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | External file location | Undergrad     |
      | File format            | image/tiff    |
      | Total file size        | 22            |
      | Total files            | 333           |
      | Name                   | My file group |
    And I select 'Scanning' from 'Producer'
    And I press 'Create File group'
    Then I should be on the view page for the file group with name 'My file group'
    And I should see 'Undergrad'
    And I should see 'image/tiff'
    And the collection with title 'Dogs' should have 1 file group with name 'My file group'
    And the cfs root for the file group named 'My file group' should be nil

  Scenario: Create a new file group as a manager
    Given I am logged in as a manager
    When I view the collection with title 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | External file location | Undergrad     |
      | File format            | image/tiff    |
      | Total file size        | 22            |
      | Total files            | 333           |
      | Name                   | My file group |
    And I select 'Scanning' from 'Producer'
    And I press 'Create File group'
    Then I should be on the view page for the file group with name 'My file group'
    And I should see 'Undergrad'
    And I should see 'image/tiff'
    And the collection with title 'Dogs' should have 1 file group with name 'My file group'
    And the cfs root for the file group named 'My file group' should be nil

  Scenario: See package profile name and url in collection view
    Given I am logged in as an admin
    Given every package profile with fields exists:
      | name          | url                              |
      | image_profile | http://image_profile.example.com |
    And the file group named 'images' has package profile named 'image_profile'
    When I view the file group with name 'images'
    Then I should see all of:
      | image_profile | http://image_profile.example.com |

  Scenario: Navigate from file group view to corresponding package profile
    Given I am logged in as an admin
    Given the file group named 'images' has package profile named 'image_profile'
    When I view the file group with name 'images'
    And I click on 'image_profile'
    Then I should be on the view page for the package profile with name 'image_profile'

  Scenario: Change package profile when editing file group
    Given I am logged in as an admin
    Given every package profile with fields exists:
      | name          |
      | image_profile |
      | book_profile  |
    And the file group named 'images' has package profile named 'image_profile'
    When I edit the file group with name 'images'
    And I select 'book_profile' from 'Package profile'
    And I click on 'Update File group'
    Then the file group named 'images' should have package profile named 'book_profile'
