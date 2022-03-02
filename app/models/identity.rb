class Identity < OmniAuth::Identity::Models::ActiveRecord
  validates_presence_of :name
  validates_uniqueness_of :email
  validates_format_of :email, { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
end