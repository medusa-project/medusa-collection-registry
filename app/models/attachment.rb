require 'net_id_person_associator'
class Attachment < ActiveRecord::Base
	net_id_person_association(:author)

	belongs_to :attachable, :polymorphic => true
	validates_inclusion_of :attachable_type, :in => ['Collection', 'FileGroup', 'ExternalFileGroup', 'BitLevelFileGroup', 'ObjectLevelFileGroup']

	# Paperclip
	has_attached_file :attachment,
	:styles => {
	}

	validates_attachment_size :attachment, :less_than => 5.megabytes
end