Feature: File Statistics Summary on the Collection Registry Dashboard
  In order to view a summary of file statistics in the collection registry
  As a librarian
  I want to have a dashboard view that shows it

  Background:
    Given I am logged in as an admin
    And PENDING
#    And there are cfs file infos with fields:
#      | path                  | size    | content_type |
#      | root/big/big_file     | 1111111 |              |
#      | root/small/small_1    | 9208    | text/x-ruby  |
#      | root/small/small_2    | 370891  | image/tiff   |
#      | root/small/small_3    | 7000    | text/x-ruby  |
#      | root/small/tiny/micro | 34467   |              |

  Scenario: View file statistics section of dashboard
    When I go to the dashboard
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
      |  |

  Scenario: View bit & object preservation summary table
    When I go to the dashboard
    And I click on 'File Statistics'
    Then I should see the bit & object preservation summary file statistics
    And I should see all of:
      | Total Bit Preservation Files: | 5 |  | Total Object Preservation Files: | 0 |
    And I should see all of:
      | Total Bit Preservation GB: | 0.0162 |  | Total Bit Preservation GB: | 0 |

