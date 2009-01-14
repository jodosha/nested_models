module ActiveRecord
  class Base
    class << self
      alias_method :active_record_update, :update
      def update(id, attributes = nil) #:nodoc:
        if id.is_a?(Array) && id.first.is_a?(Hash)
          id.each { |hash| update(hash.delete(primary_key.to_sym), hash) }
        else
          active_record_update(id, attributes)
        end
      end
      
      def set_accessible_association_destroy_flag(flag)
        self.accessible_association_destroy_flag = flag.to_sym
      end
    end

    class_inheritable_array :accessible_associations
    self.accessible_associations = []

    class_inheritable_accessor :accessible_association_destroy_flag
    self.accessible_association_destroy_flag = :destroy

    alias_method :active_record_attributes=, :attributes=
    def attributes=(new_attributes, guard_protected_attributes = true)
      assign_accessible_associations_attributes(new_attributes)
      send(:active_record_attributes=, new_attributes, guard_protected_attributes)
    end

    protected
      def assign_accessible_associations_attributes(new_attributes)
        (self.class.accessible_associations & new_attributes.keys).each do |association|
          associated_attributes = new_attributes.delete(association)
          association = self.send(association)
          destroy_accessible_associated_records association, associated_attributes
          update_accessible_associated_records  association, associated_attributes
          create_accessible_associated_records  association, associated_attributes
        end
      end

      def create_accessible_associated_records(association, associated_attributes)
        association.build associated_attributes
      end

      def update_accessible_associated_records(association, associated_attributes)
        attrs = extract_update_accessible_attributes(association, associated_attributes)
        association.update attrs unless attrs.empty?
      end

      def destroy_accessible_associated_records(association, associated_attributes)
        attrs = extract_destroy_accessible_attributes(association, associated_attributes)
        association.destroy attrs unless attrs.empty?
      end

      def extract_update_accessible_attributes(association, associated_attributes)
        # TODO use returning instead
        result = associated_attributes.dup
        associated_attributes.reject! {|hash| hash.has_key?(association.primary_key.to_sym)}
        result - associated_attributes
      end
      
      def extract_destroy_accessible_attributes(association, associated_attributes)
        # TODO refactoring!!
        primary_key, destroy_flag = association.primary_key.to_sym, association.accessible_association_destroy_flag
        result = associated_attributes.map do |hash|
          hash[primary_key] if hash[destroy_flag]
        end.compact
        associated_attributes.reject! {|hash| hash[destroy_flag]}
        result
      end
  end
end
