source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Allow CI to pin a specific ActiveModel version via env var
am_ver = ENV["ACTIVEMODEL_VERSION"]
gem "activemodel", am_ver if am_ver

# Optional: ActiveRecord integration testing
if ENV["AR_INTEGRATION"] == "1"
  ar_ver = ENV["ACTIVERECORD_VERSION"]
  gem "activerecord", ar_ver || ">= 7.0", "< 9"
  sqlite_req = (ar_ver && ar_ver.start_with?("~> 8")) ? ">= 2.1" : ">= 1.6"
  gem "sqlite3", sqlite_req
end

# Specify your gem's dependencies in activerecord-s3-bucket-name-validator.gemspec
gemspec
