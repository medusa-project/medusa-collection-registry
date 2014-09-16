#Remove attachments after tests
After do
  Attachment.all.each do |attachment|
    attachment.destroy
  end
end