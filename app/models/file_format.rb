class FileFormat < ApplicationRecord
  has_many :file_format_profiles, -> {order :name}
  has_many :file_format_notes, -> {order :created_at}, dependent: :destroy
  has_many :file_format_normalization_paths, -> {order :created_at}, dependent: :destroy
  has_many :pronoms, -> {order :created_at}, dependent: :destroy
end
