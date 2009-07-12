class Twitter < ActiveResource::Base
  self.site = 'http://twitter.com'
  self.logger = Logger.new($stderr)

  class Twitter::Status < Twitter
  end
end

class String
  def truncate(int = 24)
    chars = self.split(//u)[0..int]
    if chars.size > int
      chars.to_s + "..."
    else
      chars.to_s
    end
  end
end

module EnjuTwitter
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_twitter
      include EnjuTwitter::InstanceMethods
    end
  end
  
  module InstanceMethods
    attr_accessor :post_to_twitter, :twitter_comment
    def send_to_twitter
      if RAILS_ENV == "production"
        if Twitter::Status
          status_manifestation = "#{original_title.to_s.truncate}: #{note.to_s.split.join(" / ").truncate} #{LibraryGroup.url}manifestations/#{id}"
          begin
            timeout(10){
              Twitter::Status.post(:update, :status => status_manifestation)
            }
          rescue Timeout::Error
            Twitter.logger.warn 'post timeout!'
          end
        end
      end
    end
  end
end
