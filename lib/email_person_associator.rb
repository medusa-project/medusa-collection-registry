class ActiveRecord::Base
  #TODO this can probably be expressed better as a concern
  #Use email_person_association to make a simple association in a model with a Person
  #Makes a belong_to association attr_name
  #to the person class, and makes accessors attr_name_email and attr_name_email=
  #that do the right things. You still need to make a #{attr_name}_id field via a migration
  #and a reverse association if desired
  def self.email_person_association(attr_name)
    belongs_to attr_name, class_name: Person
    define_method :"#{attr_name}_email" do
      self.send(attr_name).try(:email)
    end
    define_method :"#{attr_name}_email=" do |email|
      email.strip!
      setter = :"#{attr_name}="
      if email.blank?
        self.send(setter, nil)
      else
        self.send(setter, Person.find_or_create_by(email: email))
      end
    end
  end
end