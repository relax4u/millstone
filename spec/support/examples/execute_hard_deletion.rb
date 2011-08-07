shared_examples "delete alive and hidden record" do
  specify "alive record should be deleted from table" do
    expect { klass.with_deleted.find(alive_record) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  specify "hidden record should be deleted from table" do
    expect { klass.with_deleted.find(hidden_record) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

shared_examples "execute hard deletion" do
  describe ".delete!" do
    it_behaves_like "delete alive and hidden record" do
      before do
        klass.delete!([alive_record, hidden_record])
      end
    end
  end

  describe ".delete_all!" do
    it_behaves_like "delete alive and hidden record" do
      before do
        klass.delete_all!(["id IN (?)", [alive_record, hidden_record]])
      end
    end
  end

  describe ".destroy!" do
    it_behaves_like "delete alive and hidden record" do
      before do
        klass.destroy!([alive_record, hidden_record])
      end
    end
  end

  describe ".destroy_all!" do
    it_behaves_like "delete alive and hidden record" do
      before do
        klass.destroy_all!(["id IN (?)", [alive_record, hidden_record]])
      end
    end
  end
end
