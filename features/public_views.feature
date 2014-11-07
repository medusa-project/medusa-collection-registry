Feature: Public views
  In order to use selected Medusa content
  As a public user
  I want to be able to view certain Medusa objects

  Background:
    Given I clear the cfs root directory
    And the physical cfs directory 'dogs' has a file 'intro.txt' with contents 'dog intro'
    And the physical cfs directory 'cats' has a file 'intro.txt' with contents 'cat intro'
    And the repository with title 'Animals' has child collections with fields:
      | title | description            | private_description     |
      | Dogs  | public dog description | private dog description |
      | Cats  | public dog description | private dog description |
    And the collection with title 'Dogs' has child file groups with fields:
      | name | type              | summary     | staged_file_location |
      | Dogs | BitLevelFileGroup | dog summary | /private/location    |
    And the collection with title 'Cats' has child file groups with fields:
      | name | type              | summary     | staged_file_location |
      | Cats | BitLevelFileGroup | cat summary | /private/location    |
    And the file group named 'Dogs' has cfs root 'dogs' and delayed jobs are run
    And the file group named 'Cats' has cfs root 'cats' and delayed jobs are run
    And the collection with title 'Dogs' has public rights
    And the file group with name 'Dogs' has public rights
    And the collection with title 'Cats' has private rights
    And the file group with name 'Cats' has private rights

  Scenario: View allowed collection metadata
    Given I public view the collection with title 'Dogs'
    Then I should see all of:
      | Dogs | public dog description |
    And I should not see 'private dog description'

  Scenario: Attempt to view restricted collection metadata
    Given I public view the collection with title 'Cats'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed file group metadata
    Given I public view the file group with name 'Dogs'
    Then I should see all of:
      | Dogs | dog summary |
    And I should not see '/private/location'

  Scenario: Attempt to view restricted file group metadata
    Given I public view the file group with name 'Cats'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed cfs directory metadata
    Given I public view the cfs directory for the file group named 'Dogs' for the path '.'
    Then I should see all of:
      | intro.txt |

  Scenario: Attempt to view restricted cfs directory metadata
    Given I public view the cfs directory for the file group named 'Cats' for the path '.'
    Then I should be redirected to the unauthorized page

  Scenario: View allowed cfs file metadata
    Given I public view the cfs file for the file group named 'Dogs' for the path 'intro.txt'
    Then I should see all of:
      | intro.txt | 9 Bytes | f346bd77c403097b0656ecd011e8c118 | text/plain |

  Scenario: Attempt to view restricted cfs file metadata
    Given I public view the cfs file for the file group named 'Cats' for the path 'intro.txt'
    Then I should be redirected to the unauthorized page

  Scenario: Download allowed file
    Given PENDING

  Scenario: Attempt to download restricted file
    Given PENDING

  Scenario: View allowed file
    Given PENDING

  Scenario: Attempt to view restricted file
    Given PENDING

  Scenario: Collection rights are used if there are no file group rights
    Given PENDING

  Scenario: File group rights override collection rights if there are both
    Given PENDING

  Scenario: Attempt to view private collection info is redirected to public
    Given PENDING

  Scenario: Attempt to view private file group info is redirected to public
    Given PENDING

  Scenario: Attempt to view private cfs directory info is redirected to public
    Given PENDING

  Scenario: Attempt to view private cfs file info is redirected to public
    Given PENDING

  Scenario: Navigation between these
    Given PENDING

  Scenario: Links from private to public versions (for sharing)
    Given PENDING