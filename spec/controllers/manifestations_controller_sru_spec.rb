require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  describe "SRUでの検索テスト" do
    describe "出力は" do
      share_examples_for "テンプレートは" do
        it "manifestations/index.sru.builderを表示する" do
          response.should render_template("manifestations/index.sru.builder")
        end
      end
      context "一致するデータがあるとき" do
        before do
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = web'
        end
        it "検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should_not be_empty
        end
        it_should_behave_like "テンプレートは"
      end
      context "一致するデータがないとき" do
        before do
          #          get :index, :api => 'openurl', :btitle => 'web2'
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = web2'
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
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = 権限確認'
        end
        it "Guest権限の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should == 1}
        end
      end
      describe "User権限でログインしているとき" do
        before do
          login :user1
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = 権限確認'
        end
        it "User権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 2}
        end
      end
      describe "Librarian権限でログインしているとき" do
        before do
          login :librarian1
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = 権限確認'
        end
        it "Librarian権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 3}
        end
      end
      describe "Administrator権限でログインしているとき" do
        before do
          login :admin
          get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title = 権限確認'
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
      get :index, :format => 'sru', :operation => 'searchRetrieve'
      response.should be_success
      response.should render_template('manifestations/error.xml')
    end
    it 'RequestError は error.xml が返る' do
      get :index, :format => 'sru', :operation => 'searchRetrieve', :query => 'title="Ruby"Perl'
      response.should be_success
      response.should render_template('manifestations/error.xml')
    end
  end

  describe "新規レコードの作成は" do
    context "管理者のとき" do
      before do
        login :admin
        get :new, :format => 'sru'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "図書館員がログインしているとき" do
      before do
        login :librarian1
        get :new, :format => 'sru'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ユーザがログインしているとき" do
      before do
        login :user1
        get :new, :format => 'sru'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ログインしていないとき" do
      before do
        get :new, :format => 'sru'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
  end
end
