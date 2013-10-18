class ActiveRecord::Base
  #Use net_id_person_association to make a simple association in a model with a Person
  #Makes #{attr_name}_net_id mass assignable, makes a belong_to association attr_name
  #to the person class, and makes accessors attr_name_net_id and attr_name_net_id=
  #that do the right things. You still need to make a #{attr_name}_id field via a migration
  #and a reverse association if desired
  def self.net_id_person_association(attr_name)
#    attr_accessible :"#{attr_name}_net_id"
    belongs_to attr_name, :class_name => Person
    define_method :"#{attr_name}_net_id" do
      self.send(attr_name).try(:net_id)
    end
    define_method :"#{attr_name}_net_id=" do |net_id|
      net_id.strip!
      setter = :"#{attr_name}="
      if net_id.blank?
        self.send(setter, nil)
      else
        self.send(setter, Person.find_or_create_by_net_id(net_id))
      end
    end
  end
end