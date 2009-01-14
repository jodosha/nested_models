Gem::Specification.new do |s|
  s.name               = "nested_models"
  s.version            = "0.0.1"
  s.date               = "2009-01-14"
  s.summary            = "Massive access to ActiveRecord associated models."
  s.author             = "Luca Guidi"
  s.email              = "guidi.luca@gmail.com"
  s.homepage           = "http://lucaguidi.com/pages/nested_models"
  s.description        = "NestedModels deal with massive handling of associated (nested) ActiveRecord models."
  s.has_rdoc           = true
  s.files              = ["CHANGELOG", "MIT-LICENSE", "README", "Rakefile", "init.rb", "install.rb", "lib/activerecord/lib/active_record.rb", "lib/activerecord/lib/active_record/associations.rb", "lib/activerecord/lib/active_record/base.rb", "lib/nested_models.rb", "nested_models.gemspec", "tasks/nested_models_tasks.rake", "test/active_record/associations/has_many_association_test.rb", "test/active_record/base_test.rb", "test/fixtures/milestones.yml", "test/fixtures/projects.yml", "test/fixtures/tasks.yml", "test/models/milestone.rb", "test/models/project.rb", "test/models/task.rb", "test/test_helper.rb", "uninstall.rb"]
  s.test_files         = ["test/active_record/associations/has_many_association_test.rb", "test/active_record/base_test.rb"]
  s.extra_rdoc_files   = ['README', 'CHANGELOG']
  
  s.add_dependency("activesupport", ["> 2.2.2"])
  s.add_dependency("activerecord",  ["> 2.2.2"])
end