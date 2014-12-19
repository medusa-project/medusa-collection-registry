Feature: CFS basic properties
  In order to assess staged files
  As a librarian
  I want to have basic file properties found and stored

  Background:
    Given I am logged in as an admin
    And the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys | BitLevelFileGroup |
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'stuff.txt' with contents 'Toy dog stuff'
    And the physical cfs directory 'dogs/toy-dogs/chihuahuas' has a file 'freakdog.xml' with contents '<?xml version="1.0" encoding="utf-8"?><freak>dog</freak>'
    And the file group titled 'Toys' has cfs root 'dogs/toy-dogs' and delayed jobs are run

  Scenario: When I do an initial assessment on a bit level file group there should be file objects with file properties
    Then the file group titled 'Toys' should have a cfs file for the path 'stuff.txt' with results:
      | size              | 13.0                             |
      | name              | stuff.txt                        |
      | content_type_name | text/plain                       |
      | md5_sum           | 36dc5ffa0b229e9311cf0c4485b21a54 |
    And the file group titled 'Toys' should have a cfs file for the path 'chihuahuas/freakdog.xml' with results:
      | size              | 56.0                             |
      | name              | freakdog.xml                     |
      | content_type_name | application/xml                  |
      | md5_sum           | 9972d3c67a1155d5694c6647e1e2dafc |

  Scenario: When I remove a file and rerun assessments then the record for that file is deleted
    When I remove the cfs path 'dogs/toy-dogs/chihuahuas/freakdog.xml'
    And I run assessments on the the file group titled 'Toys'
    Then the file group titled 'Toys' should not have a cfs file for the path 'chihuahuas/freakdog.xml'

  Scenario: When I remove a directory and rerun assessments then the record for that directory and its files are deleted
    When I remove the cfs path 'dogs/toy-dogs/chihuahuas'
    And I run assessments on the the file group titled 'Toys'
    Then the file group titled 'Toys' should not have a cfs file for the path 'chihuahuas/freakdog.xml'
    And the file group titled 'Toys' should not have a cfs directory for the path 'chihuahuas'

  Scenario: When I modify a file and rerun assessments then the record for that file is updated
    When the physical cfs directory 'dogs/toy-dogs' has a file 'stuff.txt' with contents 'New toy dog stuff'
    And I run assessments on the the file group titled 'Toys'
    Then the file group titled 'Toys' should have a cfs file for the path 'stuff.txt' with results:
      | size              | 17.0                             |
      | name              | stuff.txt                        |
      | content_type_name | text/plain                       |
      | md5_sum           | 6c5f4abde7d78b28d17b6a7d0ec01fe2 |

  Scenario: When I add a file and rerun assessments then the record for that file is created; existing files are unchanged
    When the physical cfs directory 'dogs/toy-dogs/chihuahuas' has a file 'yappy.txt' with contents 'yap yap'
    And I run assessments on the the file group titled 'Toys'
    Then the file group titled 'Toys' should have a cfs file for the path 'chihuahuas/yappy.txt' with results:
      | size              | 7.0        |
      | name              | yappy.txt  |
      | content_type_name | text/plain |
    And the file group titled 'Toys' should have a cfs file for the path 'chihuahuas/freakdog.xml' with results:
      | size              | 56.0                             |
      | name              | freakdog.xml                     |
      | content_type_name | application/xml                  |
      | md5_sum           | 9972d3c67a1155d5694c6647e1e2dafc |

  Scenario: When I add a directory and rerun assessments then the record for that directory is created
    When the physical cfs directory 'dogs/toy-dogs/yorkies' has a file 'good.txt' with contents 'unfreakish'
    And I run assessments on the the file group titled 'Toys'
    Then the file group titled 'Toys' should have a cfs directory for the path 'yorkies'
    And the file group titled 'Toys' should have a cfs file for the path 'yorkies/good.txt' with results:
      | size         | 10.0       |
      | name         | good.txt   |
      | content_type_name | text/plain |

  Scenario: There is a button to press to set off an assessment if no current assessment is running for a file group
    When I view the file group with title 'Toys'
    And I click on 'Run Simple Assessment'
    Then the file group titled 'Toys' should have an assessment scheduled
    And I should see 'CFS simple assessment scheduled'

  Scenario: There is a no button to press to set off an assessment if a current assessment is scheduled for the file group
    When the file group titled 'Toys' has an assessment scheduled
    When I view the file group with title 'Toys'
    Then I should not see 'Run Simple Assessment'

  Scenario: There is no button to press to set off an assessment if a current assessment is scheduled for a directory in the file groups cfs tree
    When the cfs directory for the path 'chihuahuas' for the file group titled 'Toys' has an assessment scheduled
    When I view the file group with title 'Toys'
    Then I should not see 'Run Simple Assessment'

