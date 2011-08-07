require 'spec_helper'

class ParentHasPolymorphicChild < ActiveRecord::Base
  set_table_name 'paranoid_time_columns'
  acts_as_paranoid
  has_one :child, :class_name => 'PolymorphicChild', :as => :polymorphous
  has_one :child_with_millstone, :class_name => 'PolymorphicChildWithDeleted', :as => :polymorphous
end

class PolymorphicChild < ActiveRecord::Base
  set_table_name 'polymorphic_children'
  belongs_to :polymorphous, :polymorphic => true
end

class PolymorphicChildWithDeleted < ActiveRecord::Base
  set_table_name 'polymorphic_children'
  belongs_to :polymorphous, :polymorphic => true, :with_deleted => true
end

describe Millstone::ActiveRecord::Associations::BelongsToPolymorphicAssociation do
  describe ActiveRecord::Base do
    let(:parent) { ParentHasPolymorphicChild.create!(:context => "parent") }

    describe ".belongs_to", "with_deleted => false (default)" do
      let(:record) { parent.create_child(:context => "child") }
      let(:record_which_destroyed_parent) do
        record.polymorphous.destroy
        record.reload
      end

      specify { record.polymorphous.should eq parent }
      specify { record_which_destroyed_parent.polymorphous.should be_nil }
    end

    describe ".belongs_to", "with_deleted => true" do
      let(:record) { parent.create_child_with_millstone(:context => "child") }
      let(:record_which_destroyed_parent) do
        record.polymorphous.destroy
        record.reload
      end

      specify { record.polymorphous.should eq parent }
      specify { record_which_destroyed_parent.polymorphous.should eq parent }
    end
  end
end
