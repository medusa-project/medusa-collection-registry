class FitsData < ActiveRecord::Base
  include FitsDatetimeParser

  belongs_to :cfs_file

  expose_class_config :simple_string_fields, :date_fields
  delegate :all_fields, to: :class

  def self.all_fields
    @all_fields ||= simple_string_fields.keys + date_fields.keys
  end

  def update_from(xml)
    doc = Nokogiri::XML.parse(xml).remove_namespaces!
    update_simple_string_fields(doc)
    update_date_fields(doc)
  end

  def update_simple_string_fields(doc)
    simple_string_fields.each do |field, xpath|
      node = doc.at_xpath(xpath)
      value = node.present? ? node.text : nil
      send("#{field}=", value)
    end
  end

  def update_date_fields(doc)
    date_fields.each do |field, xpath|
      node = doc.at_xpath(xpath)
      value = node.present? ? safe_parse_datetime(node.text, node['toolname']) : nil
      send("#{field}=", value)
    end
  end

  def safe_parse_datetime(datetime_string, toolname)
    parse_datetime(datetime_string, toolname)
  rescue Exception => e
    Rails.logger.error e.to_s
    GenericErrorMailer.error("#{e}\nFits data id:#{self.id}\nCfs File id:#{self.cfs_file.id}", subject: 'FITS date parse error').deliver_now
    return nil
  end

end