require File.dirname(__FILE__) + '/../test_helper'

class BaseTest < Test::Unit::TestCase
  fixtures :projects

  def test_classes_should_keep_separated_accessible_associations
    assert_equal [ :tasks ], Project.accessible_associations
    assert_empty Task.accessible_associations
  end

  def test_should_create_record_and_associated_records
    project = Project.create(:name => 'Project', :tasks => [
      { :name => 'Task one', :description => "Blah Blah" },
      { :name => 'Task two', :description => "Blah Blah" }
    ])

    assert_not project.new_record?
    assert_valid project
    assert_valid_associated_records project, :tasks
  end

  def test_should_raise_exception_on_massive_assigment_of_unaccessible_association
    assert_raise ActiveRecord::AssociationTypeMismatch do
      Project.create(:name => 'Project', :milestones => [{ :name => 'Alpha' }])
    end
  end

  def test_should_add_associated_records
    assert_difference "Task.count" do
      assert project.update_attributes(:name => "NM", :tasks => [
        { :name => 'Another task', :description => "Blah Blah"}
      ])      
    end
    assert_equal "NM", project.name
    assert_valid_associated_records project, :tasks
  end

  private
    def project
      @project ||= projects(:nested_models)
    end
end
