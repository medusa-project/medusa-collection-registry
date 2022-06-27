class Repository < ApplicationRecord
  include ActiveDateChecker
  include Breadcrumb
  include CascadedEventable
  include CascadedRedFlaggable
  include MedusaAutoHtml
  include EmailPersonAssociator
  include Eventable
  include Uuidable

  email_person_association(:contact)
  belongs_to :institution
  belongs_to :parent, class_name: 'Institution', foreign_key: 'institution_id'

  has_many :collections, dependent: :destroy
  has_many :assessments, as: :assessable, dependent: :destroy
  has_many :virtual_repositories, dependent: :destroy

  LDAP_DOMAINS = %w(uofi)

  validates_uniqueness_of :title
  validates_presence_of :title
  validates_presence_of :institution_id
  validate :check_active_dates
  validates_inclusion_of :ldap_admin_domain, in: LDAP_DOMAINS, allow_blank: true

  standard_auto_html(:notes)

  breadcrumbs parent: nil, label: :title
  cascades_events parent: nil
  cascades_red_flags parent: nil

  def total_size
    self.collections.collect { |c| c.total_size }.sum
  end

  def total_files
    self.collections.collect {|c| c.total_files}.sum
  end

  #TODO - this will probably not be correct any more when we have more than one institution
  def self.aggregate_size
    BitLevelFileGroup.aggregate_size
  end

  def recursive_assessments
    self.assessments + self.collections.collect { |collection| collection.recursive_assessments }.flatten
  end

  def manager?(user)
    GroupManager.instance.is_member_of?(self.ldap_admin_group, user)
  end

  def repository
    self
  end

  def timeline_directory_ids
    directory_ids = []
    self.collections.each do |collection|
      directory_ids.push(*collection.timeline_directory_ids) unless collection.timeline_directory_ids.empty?
    end
    directory_ids
  end

  def self.title_order
    order(:title)
  end

  def self.managed_by(user)
    title_order.select {|repository| repository.manager?(user)}
  end

end
