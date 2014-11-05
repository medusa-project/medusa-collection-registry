require 'csv'
module ActiveRecordToCsv

  extend ActiveSupport::Concern

  module ClassMethods

    #A value in the header hash is just a string to use for the CSV header
    #A key is a symbol or string or array of symbols/strings. The value is computed
    #by wrapping as an array and then sending the messages in succession, starting with the instance.
    #In simple cases you could just use an attribute name; the more complex form allows us to use something like
    #[:repository, :title] => "Repository" on a collection to get the repository title with header "Repository".
    def to_csv(csv_options: {}, header_hash: self.default_csv_header_hash)
      CSV.generate(csv_options) do |csv|
        csv << header_hash.values
        all.each do |record|
          csv << header_hash.keys.collect {|key| Array.wrap(key).inject(record) {|object, message| object.send(message)} rescue ''}
        end
      end
    end

    #By default just use a map from attributes to humanized names
    def default_csv_header_hash
      Hash.new.tap do |hash|
        self.attribute_names.sort.each { |name| hash[name] = name.humanize }
      end

    end

  end
end