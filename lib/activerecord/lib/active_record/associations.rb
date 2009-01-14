module ActiveRecord
  module Associations
    module ClassMethods
      alias_method :active_record_has_many, :has_many
      def has_many(association_id, options = {}, &extension) #:nodoc:
        active_record_has_many(association_id, options, &extension)
        self.accessible_associations << association_id if options[:accessible]
      end

      valid_keys_for_has_many_association << :accessible
    end
  end
end
