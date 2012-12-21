Feature: Bit Preservation
  In order to ingest and maintain content for bit level preservation
  As a librarian
  I want to be able to view the status of the bit store associated with a collection

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
    And the directory named 'small' has subdirectories named:
      | smaller | tiny |
    And the directory named 'tiny' has files with fields:
      | name  | size  |
      | micro | 34467 |

  Scenario: Navigate from collection to root directory
    When I view the collection titled 'Dogs'
    And I click on 'Bit root directory'
    Then I should be on the view page for the root directory of the collection titled 'Dogs'
    And I should see 'Dogs'

  Scenario: Navigate from directory to owning collection
    When I view the directory named 'small'
    And I click on 'Dogs'
    Then I should be on the view page for the collection titled 'Dogs'

  Scenario: Breadcrumbs for ancestor directories
    When I view the directory named 'smaller'
    Then I should see 'root'
    And I should see 'small'

  Scenario: Navigate via breadcrumbs
    When I view the directory named 'smaller'
    And I click on 'small'
    Then I should be on the view page for the directory named 'small'

  Scenario: Directory name
    When I view the directory named 'smaller'
    Then I should see 'smaller'

  Scenario: Subdirectory table
    When I view the directory named 'small'
    Then I should see a subdirectory table
    And I should see all of:
      | smaller | tiny |

  Scenario: Navigate to subdirectory
    When I view the directory named 'small'
    And I click on 'tiny'
    Then I should be on the view page for the directory named 'tiny'

  Scenario: File table
    When I view the directory named 'small'
    Then I should see a file table
    And I should see all of:
      | small_1 | 9208 | text/x-ruby | G7jiO82hrgstPNSD2t00Hw== | 0cdf6b50-2d1e-0130-bc56-000c2967d45f-9 |
    And I should see all of:
      | small_2 | 370891 | image/tiff | RHD8s2ogKpYHBP0MCpvvdA== | 3df08c50-2d1e-0130-bc56-000c2967d45f-d |

  Scenario: Size table - show size of files in collection, current directory and children, and current directory
    When I view the directory named 'small'
    Then I should see a cumulative file size table
    And I should see all of:
      | 380,099 | 414,566 | 1,525,677 |