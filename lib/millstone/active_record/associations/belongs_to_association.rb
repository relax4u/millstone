module Millstone
  module ActiveRecord
    module Associations
      class BelongsToAssociation < ::ActiveRecord::Associations::BelongsToAssociation
        private
          def find_target
            @reflection.klass.send(:with_scope, :find => {:with_deleted => true}) do
              super
            end
          end
      end
    end
  end
end
