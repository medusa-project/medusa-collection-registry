Feature: CFS basic properties
  In order to assess staged files
  As a librarian
  I want to have basic file properties found and stored

  Background:
    Given I am logged in as an admin
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
    And I clear the cfs root directory
    And the physical cfs directory 'dogs/toy-dogs' has a file 'stuff.txt' with contents 'Toy dog stuff'
    And the physical cfs directory 'dogs/toy-dogs/chihuahuas' has a file 'freakdog.xml' with contents '<?xml version="1.0" encoding="utf-8"?><freak>dog</freak>'
    And the file group named 'Toys' has cfs root 'dogs/toy-dogs'

  Scenario: When I do an initial assessment on a bit level file group there should be file objects with file properties
   # When I run an initial cfs file assessment on the file group named 'Toys'
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

