require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  describe "OpenURLでの検索テスト" do
    describe "出力は" do
      share_examples_for "テンプレートは" do
        it "manifestations/index.htmlを表示する" do
          response.should render_template("manifestations/index")
        end
      end
      context "一致するデータがあるとき" do
        before do
          get :index, :api => 'openurl', :btitle => 'web'
        end
        it "検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should_not be_empty
        end
        it_should_behave_like "テンプレートは"
      end
      context "一致するデータがないとき" do
        before do
          get :index, :api => 'openurl', :btitle => 'web2'
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
         get :index, :api => 'openurl', :btitle => '権限確認'
        end
        it "Guest権限の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should == 1}
        end
      end
      describe "User権限でログインしているとき" do
        before do
          sign_in :user1
          get :index, :api => 'openurl', :btitle => '権限確認'
        end
        it "User権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 2}
        end
      end
      describe "Librarian権限でログインしているとき" do
          before do
            sign_in :librarian1
            get :index, :api => 'openurl', :btitle => '権限確認'
          end
        it "Librarian権限以下の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 3}
        end
      end
      describe "Administrator権限でログインしているとき" do
          before do
            sign_in :admin
            get :index, :api => 'openurl', :btitle => '権限確認'
          end
        it "全ての権限の図書が検索できる" do
          assigns(:manifestations).should_not be_empty
          assigns(:manifestations).should be_all{|m| m.required_role_id.should <= 4}
        end
      end
    end
  end
end

