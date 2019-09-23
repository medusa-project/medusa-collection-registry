FactoryBot.define do
  factory :file_format_note do
    date {Date.today}
    user
    sequence(:note) {|n| "Note #{n}"}
  end
end