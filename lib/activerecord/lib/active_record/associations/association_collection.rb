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
        load_target

        transaction do
          destroy_accessible_associated_records other_array
          update_accessible_associated_records  other_array
          create_accessible_associated_records  other_array
        end
      end

      private
        def create_accessible_associated_records(records)
          records.map! { |record| build_accessible_record(record) }.each(&:save)
          concat(records)
        end

        def update_accessible_associated_records(records)
          update_records = extract_update_accessible_records(records)
          update_records.each do |record|
            id = record.delete(primary_key)
            @reflection.klass.update(id, record)
          end
        end

        def destroy_accessible_associated_records(records)
          delete(extract_destroy_accessible_records(records))
        end

        def extract_update_accessible_records(records)
          # TODO use returning instead
          result = records.dup
          records.reject! { |record| !record[primary_key].blank? }
          result - records
        end

        def extract_destroy_accessible_records(records)
          # TODO use returning instead
          result = records.dup
          records.reject! { |record| record[destroy_flag] }
          (result - records).map { |record| build_accessible_record(record) }
        end

        def build_accessible_record(attributes)
          id = attributes.delete(primary_key)
          record = build_record(attributes)
          unless id.blank?
            record[primary_key.to_s] = id
            record.instance_variable_set(:@new_record, false) # avoid database fetch
          end
          raise_on_type_mismatch(record)
          record
        end

        def primary_key
          @primary_key ||= @reflection.klass.primary_key.to_sym
        end
        
        def destroy_flag
          @destroy_flag ||= @reflection.klass.accessible_association_destroy_flag
        end
    end
  end
end
