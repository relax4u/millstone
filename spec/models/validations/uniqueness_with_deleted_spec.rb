require 'spec_helper'

class UniquenessWithDeleted < ActiveRecord::Base
  set_table_name 'time_columns'

  acts_as_paranoid
  validates_uniqueness_of_with_deleted :context
end

class UniquenessWithoutDeleted < ActiveRecord::Base
  set_table_name 'time_columns'

  acts_as_paranoid
  validates_uniqueness_of :context
end

describe Millstone::ActiveRecord::Validations::UniquenessWithDeletedValidator do
  describe ActiveRecord::Base do
    describe ".validates_uniqueness_of" do
      let(:alive_record) { UniquenessWithoutDeleted.create(:context => "unique1") }
      let(:hidden_record) do
        hidden_record = UniquenessWithoutDeleted.create(:context => "unique2")
        hidden_record.destroy
        hidden_record
      end

      specify { UniquenessWithoutDeleted.new(:context => alive_record.context).should_not be_valid }
      specify { UniquenessWithoutDeleted.new(:context => hidden_record.context).should be_valid }
    end

    describe ".validates_uniqueness_of_with_deleted" do
      let(:alive_record) { UniquenessWithDeleted.create(:context => "unique1") }
      let(:hidden_record) do
        hidden_record = UniquenessWithDeleted.create(:context => "unique2")
        hidden_record.destroy
        hidden_record
      end

      specify { UniquenessWithDeleted.new(:context => alive_record.context).should_not be_valid }
      specify { UniquenessWithDeleted.new(:context => hidden_record.context).should_not be_valid }
    end
  end
end
