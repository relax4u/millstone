module Millstone
  module ActiveRecord
    module RelationMethods
      def self.extended(base)
        base.class_eval do
          attr_accessor :with_deleted_value, :only_deleted_value
        end
      end

      def destroy_all!(conditions = nil)
        if with_deleted_value.nil? and only_deleted_value.nil?
          with_deleted.destroy_all!(conditions)
        elsif conditions
          where(conditions).destroy_all!
        else
          to_a.each {|object| object.destroy! }.tap { reset }
        end
      end

      def destroy!(id)
        if with_deleted_value.nil? and only_deleted_value.nil?
          with_deleted.destroy!(id)
        elsif id.is_a?(Array)
          id.map {|one_id| destroy!(one_id) }
        else
          find(id).destroy!
        end
      end

      def delete_all(conditions = nil)
        conditions ? where(conditions).delete_all : update_all(@klass.paranoid_column => @klass.paranoid_generate_column_value)
      end

      def delete_all!(conditions = nil)
        if with_deleted_value.nil? and only_deleted_value.nil?
          with_deleted.delete_all!(conditions)
        elsif conditions
          where(conditions).delete_all!
        else
          arel.delete.tap { reset }
        end
      end

      def delete(id_or_array)
        where(@klass.primary_key => id_or_array).update_all(@klass.paranoid_column => @klass.paranoid_generate_column_value)
      end

      def delete!(id_or_array)
        where(@klass.primary_key => id_or_array).delete_all!
      end

      def with_deleted(with = true)
        relation = clone
        relation.with_deleted_value = with
        relation
      end

      def only_deleted(only = true)
        relation = clone
        relation.only_deleted_value = only
        relation
      end

      def except(*skips)
        result = super
        ([:with_deleted, :only_deleted] - skips).each do |method|
          result.send(:"#{method}_value=", send(:"#{method}_value"))
        end
        result
      end

      def only(*onlies)
        result = super
        ([:with_deleted, :only_deleted] & onlies).each do |method|
          result.send(:"#{method}_value=", send(:"#{method}_value"))
        end
        result
      end

      private
        def build_arel
          arel = super
          return arel unless @klass.paranoid?

          if @with_deleted_value
            # nothing
          elsif @only_deleted_value
            arel = collapse_wheres(arel, [@klass.send(:sanitize_sql, ["#{@klass.paranoid_column_reference} IS NOT ?", nil])])
          else
            arel = collapse_wheres(arel, [@klass.send(:sanitize_sql, ["#{@klass.paranoid_column_reference} IS ?", nil])])
          end

          arel
        end
    end
  end
end
