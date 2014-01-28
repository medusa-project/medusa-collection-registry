Feature: Red Flag Summary
  In order to track problem items
  As a librarian
  I want to be able to view red flags at a variety of levels

  Background:
    Given the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the collection titled 'Dogs' has file groups with fields:
      | name | type              |
      | Toys | BitLevelFileGroup |
      | Hot  | BitLevelFileGroup |
    And the collection titled 'Cats' has file groups with fields:
      | name | type              |
      | Cool | BitLevelFileGroup |
    And the file group named 'Toys' has cfs root 'dogs/toys'
    And the file group named 'Hot' has cfs root 'dogs/hot'
    And the file group named 'Cool' has cfs root 'cats/cool'
    And the cfs file info for the path 'dogs/toys/pic.jpg' has red flags with fields:
      | message         |
      | Bad toy picture |
      | Bad checksum    |
    And the cfs file info for the path 'dogs/toys/text.pdf' has red flags with fields:
      | message      |
      | Bad toy text |
    And the cfs file info for the path 'dogs/hot/pic.jpg' has red flags with fields:
      | message         |
      | Bad hot picture |
    And the cfs file info for the path 'cats/cool/text.pdf' has red flags with fields:
      | message       |
      | Bad cool text |

  Scenario: View red flags for file group
    Given I am logged in as an admin
    When I view the file group named 'Toys'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Toys | Bit level file group |
    And I should see none of:
      | Bad hot picture | Bad cool text |

  Scenario: View red flags for file group as a manager
    Given I am logged in as a manager
    When I view the file group named 'Toys'
    And I click on 'Red Flags'
    Then I should see a table of red flags

  Scenario: View red flags for file group as a visitor
    Given I am logged in as a visitor
    When I view the file group named 'Toys'
    And I click on 'Red Flags'
    Then I should see a table of red flags

  Scenario: View red flags for collection
    Given I am logged in as an admin
    When I view the collection titled 'Dogs'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for collection as a manager
    Given I am logged in as a manager
    When I view the collection titled 'Dogs'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for collection as a visitor
    Given I am logged in as a visitor
    When I view the collection titled 'Dogs'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Dogs | Collection |
    And I should not see 'Bad cool text'

  Scenario: View red flags for repository
    Given I am logged in as an admin
    When I view the repository titled 'Animals'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals | Repository |

  Scenario: View red flags for repository as a manager
    Given I am logged in as a manager
    When I view the repository titled 'Animals'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals | Repository |

  Scenario: View red flags for repository as a visitor
    Given I am logged in as a visitor
    When I view the repository titled 'Animals'
    And I click on 'Red Flags'
    Then I should see a table of red flags
    And I should see all of:
      | Bad toy picture | Bad checksum | Bad toy text | Bad hot picture | Bad cool text | Animals | Repository |
