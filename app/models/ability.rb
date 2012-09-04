require 'uiuc_ldap' #we may not need this here, but this will ensure it is available for anything  that needs it
class Ability
  include CanCan::Ability

  def initialize(user)

    #We start with the general form here. We can work out how CanCan's simpler forms might apply later if need be,
    #or auth could just always pass through this method.
    #We can visualize the possible subject_classes having a method that takes the user, action,
    #and subject and using it to decide the result (so all the logic isn't concentrated here).
    #That way they'd be able to know what sort of LDAP lookup they needed to do locally (and to
    #consult the db if appropriate, etc.)
    can do |action, subject_class, subject|
      if subject_class.respond_to?(:authorized?)
        subject_class.authorized?(user, action, subject)
      else
        false
      end
    end
  end

end
