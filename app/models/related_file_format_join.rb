class RelatedFileFormatJoin < ApplicationRecord
  belongs_to :file_format
  belongs_to :related_file_format, class_name: 'FileFormat'

  after_destroy :destroy_symmetric_partner
  after_save :ensure_symmetric_partner

  def destroy_symmetric_partner
    if partner
      partner.destroy!
    end
  end

  def ensure_symmetric_partner
    unless partner
      self.class.create(file_format: related_file_format, related_file_format: file_format)
    end
  end

  def partner
    self.class.find_by(file_format_id: related_file_format, related_file_format: file_format)
  end

end
