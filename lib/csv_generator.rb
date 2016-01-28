require 'csv'
module CsvGenerator

  module_function

  #header_spec is a map from symbols/strings to strings.
  #The hash keys are methods to call on the members of the collection to get the csv values, with '' on any error;
  #the hash values are the headers
  #csv options are passed directly to CSV
  def generate(collection, header_spec, csv_options = {})
    CSV.generate(csv_options) do |csv|
      csv << header_spec.values
      collection.find_each(batch_size: 100) do |record|
        csv << header_spec.keys.collect {|key| record.send(key) rescue ''}
      end
    end
  end

end