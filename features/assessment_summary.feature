Feature: Assessment summary
  In order to have an overview of assessments at different levels
  As a librarian
  I want to be able to view a summary of assessments for objects owned by other objects

  Background:
    Given I am logged in as an admin
    And the repository with title 'Animals' has child collections with fields:
      | title |
      | Dogs  |
      | Cats  |
    And the repository with title 'Plants' has child collections with fields:
      | title |
      | Cacti |
    And the collection with title 'Dogs' has child file groups with fields:
      | name |
      | Toy  |
      | Hot  |
    And the file group named 'Toy' has an assessment named 'toy assessment'
    And the file group named 'Hot' has an assessment named 'hot assessment'
    And the collection titled 'Dogs' has an assessment named 'dog assessment'
    And the collection titled 'Cats' has an assessment named 'cat assessment'
    And the collection titled 'Cacti' has an assessment named 'cacti assessment'

  Scenario: View collection and go to summary of assessments
    When I view the collection with title 'Dogs'
    Then I should see all of:
      | toy assessment | hot assessment | dog assessment |
    And I should see none of:
      | cat assessment | cacti assessment |

  Scenario: View repository and go to summary of assessments
    When I view the repository with title 'Animals'
    Then I should see all of:
      | toy assessment | hot assessment | dog assessment | cat assessment |
    And I should see none of:
      | cacti assessment |
