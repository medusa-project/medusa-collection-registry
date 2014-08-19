Feature: CFS integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to work with a CFS file share exposed as a local directory

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has a file 'intro.txt' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'picture.jpg' with contents 'anything'
    And the physical cfs directory 'dogs/pugs' has a file 'description.txt' with contents 'anything'
    And the collection titled 'Animals' has file groups with fields:
      | name | type              |
      | Dogs | BitLevelFileGroup |
    And the file group named 'Dogs' has cfs root 'dogs' and delayed jobs are run

  Scenario: View CFS directory as an admin
    Given I am logged in as an admin
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a manager
    Given I am logged in as a manager
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a visitor
    Given I am logged in as a visitor
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a public user
    Given I am not logged in
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should be on the login page

  Scenario: Navigate CFS directory down
    Given I am logged in as an admin
    When I view the cfs directory for the file group named 'Dogs' for the path '.'
    And I click on 'pugs'
    Then I should be viewing the cfs directory for the file group named 'Dogs' for the path 'pugs'

  Scenario: Navigate CFS directory up
    Given I am logged in as an admin
    When I view the cfs directory for the file group named 'Dogs' for the path 'pugs'
    And I click on 'dogs'
    Then I should be viewing the cfs directory for the file group named 'Dogs' for the path '.'

  Scenario: View a file as an admin
    Given I am logged in as an admin
    When I view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should be viewing the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    And I should see 'intro.txt'

  Scenario: View a file as a manager
    Given I am logged in as a manager
    When I view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should be viewing the cfs file for the file group named 'Dogs' for the path 'intro.txt'

  Scenario: View a file as a visitor
    Given I am logged in as a visitor
    When I view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should be viewing the cfs file for the file group named 'Dogs' for the path 'intro.txt'

  Scenario: View a file as a public user
    Given I am not logged in
    When I view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should be on the login page


