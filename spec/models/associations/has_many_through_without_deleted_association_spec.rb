require 'spec_helper'

class Master < ActiveRecord::Base
end

class HavingWithDeleted < ActiveRecord::Base
  set_table_name 'havings'

  acts_as_paranoid
  belongs_to :parent, :class_name => 'ParentHasMaster', :foreign_key => 'parent_id'
  belongs_to :master
end

class HavingWithoutDeleted < ActiveRecord::Base
  set_table_name 'havings'

  acts_as_paranoid
  belongs_to :parent, :class_name => 'ParentHasMaster', :foreign_key => 'parent_id'
  belongs_to :master
end

class ParentHasMaster < ActiveRecord::Base
  set_table_name 'time_columns'

  has_many :havings_with_deleted, :class_name => 'HavingWithDeleted', :foreign_key => 'parent_id'
  has_many :havings_without_deleted, :class_name => 'HavingWithoutDeleted', :foreign_key => 'parent_id'

  has_many :masters_with_deleted, :class_name => 'Master', :through => :havings_with_deleted, :source => :master, :with_deleted => true
  has_many :masters_without_deleted, :class_name => 'Master', :through => :havings_without_deleted, :source => :master
end

describe Millstone::ActiveRecord::Associations::HasManyThroughWithoutDeletedAssociation do
  describe ActiveRecord::Base do
    let(:parent) { ParentHasMaster.create!(:context => "parent") }
    let(:master1) { Master.create!(:context => "master1") }
    let(:master2) { Master.create!(:context => "master2") }

    describe ".has_many", ":with_deleted => false (default)" do
      before do
        parent.masters_without_deleted << master1
        parent.masters_without_deleted << master2
        parent.masters_without_deleted.delete(master2)
        parent.reload
      end

      specify { parent.masters_without_deleted.should include master1 }
      specify { parent.masters_without_deleted.should_not include master2 }
    end

    describe ".has_many", ":with_deleted => true" do
      before do
        parent.masters_with_deleted << master1
        parent.masters_with_deleted << master2
        parent.masters_with_deleted.delete(master2)
        parent.reload
      end

      specify { parent.masters_with_deleted.should include master1 }
      specify { parent.masters_with_deleted.should include master2 }
    end
  end
end
