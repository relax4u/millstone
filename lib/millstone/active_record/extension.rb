require 'millstone/active_record/relation_methods'

module Millstone
  module ActiveRecord
    class AlreadyMarkedDestruction < StandardError
    end

    module Extension
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods
        def paranoid?
          self.included_modules.include?(InstanceMethods)
        end

        def acts_as_paranoid(options = {})
          options = options.reverse_merge(:column => :deleted_at, :type => :time)

          unless [:time, :boolean].include? options[:type]
            raise ArgumentError, "'time' or 'boolean' expected for :type option, got #{options[:type]}"
          end

          class_attribute :paranoid_configuration, :paranoid_column_reference
          self.paranoid_configuration = options
          self.paranoid_column_reference = "#{self.table_name}.#{paranoid_configuration[:column]}"
          
          return if paranoid?

          extend ClassMethods
          include InstanceMethods
        end

        module ClassMethods
          def self.extended(base)
            class << base
              delegate :destroy!, :destroy_all!, :delete!, :delete_all!, :to => :scoped
              delegate :with_deleted, :only_deleted, :to => :scoped
              alias_method_chain :relation, :deleted
            end
          end

          def paranoid_column
            paranoid_configuration[:column].to_sym
          end

          def paranoid_type
            paranoid_configuration[:type].to_sym
          end

          def paranoid_generate_column_value
            case paranoid_type
            when :time then Time.now
            when :boolean then true
            end
          end

          private
            def relation_with_deleted
              relation = relation_without_deleted
              relation.extending Millstone::ActiveRecord::RelationMethods
            end
        end

        module InstanceMethods
          def destroy
            with_transaction_returning_status do
              _run_destroy_callbacks do
                raise AlreadyMarkedDestruction, "#{self.class.name} ID=#{self.id} already marked destruction." unless self.paranoid_value.nil?
                self.class.delete(self.id)
                self.paranoid_value = self.class.paranoid_generate_column_value
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

          def deleted?
            !paranoid_value.nil?
          end

          def paranoid_value
            self.send(self.class.paranoid_column)
          end

          private
            def paranoid_value=(value)
              self.send("#{self.class.paranoid_column}=", value)
            end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Millstone::ActiveRecord::Extension
