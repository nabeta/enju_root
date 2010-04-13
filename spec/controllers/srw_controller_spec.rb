require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

PARAMS = <<EOB
    {
    "Envelope"=>
      {"Body"=>
        {"searchRetrieveRequest"=>
          {"comment"=>[nil, nil, nil, nil, nil, nil, nil, nil, nil],
          "recordXPath"=>"?",
          "extraRequestData"=>nil,
          "stylesheet"=>"?",
          "version"=>"1.1",
#          "maximumRecords"=>"1",
          "recordPacking"=>"xml",
#          "startRecord"=>"2",
          "recordSchema"=>"dcndl_porta",
          "resultSetTTL"=>"?",
          "sortKeys"=>"title,0",
          "query"=>"title=ruby"}},
      "Header"=>nil}}
EOB


describe SrwController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  
  before do
    @params = eval(PARAMS)
  end

  describe "SRWでの検索テスト" do
    describe "出力は" do
      share_examples_for "テンプレートは" do
        it "srw/index.xml.builderを表示する" do
          post :index, @params
          response.should render_template("srw/index.xml.builder")
        end
      end
      context "一致するデータがあるとき" do
        before do
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=web'
          post :index, @params
        end
        it "検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should_not be_empty
        end
        it_should_behave_like "テンプレートは"
      end
      context "一致するデータがないとき" do
        before do
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=web2'
          post :index, @params
        end
        it "検索結果が0件であること " do
          response.should be_success
          assigns(:manifestations).should be_empty
        end
        it_should_behave_like "テンプレートは"
      end
    end
    describe "ログイン権限別には" do
      describe "ログインしていないとき" do
        before do
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=権限確認'
          post :index, @params
        end
        it "Guest権限の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should == 1}
        end
      end
      describe "User権限でログインしているとき" do
        before do
          sign_in :user1
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=権限確認'
          post :index, @params
        end
        it "User権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 2}
        end
      end
      describe "Librarian権限でログインしているとき" do
        before do
          sign_in :librarian1
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=権限確認'
          post :index, @params
        end
        it "Librarian権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 3}
        end
      end
      describe "Administrator権限でログインしているとき" do
        before do
          sign_in :admin
          @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title=権限確認'
          post :index, @params
        end
        it "全ての権限の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 4}
        end
      end
    end
  end
  describe 'エラー処理では' do
    it 'QueryError は error.xml が返る' do
      @params["Envelope"]["Body"]["searchRetrieveRequest"].delete "query"
      post :index, @params
      response.should be_success
      response.should render_template('srw/error.xml')
    end
    it 'RequestError は error.xml が返る' do
      @params["Envelope"]["Body"]["searchRetrieveRequest"]["query"] = 'title="Ruby"Perl'
      post :index, @params
      response.should be_success
      response.should render_template('srw/error.xml')
    end
  end
end

