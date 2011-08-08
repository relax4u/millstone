module Millstone
  module ActiveRecord
    module Associations
      class HasManyThroughWithoutDeletedAssociation < ::ActiveRecord::Associations::HasManyThroughAssociation
        def construct_conditions
          return super unless @reflection.through_reflection.klass.paranoid?

          table_name = @reflection.through_reflection.quoted_table_name
          conditions = construct_quoted_owner_attributes(@reflection.through_reflection).map do |attr, value|
            "#{table_name}.#{attr} = #{value}"
          end
          conditions << @reflection.through_reflection.klass.millstone_without_deleted_conditions
          conditions << sql_conditions if sql_conditions
          "(" + conditions.join(') AND (') + ")"
        end
      end
    end
  end
end
