require 'aws-sdk'

module S3
  def self.upload(filename='sound.rb')
    puts "uploading #{filename} to #{ENV["AWS_BUCKET_NAME"]}"
    s3 = Aws::S3::Resource.new
    obj = s3.bucket(ENV["AWS_BUCKET_NAME"]).object('key')
    obj.upload_file(filename)
  end
end
