require "activerecord/s3/bucket/name/validator/version"
require "active_model"
require "i18n"
begin
  require "activerecord/s3/bucket/name/validator/railtie"
rescue LoadError
  # Rails not present; ignore
end

module Activerecord
  module S3
    module Bucket
      module Name
        module Validator
          # Validator implementation lives at top-level constant so Rails can autoload it
        end
      end
    end
  end
end

# Load embedded translations when not in Rails (Rails will pick them up via Railtie below)
begin
  locales_glob = File.expand_path("../../../../../config/locales/*.yml", __FILE__)
  I18n.load_path += Dir[locales_glob] if Dir.exist?(File.dirname(locales_glob))
rescue StandardError
  # ignore i18n loading errors
end

# Usage in a model:
#   validates :bucket_name, s3_bucket_name: { type: :general_purpose }
# Options:
#   :type => :general_purpose (default), :directory, or :table
#   :transfer_acceleration => true to forbid periods for TA buckets
class S3BucketNameValidator < ActiveModel::EachValidator
  RESERVED_PREFIXES_GENERAL = %w[xn-- sthree- amzn-s3-demo-].freeze
  RESERVED_SUFFIXES_GENERAL = %w[-s3alias --ol-s3 .mrap --x-s3 --table-s3].freeze

  RESERVED_PREFIXES_TABLE = %w[xn-- sthree- amzn-s3-demo- aws].freeze
  RESERVED_SUFFIXES_TABLE = %w[-s3alias --ol-s3 --x-s3 --table-s3].freeze

  def validate_each(record, attribute, value)
    type = (options[:type] || :general_purpose).to_sym
    return if blank_ok?(value)

    valid = case type
            when :general_purpose then validate_general_purpose(value, transfer_acceleration: !!options[:transfer_acceleration])
            when :directory then validate_directory_bucket(value)
            when :table then validate_table_bucket(value)
            else
              record.errors.add(attribute, :invalid, message: "unknown bucket type: #{type}")
              false
            end

    unless valid
      error_key = if type == :general_purpose && options[:transfer_acceleration] && value.include?(".")
                    :s3_bucket_name_invalid_transfer_acceleration
                  else
                    case type
                    when :general_purpose then :s3_bucket_name_invalid_general
                    when :directory then :s3_bucket_name_invalid_directory
                    when :table then :s3_bucket_name_invalid_table
                    else :s3_bucket_name_invalid
                    end
                  end
      record.errors.add(attribute, error_key)
    end
  end

  private

  # I18n error messages are defined in config/locales/*.yml

  def blank_ok?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?)
  end

  # Based on AWS docs: General purpose bucket naming rules
  def validate_general_purpose(name, transfer_acceleration: false)
    return false unless length_between?(name, 3, 63)
    return false unless name =~ /\A[a-z0-9.-]+\z/
    return false unless begins_and_ends_with_alnum?(name)
    return false if name.include?("..")
    return false if ip_like?(name)
    return false unless RESERVED_PREFIXES_GENERAL.none? { |p| name.start_with?(p) }
    return false unless RESERVED_SUFFIXES_GENERAL.none? { |s| name.end_with?(s) }
    return false if transfer_acceleration && name.include?(".")
    true
  end

  # Based on AWS docs: Directory bucket naming rules (S3 Express One Zone)
  def validate_directory_bucket(name)
    return false unless length_between?(name, 3, 63)
    return false unless name =~ /\A[a-z0-9-]+\z/
    return false unless begins_and_ends_with_alnum?(name)
    # must contain --<zone-id>--x-s3 suffix
    return false unless name =~ /--[a-z0-9-]+--x-s3\z/
    # reserved prefixes/suffixes still apply
    return false if name.start_with?("xn--", "sthree-", "sthree-configurator", "amzn-s3-demo-")
    return false if name.end_with?("-s3alias", "--ol-s3", ".mrap", "--table-s3")
    true
  end

  # Based on AWS docs: S3 Tables bucket naming rules
  def validate_table_bucket(name)
    return false unless length_between?(name, 3, 63)
    return false unless name =~ /\A[a-z0-9-]+\z/
    return false unless begins_and_ends_with_alnum?(name)
    return false unless RESERVED_PREFIXES_TABLE.none? { |p| name.start_with?(p) }
    return false unless RESERVED_SUFFIXES_TABLE.none? { |s| name.end_with?(s) }
    true
  end

  def length_between?(str, min, max)
    str.length.between?(min, max)
  end

  def begins_and_ends_with_alnum?(str)
    str[0] =~ /[a-z0-9]/ && str[-1] =~ /[a-z0-9]/
  end

  def ip_like?(str)
    str =~ /\A(?:\d{1,3}\.){3}\d{1,3}\z/
  end
end
