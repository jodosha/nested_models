RAILS_ENV = "test" unless defined?(RAILS_ENV)

require 'rubygems'
require 'active_record'
require 'active_record/fixtures'

path_to_fixtures = File.dirname(__FILE__) + '/../test/fixtures'
fixtures = %w( projects tasks milestones )

desc 'Run default task (test)'
task :nested_models => 'nested_models:test'

namespace :nested_models do
  desc 'Reset the NestedModels data'
  task :reset => [ :teardown, :setup ]

  desc 'Create NestedModels test database tables and load fixtures'
  task :setup => [ :create_tables, :load_fixtures ]

  desc 'Remove all NestedModels data'
  task :teardown => :drop_tables

  desc 'Create NestedModels test database tables'
  task :create_tables => :environment do
    ActiveRecord::Schema.define do
      create_table :projects, :force => true do |t|
        t.string :name

        t.timestamps
      end

      create_table :tasks, :force => true do |t|
        t.integer :project_id
        t.string  :name
        t.text    :description

        t.timestamps
      end
      
      create_table :milestones, :force => true do |t|
        t.integer :project_id
        t.string  :name
        t.date    :due_on

        t.timestamps
      end
    end
  end

  desc 'Drops NestedModels test database tables'
  task :drop_tables => :environment do
    ActiveRecord::Base.connection.drop_table :projects
    ActiveRecord::Base.connection.drop_table :tasks
    ActiveRecord::Base.connection.drop_table :milestones
  end

  desc 'Load fixtures'
  task :load_fixtures => :environment do
    fixtures.each { |f| Fixtures.create_fixtures(path_to_fixtures, f) }
  end

  desc 'Test NestedModels'
  task :test => [ :setup, 'test:all' ]

  namespace :test do
    desc 'Run NestedModels tests'
    Rake::TestTask.new(:all) do |t|
      t.test_files = FileList["#{File.dirname( __FILE__ )}/../test/**/*_test.rb"]
      t.verbose = true
    end
  end
end
