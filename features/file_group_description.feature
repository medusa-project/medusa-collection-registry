Feature: File Group description
  In order to track information about file groups
  As a librarian
  I want to edit file group information

  Background:
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
    And the collection with title 'Dogs' has child file groups with fields:
      | external_file_location | total_file_size | total_files | description      | provenance_note     | title  | staged_file_location | access_url                | acquisition_method  |
      | Main Library           | 100             | 1200        | main summary     | main provenance     | images | staging_dir/images   | http://access.example.com | vendor digitization |
      | Grainger               | 4               | 2400        | grainger summary | grainger provenance | texts  | staging_dir/texts    |                           |                     |
    And every producer with fields exists:
      | title    |
      | Scanning |

  Scenario: View a file group
    Given I am logged in as an admin
    And the uuid of the file group with title 'images' is '3da0fae0-e3fa-012f-ac10-005056b22849-8'
    When I view the file group with title 'images'
    Then I should see all of:
      | 1,200 | main summary | main provenance | images | external | staging_dir/images | 3da0fae0-e3fa-012f-ac10-005056b22849-8 | http://access.example.com | vendor digitization |

  Scenario: View a file group as a manager
    Given I am logged in as a manager
    When I view the file group with title 'images'
    Then I should be on the view page for the file group with title 'images'

  Scenario: View a file group as a user
    Given I am logged in as a user
    When I view the file group with title 'images'
    Then I should be on the view page for the file group with title 'images'

  Scenario: Edit a file group
    Given I am logged in as an admin
    When I edit the file group with title 'images'
    And I fill in fields:
      | Total files                                        | 1300                          |
      | Description                                        | Changed summary               |
      | Provenance Note                                    | Changed provenance            |
      | Title                                              | pictures                      |
      | Staged file location                               | staging_dir/pics              |
      | Access link (to digital content in another system) | http://new-access.example.com |
    And I select 'external deposit' from 'Acquisition method'
    And I press 'Update'
    Then I should be on the view page for the file group with title 'pictures'
    And I should see all of:
      | 1,300 | Changed summary | Changed provenance | pictures | staging_dir/pics | http://new-access.example.com | external deposit |
    And I should see none of:
      | 1,200 | main summary | main provenance | images | staging_dir/pictures | http://access.example.com | vendor digitization |

  Scenario: Edit a file group as a manager
    Given I am logged in as a manager
    When I edit the file group with title 'images'
    And I fill in fields:
      | Total files | 1300 |
    And I press 'Update'
    Then I should be on the view page for the file group with title 'images'
    And I should see all of:
      | 1,300 |
    And I should see none of:
      | 1,200 |

  Scenario: Edit a file group and see owning repository and collection
    Given I am logged in as an admin
    When I edit the file group with title 'images'
    Then I should see 'Dogs'
    And I should see 'Animals'

  Scenario: Navigate from the file group view page to owning collection
    Given I am logged in as an admin
    When I view the file group with title 'images'
    And I click on 'Dogs'
    Then I should be on the view page for the collection with title 'Dogs'

  Scenario: Navigate from file group view page to its edit page
    Given I am logged in as an admin
    When I view the file group with title 'images'
    And I click on 'Edit'
    Then I should be on the edit page for the file group with title 'images'

  Scenario: Delete file group from edit page
    Given I am logged in as a manager
    When I edit the file group with title 'images'
    And I click on 'Delete'
    Then I should be on the view page for the collection with title 'Dogs'
    And the collection with title 'Dogs' should have 0 file groups with title 'images'

  Scenario: Create a new file group as an admin
    Given I am logged in as an admin
    When I view the collection with title 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | External file location | Undergrad     |
      | Total file size        | 22            |
      | Total files            | 333           |
      | Title                  | My file group |
    And I select 'Scanning' from 'Producer'
    And I press 'Create'
    Then I should be on the view page for the file group with title 'My file group'
    And I should see 'Undergrad'
    And the collection with title 'Dogs' should have 1 file group with title 'My file group'
    And the file group with title 'My file group' should have an event with key 'created' performed by 'admin@example.com'
    And the cfs root for the file group titled 'My file group' should be nil

  Scenario: Create a new file group as a manager
    Given I am logged in as a manager
    When I view the collection with title 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | External file location | Undergrad     |
      | Total file size        | 22            |
      | Total files            | 333           |
      | Title                  | My file group |
    And I select 'Scanning' from 'Producer'
    And I press 'Create'
    Then I should be on the view page for the file group with title 'My file group'
    And I should see 'Undergrad'
    And the collection with title 'Dogs' should have 1 file group with title 'My file group'
    And the cfs root for the file group titled 'My file group' should be nil

  Scenario: See package profile name and url in collection view
    Given I am logged in as an admin
    Given every package profile with fields exists:
      | name          | url                              |
      | image_profile | http://image_profile.example.com |
    And the file group titled 'images' has package profile named 'image_profile'
    When I view the file group with title 'images'
    Then I should see all of:
      | image_profile | http://image_profile.example.com |

  Scenario: Navigate from file group view to corresponding package profile
    Given I am logged in as an admin
    Given the file group titled 'images' has package profile named 'image_profile'
    When I view the file group with title 'images'
    And I click on 'image_profile'
    Then I should be on the view page for the package profile with name 'image_profile'

  Scenario: Change package profile when editing file group
    Given I am logged in as an admin
    Given every package profile with fields exists:
      | name          |
      | image_profile |
      | book_profile  |
    And the file group titled 'images' has package profile named 'image_profile'
    When I edit the file group with title 'images'
    And I select 'book_profile' from 'Package profile'
    And I click on 'Update'
    Then the file group titled 'images' should have package profile named 'book_profile'
