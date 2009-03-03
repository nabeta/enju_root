require File.join(File.dirname(__FILE__), 'helper')
 
class ConfiguratorTest < Test::Unit::TestCase
 
  def setup
    setup_db
    @user = User.create
    @company = Company.create
  end
  
  context 'setting configurator values on objects' do
    
    should 'not accept either strings or symbols as keys' do
      @user.config[:favorite_color] = 'red'
      assert_equal 'red', @user.config[:favorite_color]
      @user.config['favorite_city'] = 'New York'
      assert_equal 'New York', @user.config[:favorite_city]
    end

    should 'test for data types being preserved' do
      @user.config[:age] = 50
      assert_instance_of Fixnum, @user.config[:age]
      @user.config[:likes_cats?] = true
      assert_instance_of TrueClass, @user.config[:likes_cats?]
      @user.config[:account_balance] = 123.45
      assert_instance_of Float, @user.config[:account_balance]
    end

    should 'handle two levels of namespaces as keys' do
      @other_user = User.create
      @user.config[:animals, :likes_cats?] = true
      @user.config[:animals, :favorite] = 'cat'
      @other_user.config[:animals, :likes_cats?] = false
      @other_user.config[:animals, :favorite] = 'dog'
      assert_equal true, @user.config[:animals, :likes_cats?]
      assert_equal 'cat', @user.config[:animals, :favorite]
      assert_equal false, @other_user.config[:animals, :likes_cats?]
      assert_equal 'dog', @other_user.config[:animals, :favorite]
      assert_equal true, @user.config.namespace(:animals)[:likes_cats?]
      assert_equal 'cat', @user.config.namespace(:animals)[:favorite]
      assert_equal false, @other_user.config.namespace(:animals)[:likes_cats?]
      assert_equal 'dog', @other_user.config.namespace(:animals)[:favorite]
    end

    should 'return a hash when querying a namespace with #namespace' do
      @user.config[:animals, :cat] = 'Toby'
      @user.config[:animals, :dog] = 'Gabby'
      @user.config[:animals, :mouse] = 'Mickey'
      hsh = { :cat => 'Toby', :dog => 'Gabby', :mouse => 'Mickey' }
      assert_equal hsh, @user.config.namespace(:animals)
    end

    context 'when querying and attempting to write to a key that is a namespace' do

    end

    should 'honor default configuration settings' do
      assert_equal '$55,000', @company.config[:salary, :default_for_manager]
      @company.config[:salary, :default_for_manager] = '$65,000'
      assert_equal '$65,000', @company.config[:salary, :default_for_manager]
    end

    should 'allow for mass assignment of flat/nested hashes' do
      hash = { :favorite_color => 'red', :favorite_city => 'New York', :favorite_artist => 'Radiohead', :animals => { :favorite => 'cat', :likes_elephants? => true } }
      @user.config = hash
      assert_equal @user.config[:favorite_color], 'red'
      assert_equal @user.config[:animals, :favorite], 'cat'
      assert_equal @user.config[:animals, :likes_elephants?], true
    end

    should 'support default values on a class' do
      User.config[:default_salary] = '$55,000'
      assert_equal '$55,000', User.config[:default_salary]
    end

    should 'support default namespaced values on a class' do
      assert_equal Company.config[:salary, :default_for_manager], '$55,000'
    end

    should 'allow for mass assignment on a class' do
      hash = { :favorite_color => 'red', :favorite_city => 'New York', :favorite_artist => 'Radiohead', :animals => { :favorite => 'cat', :likes_elephants? => true } }
      User.config = hash
      assert_equal User.config[:favorite_color], 'red'
      assert_equal User.config[:animals, :favorite], 'cat'
      assert_equal User.config[:animals, :likes_elephants?], true
    end

    should 'support setting global values' do
      Configurator[:enable_quantum_accelerator?] = true
      assert Configurator[:enable_quantum_accelerator?]
      Configurator[:colors, :favorite] = 'red'
      assert_equal Configurator[:colors, :favorite], 'red'
    end
    
  end
 
end