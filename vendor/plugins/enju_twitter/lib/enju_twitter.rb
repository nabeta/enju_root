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
    def twitter_client
      oauth = Twitter::OAuth.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
      oauth.authorize_from_access(TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_SECRET)
      client = Twitter::Base.new(oauth)
    end

    def manifestation_comment
      manifestation_url = "#{LibraryGroup.url}manifestations/#{id}"
      status_manifestation = "#{original_title.to_s.truncate}: #{note.to_s.split.join(" / ").truncate} #{manifestation_url}"
      if comment.to_s.strip.present?
        "#{comment} #{manifestation_url}"
      else
        "#{manifestation_url}"
      end
    end

    def send_to_twitter(comment = nil)
      if RAILS_ENV == "production"
        begin
          timeout(30){
            client.update(comment)
          }
        rescue Timeout::Error
          Rails.logger.warn 'post timeout!'
        end
      end
    end
  end
end
