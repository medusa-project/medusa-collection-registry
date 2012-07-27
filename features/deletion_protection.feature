Feature: Delete protection
  In order to prevent orphaned data
  As a librarian
  I want to prevent objects with certain associations from being deleted

#TODO can't really do this until production units and file groups are attached
#repository can't be deleted if it has any collections?
#collection can't be deleted if it has any assessments or file groups? Or should
#we allow this?
#production unit can't be deleted if there are any associated file groups