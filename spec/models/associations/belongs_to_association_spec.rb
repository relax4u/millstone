require 'spec_helper'

class ParentHasChild < ActiveRecord::Base
  set_table_name 'time_columns'
  acts_as_paranoid
  has_one :child, :class_name => 'Child', :foreign_key => 'parent_id'
  has_one :child_with_millstone, :class_name => 'ChildWithDeleted', :foreign_key => 'parent_id'
end

class Child < ActiveRecord::Base
  set_table_name 'children'
  belongs_to :parent, :class_name => 'ParentHasChild', :foreign_key => 'parent_id'
end

class ChildWithDeleted < ActiveRecord::Base
  set_table_name 'children'
  belongs_to :parent, :class_name => 'ParentHasChild', :foreign_key => 'parent_id', :with_deleted => true
end

describe Millstone::ActiveRecord::Associations::BelongsToAssociation do
  describe ActiveRecord::Base do
    let(:parent) { ParentHasChild.create!(:context => "parent") }

    describe ".belongs_to", "with_deleted => false (default)" do
      let(:record) { parent.create_child(:context => "child") }
      let(:record_which_destroyed_parent) do
        record.parent.destroy
        record.reload
      end

      specify { record.parent.should eq parent }
      specify { record_which_destroyed_parent.parent.should be_nil }
    end

    describe ".belongs_to", "with_deleted => true" do
      let(:record) { parent.create_child_with_millstone(:context => "child") }
      let(:record_which_destroyed_parent) do
        record.parent.destroy
        record.reload
      end

      specify { record.parent.should eq parent }
      specify { record_which_destroyed_parent.parent.should eq parent }
    end
  end
end
