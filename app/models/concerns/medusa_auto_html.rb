require 'active_support/concern'

module MedusaAutoHtml
  extend ActiveSupport::Concern

  module ClassMethods
    def standard_auto_html(*fields)
      fields.each do |field|
        self.send(:auto_html_for, field) do
          html_escape
          link target: '_blank'
          simple_format
        end
      end
    end
  end

end