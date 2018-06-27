#Set up the main storage root
#We use and discard a root set for simplicity, as it is able to create the right type of root
root_config = Settings.medusa.main_storage_root.to_h
root_set = MedusaStorage::RootSet.new(Array.wrap(root_config))
Application.main_storage_root = root_set.at(root_config[:name]) || raise("Main storage root not defined")