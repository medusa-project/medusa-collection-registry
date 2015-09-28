class Project < ActiveRecord::Base
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  belongs_to :collection

  STATUSES = %w(active inactive completed)

  validates_presence_of :start_date, :title, :manager_id, :owner_id, :collection_id, :status
  validates_inclusion_of :status, in: STATUSES

  standard_auto_html(:specifications, :summary)

end