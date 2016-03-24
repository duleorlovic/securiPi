# s3.rb
#
# you can test with: ruby -e "load 's3.rb';S3.upload"
require 'aws-sdk'
Aws.config.update({
  region: ENV["rvm_AWS_REGION"],
  credentials: Aws::Credentials.new(ENV["rvm_AWS_ACCESS_KEY_ID"], ENV["rvm_AWS_SECRET_ACCESS_KEY"]),
})
module S3
  def self.getUrl(filename='sound.rb')
    "https://#{ENV["rvm_AWS_BUCKET_NAME"]}.s3.amazonaws.com/#{filename}"
  end

  def self.upload(filename='sound.rb')
    puts "Uploading #{filename} to #{ENV["rvm_AWS_BUCKET_NAME"]}"
    if File.exists? filename
      t = Time.now
      s3 = Aws::S3::Resource.new(region: ENV["rvm_AWS_REGION"])
      obj = s3.bucket(ENV["rvm_AWS_BUCKET_NAME"]).object(filename)
      obj.upload_file(filename, acl: 'public-read')
      puts "done uploading in #{(Time.now-t).to_i} sec"
      puts obj.public_url
      system "rm #{filename}" if filename != 'sound.rb'
      return obj.public_url
    else
      puts "#{filename} does not exists"
    end
  end
end
