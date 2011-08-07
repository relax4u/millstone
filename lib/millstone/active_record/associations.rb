require 'millstone/active_record/associations/belongs_to_association'
require 'millstone/active_record/associations/belongs_to_polymorphic_association'
require 'millstone/active_record/associations/has_many_through_without_deleted_association'

module Millstone
  module ActiveRecord
    module Associations
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method_chain :has_many, :millstone
          alias_method_chain :belongs_to, :millstone
        end
      end

      module ClassMethods
        def has_many_with_millstone(association_id, options = {}, &extension)
          with_deleted = options.delete :with_deleted
          has_many_without_millstone(association_id, options, &extension).tap do
            reflection = reflect_on_association(association_id)

            if options[:through] and reflection.through_reflection.klass.paranoid? and !with_deleted
              collection_accessor_methods(reflection, Millstone::ActiveRecord::Associations::HasManyThroughWithoutDeletedAssociation)
            end
          end
        end

        def belongs_to_with_millstone(association_id, options = {})
          with_deleted = options.delete :with_deleted
          belongs_to_without_millstone(association_id, options).tap do
            if with_deleted
              reflection = reflect_on_association(association_id)
              
              if reflection.options[:polymorphic]
                association_accessor_methods(reflection, Millstone::ActiveRecord::Associations::BelongsToPolymorphicAssociation)
              else
                association_accessor_methods(reflection, Millstone::ActiveRecord::Associations::BelongsToAssociation)
                association_constructor_method(:build, reflection, Millstone::ActiveRecord::Associations::BelongsToAssociation)
                association_constructor_method(:create, reflection, Millstone::ActiveRecord::Associations::BelongsToAssociation)
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Millstone::ActiveRecord::Associations
