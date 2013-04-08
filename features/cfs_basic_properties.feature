Feature: CFS basic properties
  In order to assess staged files
  As a librarian
  I want to have basic file properties found and stored

  Background:
    Given I am logged in as an admin
    And I clear the cfs root directory
    And there is a cfs directory 'dogs/toy-dogs'
    And the collection titled 'Dogs' has file groups with fields:
      | name |
      | Toys |
    And the cfs directory 'dogs/toy-dogs' has a file 'stuff.txt' with contents 'Toy dog stuff'

  Scenario: Setting CFS directory for a file group runs basic file properties on owned files
    When I set the cfs root of the file group named 'Toys' to 'dogs/toy-dogs'
    Then the cfs file 'dogs/toy-dogs/stuff.txt' should have size '13'
    And the cfs file 'dogs/toy-dogs/stuff.txt' should have content type 'text/plain'
    And the cfs file 'dogs/toy-dogs/stuff.txt' should have md5 sum '36dc5ffa0b229e9311cf0c4485b21a54'

  Scenario: When a file is removed from CFS we can remove its CfsFileInfo counterpart
    When I set the cfs root of the file group named 'Toys' to 'dogs/toy-dogs'
    And I remove the cfs path 'dogs/toy-dogs/stuff.txt'
    And I remove cfs orphan files under 'dogs/toy-dogs'
    Then there should not be cfs file info for 'dogs/toy-dogs/stuff.txt'
    

