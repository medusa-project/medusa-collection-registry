Feature: CFS integration
  In order to temporarily preserve and work with files before ingest
  As a librarian
  I want to be able to work with a CFS file share exposed as a local directory

  Background:
    Given I clear the cfs root directory
    And there is a cfs directory 'dogs/pugs'
    And the cfs directory 'dogs' has files:
      | intro.txt |
    And the cfs directory 'dogs/pugs' has files:
      | picture.jpg | description.txt |

  Scenario: View CFS directory as an admin
    Given I am logged in as an admin
    When I view the cfs path 'dogs'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a manager
    Given I am logged in as a manager
    When I view the cfs path 'dogs'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a visitor
    Given I am logged in as a visitor
    When I view the cfs path 'dogs'
    Then I should see all of:
      | intro.txt | pugs |

  Scenario: View CFS directory as a public user
    Given I am not logged in
    When I view the cfs path 'dogs'
    Then I should be on the login page

  Scenario: Navigate CFS directory down
    Given I am logged in as an admin
    When I view the cfs path 'dogs'
    And I click on 'pugs'
    Then I should be viewing the cfs directory 'dogs/pugs'

  Scenario: Navigate CFS directory up
    Given I am logged in as an admin
    When I view the cfs path 'dogs/pugs'
    And I click on 'dogs'
    Then I should be viewing the cfs directory 'dogs'

  Scenario: View a file as an admin
    Given I am logged in as an admin
    When I view the cfs path 'dogs/intro.txt'
    Then I should be viewing the cfs file 'dogs/intro.txt'
    And I should see 'intro.txt'

  Scenario: View a file as a manager
    Given I am logged in as a manager
    When I view the cfs path 'dogs/intro.txt'
    Then I should be viewing the cfs file 'dogs/intro.txt'

  Scenario: View a file as a visitor
    Given I am logged in as a visitor
    When I view the cfs path 'dogs/intro.txt'
    Then I should be viewing the cfs file 'dogs/intro.txt'

  Scenario: View a file as a public user
    Given I am not logged in
    When I view the cfs path 'dogs/intro.txt'
    Then I should be on the login page

  Scenario: Try to view non-existent directory
    Given I am logged in as an admin
    When I view the cfs path 'dogs/chihuahuas'
    Then I should see '/dogs/chihuahuas was not found.'


