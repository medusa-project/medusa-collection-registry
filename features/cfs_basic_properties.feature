Feature: CFS basic properties
  In order to assess staged files
  As a librarian
  I want to have basic file properties found and stored

  Background:
    Given I am logged in as an admin
    And the collection with title 'Dogs' has child file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'stuff.txt' with contents 'Toy dog stuff'
    And the physical cfs directory 'dogs/toy-dogs/chihuahuas' has a file 'freakdog.xml' with contents '<?xml version="1.0" encoding="utf-8"?><freak>dog</freak>'
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  Scenario: When I do an initial assessment on a bit level file group there should be file objects with file properties
    Then the file group named 'Toys' has a cfs file for the path 'stuff.txt' with results:
      | size         | 13.0                             |
      | name         | stuff.txt                        |
      | content_type | text/plain                       |
      | md5_sum      | 36dc5ffa0b229e9311cf0c4485b21a54 |
    And the file group named 'Toys' has a cfs file for the path 'chihuahuas/freakdog.xml' with results:
      | size         | 56.0                             |
      | name         | freakdog.xml                     |
      | content_type | application/xml                  |
      | md5_sum      | 9972d3c67a1155d5694c6647e1e2dafc |

  Scenario: When I remove a file and rerun assessments then the record for that file is deleted
    When I remove the cfs path 'dogs/toy-dogs/chihuahuas/freakdog.xml'
    And I run assessments on the the file group named 'Toys'
    Then the file group named 'Toys' should not have a cfs file for the path 'chihuahuas/freakdog.xml'

  Scenario: When I remove a directory and rerun assessments then the record for that directory and its files are deleted
    When I remove the cfs path 'dogs/toy-dogs/chihuahuas'
    And I run assessments on the the file group named 'Toys'
    Then the file group named 'Toys' should not have a cfs file for the path 'chihuahuas/freakdog.xml'
    And the file group named 'Toys' should not have a cfs directory for the path 'chihuahuas'

  Scenario: When I modify a file and rerun assessments then the record for that file is updated
    When PENDING

  Scenario: When I add a file and rerun assessments then the record for that file is created
    When PENDING

  Scenario: When I rerun assessments then the records for unchanged files are unchanged
    When PENDING

  Scenario: There is a button to press to set off an assessment if no current assessment is running for a file group's cfs dir
    When PENDING

  Scenario: There is a no button to press to set off an assessment if a current assessment is running for a file group's cfs dir
    When PENDING

  Scenario: There is a button to press for a root cfs directory if no current assessment is running for it
    When PENDING

  Scenario: There is no button to press for a root cfs directory if an assessment is running for it
    When PENDING

  Scenario: There is no button to press for a non-root cfs directory assessment
    When PENDING
