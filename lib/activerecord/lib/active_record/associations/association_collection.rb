require 'set'

module ActiveRecord #:nodoc:
  module Associations #:nodoc:
    class AssociationCollection < AssociationProxy #:nodoc:
      alias_method :replace_without_accessible_collection, :replace
      def replace(other_array) #:nodoc:
        if @reflection.options[:accessible]
          replace_with_accessible_collection(other_array)
        else
          replace_without_accessible_collection(other_array)
        end
      end

      def replace_with_accessible_collection(other_array) #:nodoc:
        other_array.map! do |val|
          id = val.delete(primary_key.to_sym)
          record = build_record(val)
          unless id.blank?
            record[primary_key] = id
            record.instance_variable_set(:@new_record, false) # avoid database fetch
          end
          record
        end

        other_array.each { |val| raise_on_type_mismatch(val) }

        load_target
        transaction do
          destroy_accessible_associated_records other_array
          update_accessible_associated_records  other_array
          create_accessible_associated_records  other_array
        end
      end

      private
        def create_accessible_associated_records(records)
          records.each(&:save)
          concat(records)
        end
      
        def update_accessible_associated_records(records)
          update_records = extract_update_accessible_records(records)
          update_records.each do |record|
            attributes = record.attributes
            id = attributes.delete(primary_key)
            @reflection.klass.update(id, attributes)
          end
          concat(update_records)
        end

        def destroy_accessible_associated_records(records)
          delete(extract_destroy_accessible_records(records))
        end

        def extract_update_accessible_records(records)
          # TODO use returning instead
          result = records.dup
          records.reject! { |record| !record.new_record? }
          result - records
        end

        def extract_destroy_accessible_records(records)
          # TODO use returning instead
          result = records.dup
          records.reject! { |record| record.destroyable? }
          result - records
        end
        
        def primary_key
          @primary_key ||= @reflection.klass.primary_key
        end
        
        def destroy_flag
          @destroy_flag ||= @reflection.klass.accessible_association_destroy_flag
        end
    end
  end
end
