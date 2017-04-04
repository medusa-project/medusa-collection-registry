FactoryGirl.define do
  factory :item do
    project
    %i(bib_id oclc_number call_number).each do |identifier|
      sequence(identifier) {|n| "#{identifier}_#{n}"}
    end
    sequence(:barcode) {|n| (n + 30012323456789).to_s}
  end

end