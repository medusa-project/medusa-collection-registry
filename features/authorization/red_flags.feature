Feature: Red flags authorization
  In order to protect the red flags
  As the system
  I want to enforce proper authorization

  Background:
    Given I clear the cfs root directory
    And there is a physical cfs directory 'dogs'
    And the cfs directory 'dogs' contains cfs fixture file 'grass.jpg'
    And the collection with title 'Dogs' has child file groups with fields:
      | name     | type              |
      | pictures | BitLevelFileGroup |
    And I set the cfs root of the file group named 'pictures' to 'dogs'
    And the file group named 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |

  Scenario: Enforce permissions
    Then deny object permission on the red flag with message 'Size red flag' to users for action with redirection:
      | public user | view, edit, update, unflag(post) | authentication |
      | visitor     | edit, update, unflag(post)       | unauthorized  |

