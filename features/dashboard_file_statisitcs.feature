Feature: File Statistics Summary on the Collection Registry Dashboard
  In order to view a summary of file statistics in the collection registry
  As a librarian
  I want to have a dashboard view that shows it

  Background:
    Given I am logged in as an admin
    And the repository titled 'Animals' has collections with fields:
      | title |
      | Dogs  |
    And the root directory for the collection titled 'Dogs' has subdirectories named:
      | big | small |
    And the directory named 'big' has files with fields:
      | name     | size    |
      | big_file | 1111111 |
    And the directory named 'small' has files with fields:
      | name    | size   | content_type | md5sum                   | dx_name                                | dx_ingested |
      | small_1 | 9208   | text/x-ruby  | G7jiO82hrgstPNSD2t00Hw== | 0cdf6b50-2d1e-0130-bc56-000c2967d45f-9 | true        |
      | small_2 | 370891 | image/tiff   | RHD8s2ogKpYHBP0MCpvvdA== | 3df08c50-2d1e-0130-bc56-000c2967d45f-d | false       |
      | small_3 | 7000   | text/x-ruby  | ABjiO82hrgstPNSD2t00Hw== | 1cdf6b50-2d1e-0130-bc56-000c2967d45f-9 | true        |
    And the directory named 'small' has subdirectories named:
      | smaller | tiny |
    And the directory named 'tiny' has files with fields:
      | name  | size  |
      | micro | 34467 |

  Scenario: View file statistics section of dashboard
    When I go to the dashboard
    Then show me the page
    And I click on 'File Statistics'
    Then I should see the bit & object preservation content_type statistics
    And I should see the bit & object preservation summary file statistics

  Scenario: View bit preservation summary content_type table
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see a bit preservation content_type table
    And I should see all of:
      | text/x-ruby | 0.0162 | 2 |

  Scenario: View object preservation summary content_type table
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see an object preservation content_type table
    And I should see all of:
      | |

  Scenario: View bit & object preservation summary table
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see the bit & object preservation summary file statistics
    And I should see all of:
      | Total Bit Preservation Files: | 2 | | Total Object Preservation Files: | 0 |
    And I should see all of:
      | Total Bit Preservation GB: | 0.0162 | | Total Bit Preservation GB: | 0 |

