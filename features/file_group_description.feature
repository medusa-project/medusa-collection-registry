Feature: File Group description
  In order to track information about file groups
  As a librarian
  I want to edit file group information

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | external_file_location | file_format | total_file_size | total_files | summary          | provenance_note     | name   | storage_level | staged_file_location |
      | Main Library           | image/jpeg  | 100             | 1200        | main summary     | main provenance     | images | external      | staging_dir/images   |
      | Grainger               | text/xml    | 4               | 2400        | grainger summary | grainger provenance | texts  | external      | staging_dir/texts    |

  Scenario: View a file group
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    Then I should see all of:
      | image/jpeg | 1200 | main summary | main provenance | images | external | staging_dir/images |

  Scenario: Edit a file group
    When I edit the file group with location 'Main Library' for the collection titled 'Dogs'
    And I fill in fields:
      | Total files          | 1300               |
      | Summary              | Changed summary    |
      | Provenance Note      | Changed provenance |
      | Name                 | pictures           |
      | Staged file location | staging_dir/pics   |
    And I select 'bit-level store' from 'Storage level'
    And I press 'Update File group'
    Then I should be on the view page for the file group with location 'Main Library' for the collection titled 'Dogs'
    And I should see all of:
      | 1300 | Changed summary | Changed provenance | pictures | bit-level store | staging_dir/pics |
    And I should see none of:
      | 1200 | main summary | main provenance | images | external | staging_dir/pictures |

  Scenario: Edit a file group and see owning repository and collection
    When I edit the file group with location 'Main Library' for the collection titled 'Dogs'
    Then I should see 'Dogs'
    And I should see 'Animals'

  Scenario: Navigate from the file group view page to owning collection
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: Navigate from file group view page to its edit page
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Edit'
    Then I should be on the edit page for the file group with location 'Main Library' for the collection titled 'Dogs'

  Scenario: Delete file group from view page
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Delete'
    Then I should be on the view page for the collection titled 'Dogs'
    And The collection titled 'Dogs' should not have a file group with location 'Main Library'

  Scenario: Create a new file group
    When I view the collection titled 'Dogs'
    And I click on 'Add File Group'
    And I fill in fields:
      | External file location | Undergrad     |
      | File format            | image/tiff    |
      | Total file size        | 22            |
      | Total files            | 333           |
      | Name                   | My file group |
    And I press 'Create File group'
    Then I should be on the view page for the file group with location 'Undergrad' for the collection titled 'Dogs'
    And I should see 'Undergrad'
    And I should see 'image/tiff'
    And The collection titled 'Dogs' should have a file group with location 'Undergrad'
    And the cfs root for the file group named 'My file group' should be nil

  Scenario: Navigate to root directory of file group if present
    Given The file group with location 'Main Library' has a root directory
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    And I click on 'Bit root directory'
    Then I should be on the view page for the root directory for the file group with location 'Main Library'

  Scenario: No link to root directory
    When I view the file group with location 'Main Library' for the collection titled 'Dogs'
    Then I should not see 'Bit root directory'

