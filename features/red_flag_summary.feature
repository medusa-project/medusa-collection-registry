Feature: Red Flag Summary
  In order to track problem items
  As a librarian
  I want to be able to view red flags at a variety of levels

  Background:
    Given the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection with title 'Dogs' has child file groups with fields:
      | title | type              |
      | Toys  | BitLevelFileGroup |
      | Hot   | BitLevelFileGroup |
    And the collection with title 'Cats' has child file groups with fields:
      | title | type              |
      | Cool  | BitLevelFileGroup |
    And the main storage has a directory key 'dogs/toys' containing a file
    And the main storage has a directory key 'dogs/hot' containing a file
    And the main storage has a directory key 'cats/cool' containing a file
    And the file group titled 'Toys' has cfs root 'dogs/toys'
    And the file group titled 'Hot' has cfs root 'dogs/hot'
    And the file group titled 'Cool' has cfs root 'cats/cool'
    And the file group titled 'Toys' has a cfs file for the path 'pic.jpg' with red flags with fields:
      | message         |
      | Bad toy picture |
      | Bad checksum    |
    And the file group titled 'Toys' has a cfs file for the path 'text.pdf' with red flags with fields:
      | message      |
      | Bad toy text |
    And the file group titled 'Hot' has a cfs file for the path 'pic.jpg' with red flags with fields:
      | message         |
      | Bad hot picture |
    And the file group titled 'Cool' has a cfs file for the path 'text.pdf' with red flags with fields:
      | message       |
      | Bad cool text |

  Scenario: View red flags for file group
    Given I am logged in as an admin
    When I view the file group with title 'Toys'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Toys |
    And I should see none of:
      | Bad hot picture | Bad cool text |

  Scenario: View red flags for file group as a manager
    Given I am logged in as a manager
    When I view the file group with title 'Toys'
    And I click on 'Red Flags'
    Then I should see the red flags table

  Scenario: View red flags for file group as a user
    Given I am logged in as a user
    When I view the file group with title 'Toys'
    And I click on 'Red Flags'
    Then I should see the red flags table

  Scenario: View red flags for collection
    Given I am logged in as an admin
    When I view the collection with title 'Dogs'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for collection as a manager
    Given I am logged in as a manager
    When I view the collection with title 'Dogs'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for collection as a user
    Given I am logged in as a user
    When I view the collection with title 'Dogs'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for repository
    Given I am logged in as an admin
    When I view the repository with title 'Animals'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals |

  Scenario: View red flags for repository as a manager
    Given I am logged in as a manager
    When I view the repository with title 'Animals'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals |

  Scenario: View red flags for repository as a user
    Given I am logged in as a user
    When I view the repository with title 'Animals'
    And I click on 'Red Flags'
    Then I should see the red flags table
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals |
