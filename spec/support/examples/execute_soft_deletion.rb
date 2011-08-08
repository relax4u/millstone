shared_examples "execute soft deletion" do
  describe ".delete_all" do
    it "should mark deletion to alive record" do
      expect do
        klass.delete_all(:id => alive_record)
      end.should change { klass.with_deleted.find(alive_record).millstone_column_value }
    end

    it "should not mark deletion to hidden record" do
      expect do
        klass.delete_all(:id => hidden_record)
      end.should_not change { klass.with_deleted.find(hidden_record).millstone_column_value }
    end
  end

  describe ".delete" do
    it "should mark deletion to alive record" do
      expect do
        klass.delete(alive_record)
      end.should change { klass.with_deleted.find(alive_record).millstone_column_value }
    end

    it "should not mark deletion to hidden record" do
      expect do
        klass.delete(hidden_record)
      end.should_not change { klass.with_deleted.find(hidden_record).millstone_column_value }
    end
  end

  describe ".destroy_all" do
    it "should mark deletion to alive record" do
      expect do
        klass.destroy_all(:id => alive_record)
      end.should change { klass.with_deleted.find(alive_record).millstone_column_value }
    end

    it "should not mark deletion to hidden record" do
      expect do
        klass.destroy_all(:id => hidden_record)
      end.should_not change { klass.with_deleted.find(hidden_record).millstone_column_value }
    end
  end

  describe ".destroy" do
    it "should mark deletion to alive record" do
      expect do
        klass.destroy(alive_record)
      end.should change { klass.with_deleted.find(alive_record).millstone_column_value }
    end

    it "should not mark deletion to hidden record" do
      expect do
        klass.destroy(hidden_record)
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
