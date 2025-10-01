require "test_helper"

begin
  require "active_record"
rescue LoadError
  ActiveRecord = nil
end

class ARIntegrationTest < Minitest::Test
  def setup
    skip "AR integration disabled" unless ENV["AR_INTEGRATION"] == "1"
    skip "ActiveRecord not available" unless defined?(ActiveRecord)

    # In-memory SQLite database
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Schema.define do
      create_table :storages, force: true do |t|
        t.string :bucket_name
      end
    end

    Object.send(:remove_const, :Storage) if Object.const_defined?(:Storage)
    Object.const_set(:Storage, Class.new(ActiveRecord::Base) do
      self.table_name = "storages"
      validates :bucket_name, s3_bucket_name: true
    end)
  end

  def test_ar_model_validates_bucket_name
    s = Storage.new(bucket_name: "my-example-bucket")
    assert s.valid?, s.errors.full_messages.inspect

    s = Storage.new(bucket_name: "Bad_Bucket")
    refute s.valid?
  end
end
