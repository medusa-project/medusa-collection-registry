require 'net_id_person_associator'
class Attachment < ActiveRecord::Base
	net_id_person_association(:author)

	attr_accessible :attachable_id, :attachable_type, :attachment_content_type, :attachment_file_name, :attachment_file_size, :attachment

	belongs_to :attachable, :polymorphic => true
	validates_inclusion_of :attachable_type, :in => ['Collection']

	# Paperclip
	has_attached_file :attachment,
	:styles => {
	}

	validates_attachment_size :attachment, :less_than => 5.megabytes
end