RAILS_ENV = "test" unless defined? RAILS_ENV

require 'test/unit'
require 'rubygems'

# FIXME load path
environment = File.dirname(__FILE__) + '/../../../../config/environment'
require environment if not defined?(Rails) && File.exist?(environment + '.rb')

require 'active_support'
require 'action_controller'
require 'active_support/test_case'
require 'active_record/fixtures'
require 'action_controller/integration'

$:.unshift File.dirname(__FILE__) + '/models'
require 'project'
require 'task'
require 'milestone'

ActionController::IntegrationTest.fixture_path = Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
  
  # Assert the given condition is *false*.
  def assert_not(condition, message = nil)
    assert !condition, message
  end
  
  # Assert the given collection is *empty*.
  def assert_empty(collection, message = nil)
    assert collection.empty?, message
  end
  
  # Assert the given collection is *not empty*.
  def assert_not_empty(collection, message = nil)
    assert_not collection.empty?, message
  end
  
  # Assert the given model is *valid*.
  def assert_valid(model, message = nil)
    assert model.valid?, message
  end
  
  # Assert the numerical difference of the project's task count,
  # before and after the given block is yielded.
  def assert_task_count_difference(count = 1, &block)
    assert_difference "project.tasks.count", count do
      yield
    end
  end
  
  # Assert there is not numerical difference in the project's task count,
  # before and after the given block is yielded.
  def assert_no_task_count_difference(&block)
    assert_no_difference "project.tasks.count" do
      yield
    end
  end

  # Assert the given model has valid associated records.
  def assert_valid_associated_records(model, association)
    association = model.send(association)
    assert_not_empty association
    association.each do |associated_model|
      assert_not associated_model.new_record?
      associated_model.attributes.each do |attr, value|
        assert_not_nil value,
          "#{attr} should be not nil for #{associated_model.class}(#{associated_model.id})"
      end
    end
    
  end
end
