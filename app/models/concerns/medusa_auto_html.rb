require 'active_support/concern'

module MedusaAutoHtml
  extend ActiveSupport::Concern

  module ClassMethods

    def standard_auto_html(*fields)
      pipeline = AutoHtml::Pipeline.new(AutoHtml::HtmlEscape.new,
                                        AutoHtml::Link.new(target: '_blank'),
                                        AutoHtml::SimpleFormat.new)
      fields.each do |field|
        m = Module.new do
          define_method(:"#{field}=") do |value|
            self.send("#{field}_html=", pipeline.call(value))
            super(value)
          end
          define_method(:"#{field}_html") do
            super().try(:html_safe)
          end
        end
        self.prepend m
      end
    end

  end
end

