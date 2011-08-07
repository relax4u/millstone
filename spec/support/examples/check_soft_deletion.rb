shared_examples "check soft deletion" do
  describe "#deleted?" do
    specify { alive_record.should_not be_deleted }
    specify { hidden_record.should be_deleted }
  end
end
