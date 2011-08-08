require 'millstone/active_record/relation_methods'
require 'millstone/active_record/validations/uniqueness_with_deleted'

module Millstone
  module ActiveRecord
    class AlreadyMarkedDeletion < StandardError
    end

    module Extension
      extend ActiveSupport::Concern

      included do
        class << self
          # for acts_as_paranoid
          alias_method :acts_as_paranoid, :millstone
          alias_method :paranoid?, :as_millstone?
        end
      end

      module ClassMethods
        def as_millstone?
          self.included_modules.include?(InstanceMethods)
        end

        def millstone(options = {})
          options = options.reverse_merge(:column => :deleted_at, :type => :time)

          unless [:time, :boolean].include? options[:type]
            raise ArgumentError, "'time' or 'boolean' expected for :type option, got #{options[:type]}"
          end

          class_attribute :millstone_configuration, :millstone_column_reference
          self.millstone_configuration = options
          self.millstone_column_reference = "#{self.table_name}.#{millstone_configuration[:column]}"
          
          return if as_millstone?

          extend ClassMethods
          include InstanceMethods
          include Validations

          self.class_eval do
            alias_method :paranoid_value, :millstone_column_value
          end

          class << self
            delegate :destroy!, :destroy_all!, :delete!, :delete_all!, :to => :scoped
            delegate :with_deleted, :only_deleted, :to => :scoped
            alias_method_chain :relation, :millstone

            # for acts_as_paranoid
            alias_method :paranoid_column, :millstone_column
            alias_method :paranoid_column_type, :millstone_type
            alias_method :paranoid_column_reference, :millstone_column_reference
            alias_method :paranoid_configuration, :millstone_configuration
          end
        end

        module ClassMethods
          def millstone_column
            millstone_configuration[:column].to_sym
          end

          def millstone_type
            millstone_configuration[:type].to_sym
          end

          def millstone_generate_column_value
            case millstone_type
            when :time then Time.now
            when :boolean then true
            end
          end

          def millstone_without_deleted_conditions
            sanitize_sql(["#{millstone_column_reference} IS ?", nil])
          end

          def millstone_only_deleted_conditions
            sanitize_sql(["#{millstone_column_reference} IS NOT ?", nil])
          end

          private
            def relation_with_millstone
              relation = relation_without_millstone
              relation.extending Millstone::ActiveRecord::RelationMethods
            end
        end

        module InstanceMethods
          def destroy
            with_transaction_returning_status do
              _run_destroy_callbacks do
                raise AlreadyMarkedDeletion, "#{self.class.name} ID=#{self.id} already marked deletion." unless self.millstone_column_value.nil?
                self.class.delete(self.id)
                self.millstone_column_value = self.class.millstone_generate_column_value
                freeze
              end
            end
          end

          def destroy!
            with_transaction_returning_status do
              _run_destroy_callbacks do
                self.class.delete!(self.id)
                freeze
              end
            end
          end

          def recover(options = {})
            raise "Millstone is not support"
          end

          def recover_dependent_associations(window, options = {})
            raise "Millstone is not support"
          end

          def deleted?
            !millstone_column_value.nil?
          end

          def millstone_column_value
            self.send(self.class.millstone_column)
          end

          private
            def millstone_column_value=(value)
              self.send("#{self.class.millstone_column}=", value)
            end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Millstone::ActiveRecord::Extension
