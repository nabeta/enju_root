require 'spec_helper'

# 参考：
# 例外の書き方
# lambda{ obj.do_something }.should raise_error
# lambda{ obj.do_something }.should raise_error(SomeExpectedError)
# lambda{ obj.do_something }.should_not raise_error
describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  
  describe "GET 'index'" do
    share_examples_for 'デフォルト出力になる' do
      it "成功する" do
        response.should be_success
      end
      it "manifestation.per_pageで割り当てられた件数を取得する" do
        assigns(:manifestations).size.should == Manifestation.per_page
      end
    end

    context "admin がログインしているとき" do
      before do
        sign_in :admin
        get :index
      end
      context "パラメータなしのとき" do
        it_should_behave_like 'デフォルト出力になる'
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200
        end
        it "管理者のみ閲覧できるレコードを含む" do
          assigns(:manifestations).collect(&:id).should be_include 210
        end
      end
    end
    context "librarian がログインしているとき" do
      before do
        sign_in :librarian1
        get :index
      end
      context "パラメータなしのとき" do
        it_should_behave_like 'デフォルト出力になる'
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200
        end
        it "図書館員のみ閲覧できるレコードを含む" do
          assigns(:manifestations).collect(&:id).should be_include 211
        end
        it "管理者のみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 210
        end
      end
    end

    context "user がログインしているとき" do
      before do
        sign_in :user1
        get :index
      end
      context "パラメータなしのとき" do
        it_should_behave_like 'デフォルト出力になる'
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200
        end
        it "ユーザのみ閲覧できるレコードを含む" do
          assigns(:manifestations).collect(&:id).should be_include 213
        end
        it "管理者のみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 210
        end
        it "図書館員のみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 211
        end
      end
    end
    context "ログインしていないとき" do
      before do
        get :index
      end
      context "パラメータなしのとき" do
        it_should_behave_like 'デフォルト出力になる'
      end
      context "検索語を入力したとき" do
        before do
          get :index, :query => 'web'
        end
        it "検索結果が出力される" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200
        end
        it "ゲストのみ閲覧できるレコードを含む" do
          assigns(:manifestations).collect(&:id).should be_include 215
        end
        it "管理者のみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 210
        end
        it "図書館員のみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 211
        end
        it "ユーザのみ閲覧できるレコードを含まない" do
          assigns(:manifestations).collect(&:id).should_not be_include 213
        end
      end
    end
  end

  describe "GET 'new'" do
    share_examples_for '成功する' do
      it "成功する" do
        get :new
        response.should be_success
      end
    end

    context "adminがログインしているとき" do
      before(:each) do
        sign_in :admin
      end
      it_should_behave_like '成功する'
    end

    context "librarianがログインしているとき" do
      before(:each) do
        sign_in :librarian1
      end
      it_should_behave_like '成功する'
    end

    context "userがログインしているとき" do
      before(:each) do
        sign_in :user1
      end
      it_should_behave_like '成功する'
    end

    context "ログインしていないとき" do
      it "ログイン画面にリダイレクトされる" do
        get :new
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "DELETE 'destroy'" do
    context "adminでログインしているとき" do
      before do
        sign_in :admin
        @manifestation = manifestations(:manifestation_00001)
      end
      context 'htmlフォーマットを要求しているとき' do
        before do
          delete :destroy, :id => @manifestation.id
        end
        it "削除できる" do
          Manifestation.find_by_id(@manifestation.id).should be_nil
        end
        it "indexにリダイレクトされる" do
          response.should redirect_to(manifestations_url)
        end
      end
      context 'xmlフォーマットを要求しているとき' do
        before do
          delete :destroy, :id => @manifestation.id, :format => 'xml'
        end
        it "削除できる" do
          Manifestation.find_by_id(@manifestation.id).should be_nil
        end
        it "成功すること" do
          response.should be_success
        end
      end
    end
  end

end

