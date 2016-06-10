require 'mail'

# test with
# rvmsudo ruby -e "load 'mail.rb';MyMail.send()"

options = {
  address: "mail.gmx.com",
  port: 587,
  user_name: ENV["rvm_EMAIL_USER_NAME"],
  password: ENV["rvm_EMAIL_PASSWORD"],
}

Mail.defaults do
  delivery_method :smtp, options
end

module MyMail
  def self.send(attachment: 'sound.rb', text: 'hi')
    puts "Send email #{text} #{attachment}"
    Mail.deliver do
      to ENV["rvm_EMAIL_RECIPIENT_EMAIL"]
      from ENV["rvm_EMAIL_USER_NAME"]
      subject "camera door #{Time.now}"
      body text
      add_file attachment
    end
  rescue StandardError => e
    puts "MyMail.send failed #{e}"
  end
end
