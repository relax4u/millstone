require 'spec_helper'

class HasOneParent < ActiveRecord::Base
  set_table_name 'paranoid_time_columns'
  has_one :child, :class_name => 'HasOneChild', :foreign_key => 'parent_id'
end

class HasOneParentWithDeleted < ActiveRecord::Base
  set_table_name 'paranoid_time_columns'
  has_one :child, :class_name => 'HasOneChild', :foreign_key => 'parent_id', :with_deleted => true
end

class HasOneChild < ActiveRecord::Base
  set_table_name 'paranoid_children_time_columns'
  acts_as_paranoid
end

describe Millstone::ActiveRecord::Associations::HasOneAssociationMethods do
  describe ActiveRecord::Base do
    describe ".has_one", "with_deleted => false (default)" do
      let(:parent_has_child) do
        record = HasOneParent.create!(:context => "parent")
        record.create_child(:context => "child")
        record
      end

      let(:parent_has_destroyed_child) do
        parent_has_child.child.destroy
        parent_has_child.reload
      end

      specify { parent_has_child.child.should_not be_nil }
      specify { parent_has_destroyed_child.child.should be_nil }
    end

    describe ".has_one", "with_deleted => true" do
      let(:parent_has_child) do
        record = HasOneParentWithDeleted.create!(:context => "parent")
        record.create_child(:context => "child")
        record
      end

      let(:parent_has_destroyed_child) do
        parent_has_child.child.destroy
        parent_has_child.reload
      end

      specify { parent_has_child.child.should_not be_nil }
      specify { parent_has_destroyed_child.child.should_not be_nil }
    end
  end
end

