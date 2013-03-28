FactoryGirl.define do
  factory :cfs_file_info do
    sequence(:path) {|n| File.join(MedusaRails3::Application.cfs_root, "#{n}")}
    fits_xml "<fits/>"
  end
end