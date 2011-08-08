shared_examples "hide soft deletion marked record" do
  before do 
    klass.delete_all
    3.times { klass.create!(:context => "alive") }
    2.times { klass.create!(:context => "hidden", klass.millstone_column => klass.millstone_generate_column_value) }
  end

  describe ".all" do
    subject { klass.all }
    it { should_not include hidden_record }
    it { should include alive_record }
  end

  describe ".find" do
    specify { klass.find(alive_record).should_not be_nil }

    specify do
      expect { klass.find(hidden_record) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "options :with_deleted" do
      specify { klass.find(hidden_record, :with_deleted => true).should_not be_nil }
      specify { klass.find(alive_record, :with_deleted => true).should_not be_nil }
    end

    context "options :only_deleted" do
      specify { klass.find(hidden_record, :only_deleted => true).should_not be_nil }

      specify do
        expect { klass.find(alive_record, :only_deleted => true) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe ".count" do
    subject { klass.count }
    it "should return record count without hidden record" do
      should == 3
    end
  end

  describe ".with_deleted" do
    describe ".all" do
      subject { klass.with_deleted.all }
      it { should include hidden_record }
      it { should include alive_record }
    end

    describe ".find" do
      context "when specify hidden record" do
        subject { klass.only_deleted.find(hidden_record) }
        it { should eq hidden_record }
      end

      context "when specify alive record" do
        subject { klass.find(alive_record) }
        it { should eq alive_record }
      end
    end

    describe ".count" do
      subject { klass.with_deleted.count }
      it "should return all record count" do
        should == 5
      end
    end
  end

  describe ".only_deleted" do
    describe ".all" do
      subject { klass.only_deleted.all }
      it { should include hidden_record }
      it { should_not include alive_record }
    end

    describe ".find" do
      context "when specify hidden record" do
        subject { klass.only_deleted.find(hidden_record) }
        it { should eq hidden_record }
      end

      context "when specify alive record" do
        it "should raise error ActiveRecord::RecordNotFound" do
          expect do
            klass.only_deleted.find(alive_record)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe ".count" do
      subject { klass.only_deleted.count }
      it "should return only hidden record count" do
        should == 2
      end
    end
  end
end
