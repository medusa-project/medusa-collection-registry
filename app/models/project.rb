class Project < ActiveRecord::Base

  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  STATUSES = %w(active inactive)

  validates_presence_of :start_date, :title, :manager, :owner
  validates_inclusion_of :status, in: STATUSES

  %i(specifications summary).each do |field|
    auto_html_for field do
      html_escape
      link target: '_blank'
      simple_format
    end
  end

end