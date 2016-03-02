Feature: Red flags
  In order to notice potential problems
  As a librarian
  I want to have the system automatically note potential file problems

  Background:
    Given I clear the cfs root directory
    And there is a physical cfs directory 'dogs'
    And the cfs directory 'dogs' contains cfs fixture file 'grass.jpg'
    And the collection with title 'Dogs' has child file groups with fields:
      | title    | type              |
      | pictures | BitLevelFileGroup |
    And the file group titled 'pictures' has cfs root 'dogs'

  Scenario: A file with basic properties but no FITS replaces the content-type without red flags
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with fields:
      | content_type_name |
      | text/plain   |
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' has fits attached
    Then the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have fields:
      | content_type_name |
      | image/jpeg   |
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have 0 red flags
    And the file group titled 'pictures' should have a cfs file for the path 'grass.jpg' with fits attached

  Scenario: A file with basic properties gets a red flag if size changes when FITS is run
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with fields:
      | size |
      | 100  |
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' has fits attached
    Then the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have 1 red flag
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have fields:
      | size   |
      | 169804.0 |

  Scenario: A file with basic properties gets a red flag if md5 sum changes when FITS is run
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with fields:
      | md5_sum |
      |   36dc5ffa0b229e9311cf0c4485b21a54 |
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' has fits attached
    Then the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have 1 red flag
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have fields:
      | md5_sum   |
      | b001b52b12fc80ef6145b7655de0b668 |

  Scenario: A file with FITS already run gets a red flag when content type, size, or md5 sum changes
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with fields:
      |fits_xml|content_type_name|size| md5_sum |
      |<fits/>|text/plain   |100 |   36dc5ffa0b229e9311cf0c4485b21a54 |
    And the cfs file at path 'grass.jpg' for the file group titled 'pictures' has fits rerun
    Then the cfs file at path 'grass.jpg' for the file group titled 'pictures' should have 3 red flags

  @javascript
  Scenario: A list of red flags is available in the dashboard
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       |
      | Size red flag |
      | Md5 red flag  |
    When I go to the dashboard
    And I click on 'Red Flags'
    Then I should see all of:
      | Size red flag | Md5 red flag | medium | flagged |

  Scenario: View a red flag
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    Then I should see all of:
      | Size red flag | The size is off | medium | flagged |

  Scenario: View a red flag as manager
    Given I am logged in as a manager
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    Then I should see all of:
      | Size red flag | The size is off | medium | flagged |

  Scenario: View a red flag as user
    Given I am logged in as a user
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    Then I should see all of:
      | Size red flag | The size is off | medium | flagged |

  Scenario: Navigate from red flag to owning object
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    And I click on 'grass.jpg'
    Then I should be viewing the cfs file for the file group titled 'pictures' for the path 'grass.jpg'

  Scenario: Edit red flag from its show view
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    And I click on 'Edit'
    And I fill in fields:
      | Notes | The size is really off |
    And I click on 'Update Red flag'
    Then I should see 'The size is really off'
    And I should not see 'The size is off'

  Scenario: Edit red flag from its show view as a manager
    Given I am logged in as a manager
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I view the first red flag for the file group titled 'pictures' for the cfs file for the path 'grass.jpg'
    And I click on 'Edit'
    And I fill in fields:
      | Notes | The size is really off |
    And I click on 'Update Red flag'
    Then I should see 'The size is really off'
    And I should not see 'The size is off'

  @javascript
  Scenario: Navigate from index to red flag view
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I go to the dashboard
    And I click on 'Red Flags'
    And I click on 'View' in the red flags table
    Then I should be viewing the first red flag for the file group titled 'pictures' for the path 'grass.jpg'

  @javascript
  Scenario: Navigate from index to red flag edit
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I go to the dashboard
    And I click on 'Red Flags'
    And I click on 'Edit' in the red flags table
    Then I should be editing the first red flag for the file group titled 'pictures' for the path 'grass.jpg'

  @javascript
  Scenario: Mark red flag as unflagged from index view
    Given I am logged in as an admin
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I go to the dashboard
    And I click on 'Red Flags'
    And I click on 'Unflag' in the red flags table
    Then I should be on the dashboard page
    And I should see 'unflagged'

  @javascript
  Scenario: Mark red flag as unflagged from index view as a manager
    Given I am logged in as a manager
    And the file group titled 'pictures' has a cfs file for the path 'grass.jpg' with red flags with fields:
      | message       | notes           |
      | Size red flag | The size is off |
    When I go to the dashboard
    And I click on 'Red Flags'
    And I click on 'Unflag' in the red flags table
    Then I should be on the dashboard page
    And I should see 'unflagged'
