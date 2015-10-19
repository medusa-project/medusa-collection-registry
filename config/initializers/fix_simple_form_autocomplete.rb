#Until rails3-jquery-autocomplete catches up this fixes a deprecation issue
#with their simple_from integration. There is a pull request for this fix,
#so hopefully it'll make it in soon after 1.0.14.
# require 'rails-jquery-autocomplete'
# class SimpleForm::Inputs::AutocompleteInput
#   def input(wrapper_options)
#     @builder.autocomplete_field(
#         attribute_name,
#         options[:url],
#         merge_wrapper_options(rewrite_autocomplete_option, wrapper_options)
#     )
#   end
# end