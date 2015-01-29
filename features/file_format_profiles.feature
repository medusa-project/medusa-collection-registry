Feature: File Format Profiles
  In order to facilitate preservation
  As a librarian
  I want to be able to create and maintain profiles associating file types with preservation software

  Background:
    Given every file format profile with fields exists:
      | name   | software  | software_version | os_environment | os_version | notes              |
      | images | Fotostore | 1.2.3            | Linux          | 3.2        | Photo manipulation |
    And there are cfs directories with fields:
      | path |
      | root |
    And there are cfs files of the cfs directory with path 'root' with fields:
      | name          | size | content_type_name |
      | chihuahua.jpg | 567  | image/jpeg        |
      | pit_bull.xml  | 789  | application/xml   |
      | long_hair.JPG | 4000 | image/jpeg        |
    And I am logged in as an admin

  Scenario: Index of file format profiles
    When I go to the file format profiles index page
    Then I should see all of:
      | images | Fotostore | Linux | Photo manipulation |

  Scenario: Go from index of file format profiles to show view of one
    Given PENDING

  Scenario: Go from index of file format profiles to edit one
    Given PENDING

  Scenario: Go from show of file format profile to edit
    Given PENDING

  Scenario: Edit file format profile
    Given PENDING

  Scenario: Delete file format profile from show view
    Given PENDING

  Scenario: Delete file format profile from edit view
    Given PENDING

  Scenario: Go from show view back to index
    Given PENDING

  Scenario: Go from edit view back to index
    Given PENDING

  Scenario: Create file format profile from index
    Given PENDING