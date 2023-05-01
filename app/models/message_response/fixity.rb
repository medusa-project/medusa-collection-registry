class MessageResponse::Fixity < MessageResponse::Base

  def pass_through_id_key
    'cfs_file_id'
  end

  def pass_through_class_key
    'cfs_file_class'
  end

  def self.incoming_queue
    ::CfsFile.incoming_queue
  end

  def success_method
    :on_fixity_success
  end

  def failure_method
    :on_fixity_failure
  end

  def unrecognized_method
    :on_fixity_unrecognized
  end

  def checksums
    self.parameter_field('checksums')
  end

  def md5
    self.checksums['md5']
  end

  def sha1
    self.checksums['sha1']
  end

  def found?
    self.parameter_field('found')
  end

end