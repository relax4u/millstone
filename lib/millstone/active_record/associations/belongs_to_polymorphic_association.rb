module Millstone
  module ActiveRecord
    module Associations
      class BelongsToPolymorphicAssociation < ::ActiveRecord::Associations::BelongsToPolymorphicAssociation
        private
          def find_target
            association_class.try(:send, :with_scope, :find => {:with_deleted => true}) do
              super
            end
          end
      end
    end
  end
end
