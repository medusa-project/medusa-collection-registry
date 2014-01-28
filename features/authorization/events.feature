Feature: Events authorization
  In order to protect event creation
  As the system
  I want to enforce restrict it to repository and medusa admins

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the collection titled 'Dogs' has file groups with fields:
      | external_file_location | file_format | total_file_size | total_files | summary          | provenance_note     | name   | staged_file_location |
      | Main Library           | image/jpeg  | 100             | 1200        | main summary     | main provenance     | images | staging_dir/images   |

  Scenario: Public user tries to create event for file group
    Then PENDING

  Scenario: Visitor tries to create event for file group
    Then PENDING