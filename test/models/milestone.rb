class Milestone < ActiveRecord::Base
  set_accessible_association_destroy_flag "destroy_me"

  belongs_to :project
end