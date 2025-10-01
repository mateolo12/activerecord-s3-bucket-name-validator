require "test_helper"
require "active_model"

class TestModel
  include ActiveModel::Model
  attr_accessor :bucket_name

  validates :bucket_name, s3_bucket_name: true
end

class TA_Model
  include ActiveModel::Model
  attr_accessor :bucket_name

  validates :bucket_name, s3_bucket_name: { transfer_acceleration: true }
end

class DirectoryModel
  include ActiveModel::Model
  attr_accessor :bucket_name

  validates :bucket_name, s3_bucket_name: { type: :directory }
end

class TableModel
  include ActiveModel::Model
  attr_accessor :bucket_name

  validates :bucket_name, s3_bucket_name: { type: :table }
end

class Activerecord::S3::Bucket::Name::ValidatorTest < Minitest::Test
  def test_version_exists
    refute_nil ::Activerecord::S3::Bucket::Name::Validator::VERSION
  end

  def test_valid_general_purpose_names
    m = TestModel.new(bucket_name: "my-example-bucket")
    assert m.valid?, m.errors.full_messages.inspect

    m = TestModel.new(bucket_name: "example.com")
    assert m.valid?, "Periods are allowed for general purpose buckets"

    # Max length 63
    name = ("a" * 61) + "-b"  # 63 chars, starts/ends alnum
    m = TestModel.new(bucket_name: name)
    assert m.valid?, "63-char names should be valid"
  end

  def test_invalid_general_purpose_names
    # Too short
    refute TestModel.new(bucket_name: "ab").valid?
    # Too long (64)
    refute TestModel.new(bucket_name: "a" * 64).valid?
    # Uppercase not allowed
    refute TestModel.new(bucket_name: "BadBucket").valid?
    # Underscore not allowed
    refute TestModel.new(bucket_name: "bad_bucket").valid?
    # IP-like
    refute TestModel.new(bucket_name: "192.168.5.4").valid?
    # Double period
    refute TestModel.new(bucket_name: "ex..ample").valid?
    # Reserved prefix/suffix
    refute TestModel.new(bucket_name: "xn--abc").valid?
    refute TestModel.new(bucket_name: "sthree-bucket").valid?
    refute TestModel.new(bucket_name: "amzn-s3-demo-bucket").valid?
    refute TestModel.new(bucket_name: "foo--x-s3").valid?
    # Reserved suffixes
    refute TestModel.new(bucket_name: "foo-s3alias").valid?
    refute TestModel.new(bucket_name: "foo.mrap").valid?
    refute TestModel.new(bucket_name: "foo--table-s3").valid?
    refute TestModel.new(bucket_name: "foo--ol-s3").valid?
    # Must begin/end alphanumeric
    refute TestModel.new(bucket_name: "-foo").valid?
    refute TestModel.new(bucket_name: "foo-").valid?
    refute TestModel.new(bucket_name: "foo.").valid?
  end

  def test_transfer_acceleration_forbids_periods
    m = TA_Model.new(bucket_name: "my.example")
    refute m.valid?
    m = TA_Model.new(bucket_name: "my-example")
    assert m.valid?, m.errors.full_messages.inspect
  end

  def test_directory_bucket
    # Valid: has zone id and suffix
    d = DirectoryModel.new(bucket_name: "my-bucket--usw2-az1--x-s3")
    assert d.valid?, d.errors.full_messages.inspect

    # Invalid: missing suffix
    d = DirectoryModel.new(bucket_name: "my-bucket")
    refute d.valid?

    # Invalid: reserved prefix sthree-configurator
    d = DirectoryModel.new(bucket_name: "sthree-configurator-foo--usw2-az1--x-s3")
    refute d.valid?
    # Must begin/end alphanumeric
    d = DirectoryModel.new(bucket_name: "-foo--usw2-az1--x-s3")
    refute d.valid?
    d = DirectoryModel.new(bucket_name: "foo--usw2-az1--x-s3-")
    refute d.valid?
    # Invalid: reserved prefixes
    d = DirectoryModel.new(bucket_name: "xn--foo--usw2-az1--x-s3")
    refute d.valid?
    d = DirectoryModel.new(bucket_name: "sthree-foo--usw2-az1--x-s3")
    refute d.valid?
    d = DirectoryModel.new(bucket_name: "amzn-s3-demo-foo--usw2-az1--x-s3")
    refute d.valid?
    # Invalid: bad characters
    d = DirectoryModel.new(bucket_name: "bad.dot--usw2-az1--x-s3")
    refute d.valid?
    d = DirectoryModel.new(bucket_name: "bad_underscore--usw2-az1--x-s3")
    refute d.valid?
    # Invalid: bad or missing zone id pattern
    d = DirectoryModel.new(bucket_name: "foo----x-s3")
    refute d.valid?
    # length > 63
    long_base = "a" * 60
    d = DirectoryModel.new(bucket_name: "#{long_base}--usw2-az1--x-s3")
    refute d.valid?
  end

  def test_table_bucket
    t = TableModel.new(bucket_name: "table-bucket-1")
    assert t.valid?

    t = TableModel.new(bucket_name: "bad.bucket")
    refute t.valid?
    t = TableModel.new(bucket_name: "bad_bucket")
    refute t.valid?
    t = TableModel.new(bucket_name: "aws-tables")
    refute t.valid?
    t = TableModel.new(bucket_name: "-tables")
    refute t.valid?
    # End hyphen
    t = TableModel.new(bucket_name: "tables-")
    refute t.valid?
    # Uppercase
    t = TableModel.new(bucket_name: "Badtables")
    refute t.valid?
    # Too long
    t = TableModel.new(bucket_name: "a" * 64)
    refute t.valid?
    # Reserved prefixes
    %w[xn-- sthree- amzn-s3-demo-].each do |p|
      t = TableModel.new(bucket_name: "#{p}foo")
      refute t.valid?
    end
    # Reserved suffixes
    %w[-s3alias --ol-s3 --x-s3 --table-s3].each do |s|
      t = TableModel.new(bucket_name: "foo#{s}")
      refute t.valid?
    end
  end
end
