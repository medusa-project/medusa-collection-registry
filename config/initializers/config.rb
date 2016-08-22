Config.setup do |config|
  # Name of the constant exposing loaded settings
  config.const_name = 'Settings'

  # Ability to remove elements of the array set in earlier loaded settings file. For example value: '--'.
  #
  # config.knockout_prefix = nil

  # Load environment variables from the `ENV` object and override any settings defined in files.
  #
  # config.use_env = false

  # Define ENV variable prefix deciding which variables to load into config.
  #
  # config.env_prefix = 'Settings'

  # What string to use as level separator for settings loaded from ENV variables. Default value of '.' works well
  # with Heroku, but you might want to change it for example for '__' to easy override settings from command line, where
  # using dots in variable names might not be allowed (eg. Bash).
  #
  # config.env_separator = '.'

  # Ability to process variables names:
  #   * nil  - no change
  #   * :downcase - convert to lower case
  #
  # config.env_converter = nil

  # Parse numeric values as integers instead of strings.
  #
  #config.env_parse_values = false
end

#convenience to make some methods exposing Config values
class Object

  #keys are the keys from Settings.classes.<class_key or underscored class name> we want to expose as methods
  #These will be exposed on the class with a method name the same as the key. The object will delegate that method to the
  #class unless skip_object_method is true. This makes it easy to use these for inclusion validations with just a symbol
  #argument.
  def self.expose_class_config(*keys, class_key: nil, skip_object_method: false)
    class_key ||= self.to_s.underscore
    keys = Array.wrap(keys)
    keys.each do |key|
      define_singleton_method(key) do
        Settings.classes[class_key][key]
      end
      unless skip_object_method
        self.delegate key, to: :class
      end
    end
  end

end
