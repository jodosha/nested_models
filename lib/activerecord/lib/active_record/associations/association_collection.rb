require 'set'

module ActiveRecord #:nodoc:
  module Associations #:nodoc:
    class AssociationCollection < AssociationProxy #:nodoc:
      def replace(other_array) #:nodoc:
        other_array.map! do |val|
          id = val.delete(primary_key.to_sym)
          record = build_record(val)
          if id
            record[primary_key] = id
            record.instance_variable_set(:@new_record, false) # avoid to fetch from the database
          end
          record
        end if @reflection.options[:accessible]

        other_array.each { |val| raise_on_type_mismatch(val) }

        load_target
        other   = other_array.size < 100 ? other_array : other_array.to_set
        current = @target.size < 100 ? @target : @target.to_set

        transaction do
          if @reflection.options[:accessible]
            destroy_accessible_associated_records other_array
            update_accessible_associated_records  other_array
            create_accessible_associated_records  other_array
          else
            delete(@target.select { |v| !other.include?(v) })
            concat(other_array.select { |v| !current.include?(v) })
          end
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
