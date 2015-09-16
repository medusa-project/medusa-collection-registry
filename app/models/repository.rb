class Repository < ActiveRecord::Base
  include ActiveDateChecker
  include RedFlagAggregator
  include Breadcrumb
  include CascadedEventable
  include MedusaAutoHtml
  include EmailPersonAssociator

  email_person_association(:contact)
  belongs_to :institution
  has_many :collections, dependent: :destroy
  has_many :assessments, as: :assessable, dependent: :destroy

  LDAP_DOMAINS = %w(uofi uiuc)

  validates_uniqueness_of :title
  validates_presence_of :title
  validates_presence_of :institution_id
  validate :check_active_dates
  validates_inclusion_of :ldap_admin_domain, in: LDAP_DOMAINS, allow_blank: true

  standard_auto_html(:notes)

  aggregates_red_flags collections: :collections, label_method: :title
  breadcrumbs parent: nil, label: :title
  cascades_events parent: nil

  def total_size
    self.collections.collect { |c| c.total_size }.sum
  end

  #TODO - this will probably not be correct any more when we have more than one institution
  def self.aggregate_size
    FileGroup.aggregate_size
  end

  def recursive_assessments
    self.assessments + self.collections.collect { |collection| collection.recursive_assessments }.flatten
  end

  def all_scheduled_events
    self.collections.collect { |collection| collection.all_scheduled_events }.flatten
  end

  def incomplete_scheduled_events
    self.collections.collect { |collection| collection.incomplete_scheduled_events }.flatten
  end

  def manager?(user)
    ApplicationController.is_member_of?(self.ldap_admin_group, user, self.ldap_admin_domain)
  end

  def repository
    self
  end

end
