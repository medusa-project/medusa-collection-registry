FactoryGirl.define do
  factory :item do
    project
    %i(barcode bib_id oclc_number call_number).each do |identifier|
      sequence(identifier) {|n| "#{identifier}_#{n}"}
    end
  end

end