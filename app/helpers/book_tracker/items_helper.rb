module BookTracker
  module ItemsHelper

    def readable_hathitrust_rights(item)
      # http://www.hathitrust.org/rights_database#Attributes
      case item.hathitrust_rights
        when 'pd'
          return 'Public domain'
        when 'ic'
          return 'In-copyright'
        when 'op'
          return 'Out-of-print (in-copyright)'
        when 'orph'
          return 'Copyright-orphaned (in-copyright)'
        when 'und'
          return 'Undetermined copyright status'
        when 'umall'
          return 'Available to UM affiliates and walk-in-patrons (all campuses)'
        when 'ic-world'
          return 'In-copyright and permitted as world viewable by the copyright holder'
        when 'nobody'
          return 'Available to nobody; blocked for all users'
        when 'pdus'
          return 'Public domain only when viewed in the US'
        when 'cc-by-3.0'
          return 'Creative Commons Attribution license, 3.0 Unported'
        when 'cc-by-nd-3.0'
          return 'Creative Commons Attribution-NoDerivatives license, 3.0 Unported'
        when 'cc-by-nc-nd-3.0'
          return 'Creative Commons Attribution-NonCommercial-NoDerivatives license, 3.0 Unported'
        when 'cc-by-nc-3.0'
          return 'Creative Commons Attribution-NonCommercial license, 3.0 Unported'
        when 'cc-by-nc-sa-3.0'
          return 'Creative Commons Attribution-NonCommercial-ShareAlike license, 3.0 Unported'
        when 'cc-by-sa-3.0'
          return 'Creative Commons Attribution-ShareAlike license, 3.0 Unported'
        when 'orphcand'
          return 'Orphan candidate - in 90-day holding period (implies in-copyright)'
        when 'cc-zero'
          return 'Creative Commons Zero license (implies pd)'
        when 'und-world'
          return 'Undetermined copyright status and permitted as world viewable by the depositor'
        when 'icus'
          return 'In copyright in the US'
        when 'cc-by-4.0'
          return 'Creative Commons Attribution 4.0 International license'
        when 'cc-by-nd-4.0'
          return 'Creative Commons Attribution-NoDerivatives 4.0 International license'
        when 'cc-by-nc-nd-4.0'
          return 'Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International license'
        when 'cc-by-nc-4.0'
          return 'Creative Commons Attribution-NonCommercial 4.0 International license'
        when 'cc-by-nc-sa-4.0'
          return 'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license'
        when 'cc-by-sa-4.0'
          return 'Creative Commons Attribution-ShareAlike 4.0 International license'
        else
          return 'Unknown'
      end
    end

  end
end