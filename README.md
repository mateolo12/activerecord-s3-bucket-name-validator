# ActiveModel S3 Bucket Name Validator

ActiveModel validator for Amazon S3 bucket names. It implements the official AWS naming rules for:
- General purpose buckets (classic S3)
- Directory buckets (S3 Express One Zone)
- S3 Tables buckets

Works in any class using ActiveModel::Validations and in Rails/ActiveRecord models. Ships with i18n messages in multiple locales.

## Installation

Add to your Gemfile:

```ruby
gem "activerecord-s3-bucket-name-validator"
```

Then bundle:

```bash
bundle install
```

## Compatibility

- Ruby: 3.1, 3.2, 3.3, 3.4 (CI runs 3.2–3.4)
- ActiveModel: 7.2, 8.0 (CI targets)
- Rails/ActiveRecord: supported via ActiveModel::Validations (no Rails runtime dependency)

## Quickstart

Plain ActiveModel:

```ruby
class StorageConfig
  include ActiveModel::Model
  attr_accessor :bucket_name
  validates :bucket_name, s3_bucket_name: true
end
```

ActiveRecord model:

```ruby
class Storage < ApplicationRecord
  validates :bucket_name, s3_bucket_name: true
end
```

## Options

- `type` — `:general_purpose` (default), `:directory`, or `:table`
- `transfer_acceleration` — when `true`, periods are forbidden for general-purpose buckets

Examples:

```ruby
validates :bucket_name, s3_bucket_name: { transfer_acceleration: true }
validates :bucket_name, s3_bucket_name: { type: :directory }
validates :bucket_name, s3_bucket_name: { type: :table }
```

## i18n

Error keys provided:
- `activemodel.errors.messages.s3_bucket_name_invalid_general`
- `activemodel.errors.messages.s3_bucket_name_invalid_transfer_acceleration`
- `activemodel.errors.messages.s3_bucket_name_invalid_directory`
- `activemodel.errors.messages.s3_bucket_name_invalid_table`

Locales shipped: en, es, it, fr, de, pt-BR, ja, ko, zh-CN, zh-TW, ru, nl.

Rails loads locales via a Railtie; plain ActiveModel loads them at require-time. Override by adding your own YAML with the same keys.

## What’s validated (high level)

- Length 3–63, allowed characters, begin/end alphanumeric
- No adjacent periods; not IP-like (general purpose)
- Reserved prefixes/suffixes per AWS docs (for example `xn--`, `sthree-`, `amzn-s3-demo-`, `-s3alias`, `--ol-s3`, `.mrap`, `--x-s3`, `--table-s3`)
- Directory buckets must end with `--<zone-id>--x-s3`
- S3 Tables buckets disallow periods and underscores
- Optional TA mode forbids periods

Note: Global/partition uniqueness and immutability are service-side constraints and not enforced locally.

## Examples

Valid (general purpose):

```text
my-example-bucket
example.com
```

Invalid (general purpose):

```text
ex..ample
192.168.5.4
xn--abc
foo--x-s3
```

## Running tests (for contributors)

```bash
# ActiveModel-only
bundle install
bundle exec rake test

# With ActiveRecord integration (in-memory sqlite)
AR_INTEGRATION=1 ACTIVERECORD_VERSION="~> 8.0" bundle install
AR_INTEGRATION=1 ACTIVERECORD_VERSION="~> 8.0" bundle exec rake test
```

## License

MIT — see `LICENSE.txt`.
