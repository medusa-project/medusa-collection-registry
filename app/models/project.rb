class Project < ActiveRecord::Base
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:manager)
  email_person_association(:owner)

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :items, dependent: :destroy
  belongs_to :collection

  STATUSES = %w(active inactive completed)

  validates_presence_of :start_date, :title, :manager_id, :owner_id, :collection_id, :status
  validates_inclusion_of :status, in: STATUSES
  delegate :title, to: :collection, prefix: true
  delegate :repository, :repository_title, to: :collection

  standard_auto_html(:specifications, :summary)

end