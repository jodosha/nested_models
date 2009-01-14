class Project < ActiveRecord::Base
  has_many :tasks, :accessible => true
  has_many :milestones
end
