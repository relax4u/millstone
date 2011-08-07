module Millstone::ActiveRecord::Associations
  module HasOneAssociationMethods
    extend ActiveSupport::Concern

    included do
      alias_method :find_target_without_deleted, :find_target
      alias_method :find_target, :find_target_with_paranoid
    end

    module InstanceMethods
      private
        def find_target_with_paranoid
          if @reflection.klass.paranoid? and @reflection.options[:with_deleted]
            find_target_with_deleted
          else
            find_target_without_deleted
          end
        end

        def find_target_with_deleted
          @reflection.klass.send(:with_scope, :find => {:with_deleted => true}) do
            find_target_without_deleted
          end
        end
    end
  end
end

class ActiveRecord::Base
  valid_keys_for_has_one_association.push :with_deleted
end

ActiveRecord::Associations::HasOneAssociation.send :include, Millstone::ActiveRecord::Associations::HasOneAssociationMethods
