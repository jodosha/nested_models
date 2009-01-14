module ActiveRecord
  class Base
    class_inheritable_array :accessible_associations
    self.accessible_associations = []

    alias_method :active_record_attributes=, :attributes=
    def attributes=(new_attributes, guard_protected_attributes = true)
      assign_accessible_associations_attributes(new_attributes)
      send(:active_record_attributes=, new_attributes, guard_protected_attributes)
    end
    
    protected
      def assign_accessible_associations_attributes(new_attributes)
        (self.class.accessible_associations & new_attributes.keys).each do |association|
          self.send(association).build new_attributes.delete(association)
        end
      end
  end
end
