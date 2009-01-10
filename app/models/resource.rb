class Resource < ActiveResource::Base
  #USER = "your_account"
  #PASS = "your_password"
  #self.site = "http://#{USER}:#{PASS}@mwr.mediacom.keio.ac.jp:3010"
  self.site = "http://mwr.mediacom.keio.ac.jp:3010"
  self.logger = Logger.new($stderr)

end
