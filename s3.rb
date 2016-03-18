require 'aws-sdk'
Aws.config.update({
  region: ENV["rvm_AWS_REGION"],
  credentials: Aws::Credentials.new(ENV["rvm_AWS_ACCESS_KEY_ID"], ENV["rvm_AWS_SECRET_ACCESS_KEY"]),
})
module S3
  def self.upload(filename='sound.rb')
    puts "uploading #{filename} to #{ENV["rvm_AWS_BUCKET_NAME"]}"
    s3 = Aws::S3::Resource.new(region: ENV["rvm_AWS_REGION"])
    obj = s3.bucket(ENV["rvm_AWS_BUCKET_NAME"]).object(filename)
    obj.upload_file(filename)
  end
end
