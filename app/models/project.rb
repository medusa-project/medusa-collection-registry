class Project < ActiveRecord::Base
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  STATUSES = %w(active inactive completed)

  validates_presence_of :start_date, :title, :manager, :owner
  validates_inclusion_of :status, in: STATUSES

  standard_auto_html(:specifications, :summary)

end