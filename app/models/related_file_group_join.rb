class RelatedFileGroupJoin < ActiveRecord::Base
  attr_accessible :file_group_id, :note, :related_file_group_id

  belongs_to :file_group
  belongs_to :related_file_group, :class_name => 'FileGroup'

  after_save :ensure_symmetric_join
  after_destroy :destroy_symmetric_join

  def ensure_symmetric_join
    if join = self.find_symmetric_join
      join.note = self.note
      join.save! if join.changed?
    else
      self.class.create(:file_group_id => self.related_file_group_id,
                        :related_file_group_id => self.file_group_id, :note => self.note)
    end
  end

  def destroy_symmetric_join
    if join = self.find_symmetric_join
      join.destroy
    end
  end

  def find_symmetric_join
    self.class.where(:file_group_id => self.related_file_group_id,
                     :related_file_group_id => self.file_group_id).first
  end

end
