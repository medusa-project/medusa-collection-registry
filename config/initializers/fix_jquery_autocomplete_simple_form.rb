#TODO take this out when it is fixed in the rails3-jquery-autocomplete gem
#The rails3-jquery-autocomplete gem uses simple form, but it yet define these methods with the arity
#expected by simple form. This fixes that. The arity checks should stop this from interfering after it is
#fixed in the gem itself.

module SimpleForm
  module Inputs
    if AutocompleteInput.instance_method(:input).arity == 0
      class AutocompleteInput
        alias old_input input
        def input(wrapper_options = {})
          old_input
        end
      end
    end

    if AutocompleteCollectionInput.instance_method(:input).arity == 0
      class AutocompleteCollectionInput
        alias old_input input
        def input(wrapper_options = {})
          old_input
        end
      end
    end

  end
end
