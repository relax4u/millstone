require 'spec_helper'

class MillstoneTimeColumn < ActiveRecord::Base
  set_table_name 'time_columns'
  acts_as_paranoid
end

class MillstoneBooleanColumn < ActiveRecord::Base
  set_table_name 'boolean_columns'
  acts_as_paranoid :column => :deleted, :type => :boolean
end

describe Millstone::ActiveRecord::RelationMethods do
  let (:alive_record) { klass.create!(:context => "alive") }
  let (:hidden_record) { klass.create!(:context => "hidden", klass.paranoid_column => klass.paranoid_generate_column_value) }

  describe MillstoneTimeColumn do
    let(:klass) { MillstoneTimeColumn }

    it_should_behave_like "hide soft deletion marked record"
    it_should_behave_like "execute soft deletion" do
      it "should set time to paranoid value" do
        klass.delete(alive_record)
        klass.with_deleted.find(alive_record).deleted_at.should be_a Time
      end
    end
    it_should_behave_like "execute hard deletion"
    it_should_behave_like "check soft deletion"
  end

  describe MillstoneBooleanColumn do
    let(:klass) { MillstoneBooleanColumn }

    it_should_behave_like "hide soft deletion marked record"
    it_should_behave_like "execute soft deletion" do
      it "should set true to paranoid value" do
        klass.delete(alive_record)
        klass.with_deleted.find(alive_record).deleted.should be_true
      end
    end
    it_should_behave_like "execute hard deletion"
    it_should_behave_like "check soft deletion"
  end
end
