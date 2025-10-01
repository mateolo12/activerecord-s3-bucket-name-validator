
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activerecord/s3/bucket/name/validator/version"

Gem::Specification.new do |spec|
  spec.name          = "activerecord-s3-bucket-name-validator"
  spec.version       = Activerecord::S3::Bucket::Name::Validator::VERSION
  spec.authors       = ["Claudio Poli"]
  spec.email         = ["masterkain@gmail.com"]

  spec.summary       = %q{ActiveModel/ActiveRecord validator for Amazon S3 bucket naming rules}
  spec.description   = %q{Validate S3 bucket names on your models against the official AWS rules (general purpose, directory buckets, and S3 Tables).}
  spec.homepage      = "https://example.com/activerecord-s3-bucket-name-validator"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "https://example.com/activerecord-s3-bucket-name-validator"
    # spec.metadata["changelog_uri"] = "https://example.com/activerecord-s3-bucket-name-validator/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1"

  # Runtime dependencies
  spec.add_dependency "activemodel", ">= 7.0", "< 9"
  spec.add_dependency "i18n", ">= 1.0"

  # Development and test dependencies
  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "minitest", ">= 5.0"
end
