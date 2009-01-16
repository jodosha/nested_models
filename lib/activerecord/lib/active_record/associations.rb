require File.dirname(__FILE__) + '/associations/association_collection'

module ActiveRecord
  module Associations
    module ClassMethods
      valid_keys_for_has_many_association << :accessible
      
      private
        def association_accessor_methods(reflection, association_proxy_class)
          ivar = "@#{reflection.name}"

          define_method(reflection.name) do |*params|
            force_reload = params.first unless params.empty?

            association = instance_variable_get(ivar) if instance_variable_defined?(ivar)

            if association.nil? || force_reload
              association = association_proxy_class.new(self, reflection)
              retval = association.reload
              if retval.nil? and association_proxy_class == BelongsToAssociation
                instance_variable_set(ivar, nil)
                return nil
              end
              instance_variable_set(ivar, association)
            end

            association.target.nil? ? nil : association
          end

          define_method("loaded_#{reflection.name}?") do
            association = instance_variable_get(ivar) if instance_variable_defined?(ivar)
            association && association.loaded?
          end

          define_method("#{reflection.name}=") do |new_value|
            association = instance_variable_get(ivar) if instance_variable_defined?(ivar)

            if association.nil? || association.target != new_value
              association = association_proxy_class.new(self, reflection)
            end

            new_value = reflection.klass.new(new_value) if reflection.options[:accessible] && new_value.is_a?(Hash)

            if association_proxy_class == HasOneThroughAssociation
              association.create_through_record(new_value)
              self.send(reflection.name, new_value)
            else
              association.replace(new_value)
              instance_variable_set(ivar, new_value.nil? ? nil : association)
            end
          end
        end
    end
  end
end
