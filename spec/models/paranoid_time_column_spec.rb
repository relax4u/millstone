require 'spec_helper'

describe ParanoidTimeColumn do
  let(:klass) { ParanoidTimeColumn }
  let (:alive_record) { ParanoidTimeColumn.create!(:context => "alive") }
  let (:hidden_record) { ParanoidTimeColumn.create!(:context => "hidden", :deleted_at => Time.now) }

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
