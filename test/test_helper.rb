ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # RoleRequirementTestHelper must be included to test RoleRequirement
  include RoleRequirementTestHelper

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  include AuthenticatedTestHelper

#  def follow_redirect_with_restful_routes
#    #use the normal one unless its a string
#    return follow_redirect_without_restful_routes unless @response.redirected_to.is_a?(String) 
#    #okay we need to follow the redirect, but first parse the path
#    url = URI.parse(@response.redirected_to)
#    path = url.path
#    
#    extras = CGI.parse(url.query)
#
#    #parse puts values into array so flatten
#    extras.each do |key, value|
#      extras[key] = value[0] if value.is_a?(Array) && value.length == 1
#    end
#
#    # Assume given controller
#    request = ActionController::TestRequest.new({}, {}, nil)
#    request.env["REQUEST_METHOD"] = "GET"
#    request.path = path
#
#    redirected_controller = ActionController::Routing::Routes.recognize(request)
#
#    if @controller.is_a?(redirected_controller)
#      #then we can redirect, otherwise we can't'
#      get request.path_parameters[:action], extras.symbolize_keys!
#    else
#      raise "Can't follow redirects outside of current controller (from #{@controller.controller_name} to #{redirected_controller})"
#    end
#  end
#  alias_method_chain :follow_redirect, :restful_routes
end
