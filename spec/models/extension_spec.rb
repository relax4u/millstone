require 'spec_helper'

class MillstoneTimeModel < ActiveRecord::Base
  set_table_name 'time_columns'
  millstone
end

class MillstoneBooleanModel < ActiveRecord::Base
  set_table_name 'boolean_columns'
  millstone :column => :deleted, :type => :boolean
end

describe Millstone::ActiveRecord::Extension do
  describe ActiveRecord::Base do
    let(:record) { klass.create!(:context => "name") }
    let(:deleted_record) { klass.with_deleted.first }

    shared_examples "execute destroy and destroy!" do
      describe "#destroy" do
        before { record.destroy }

        specify { deleted_record.should eq record }
        specify { deleted_record.should be_deleted }
      end

      describe "#destroy!" do
        before { record.destroy! }
        specify { deleted_record.should be_nil }
      end
    end

    context "as millstone :type => :boolean" do
      let(:klass) { MillstoneBooleanModel }

      it_behaves_like "execute destroy and destroy!"

      describe "#destroy" do
        before { record.destroy }
        specify { deleted_record.deleted.should be_true }
      end
    end

    context "as millstone :type => :time" do
      before { Delorean.time_travel_to 1.hour.ago }
      after { Delorean.back_to_the_present }

      let(:klass) { MillstoneTimeModel }

      describe "#destroy" do
        before { record.destroy }
        specify { deleted_record.deleted_at.to_s.should == Time.now.to_s }
      end
    end
  end
end
