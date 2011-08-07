require 'spec_helper'

describe ParanoidBooleanColumn do
  let(:klass) { ParanoidBooleanColumn }
  let (:alive_record) { klass.create!(:context => "alive") }
  let (:hidden_record) { klass.create!(:context => "hidden", klass.paranoid_column => klass.paranoid_generate_column_value) }

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
