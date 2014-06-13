#Create bags to be sent to Amazon Glacier for backup (other code will be
# responsible for requesting creation and for actually uploading)
#Receive the (bit level) file group to back up
#Figure out if there are previous backups and use this information
#to restrict files to back up.
#Make a list of files to back up
#If necessary break the list into pieces for size considerations
#Make bag(s) as backup
#Extract manifest files from created bags and store

#Config
# - backup registry directory (stores manifests)
# - bag creation dir - where to create the bags - this will
# need significant space, so probably will need to be on our main storage
# - maximum size of bag (environment sensitive so as to enable testing)

#Registry/bag naming format: fg<id>-<dt>-p<part>[.txt|.zip]
module BackupBagger

  module_function

end