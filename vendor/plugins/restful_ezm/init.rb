require "restful_easy_messages_system"
ActiveRecord::Base.send :include, ProtonMicro::RestfulEasyMessages::Messages
