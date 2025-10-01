require "rails/railtie"

module Activerecord
  module S3
    module Bucket
      module Name
        module Validator
          class Railtie < ::Rails::Railtie
            initializer "activerecord-s3-bucket-name-validator.i18n" do |app|
              locales = Dir[File.expand_path("../../../../../config/locales/*.yml", __FILE__)]
              app.config.i18n.load_path.concat(locales)
            end
          end
        end
      end
    end
  end
end

