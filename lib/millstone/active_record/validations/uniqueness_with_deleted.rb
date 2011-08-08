require 'active_support/core_ext/array/wrap'

module Millstone
  module ActiveRecord
    module Validations
      extend ActiveSupport::Concern

      included do
      end

      class UniquenessWithDeletedValidator < ::ActiveRecord::Validations::UniquenessValidator
        def validate_each(record, attribute, value)
          finder_class = find_finder_class_for(record)
          table = finder_class.unscoped

          table_name   = record.class.quoted_table_name

          if value && record.class.serialized_attributes.key?(attribute.to_s)
            value = YAML.dump value
          end

          sql, params  = mount_sql_and_params(finder_class, table_name, attribute, value)

          relation = table.with_deleted.where(sql, *params)  # find with deleted

          Array.wrap(options[:scope]).each do |scope_item|
            scope_value = record.send(scope_item)
            relation = relation.where(scope_item => scope_value)
          end

          unless record.new_record?
            # TODO : This should be in Arel
            relation = relation.where("#{record.class.quoted_table_name}.#{record.class.primary_key} <> ?", record.send(:id))
          end

          if relation.exists?
            record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
          end
        end
      end

      module ClassMethods
        def validates_uniqueness_of_with_deleted(*attr_names)
          validates_with UniquenessWithDeletedValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
