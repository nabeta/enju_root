require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  integrate_views

  describe "RDFでの検索テスト" do
    describe "出力は" do
      share_examples_for "テンプレートは" do
        it "manifestations/index.rdf.builderを表示する" do
          response.should render_template("manifestations/index.rdf.builder")
        end
      end
      share_examples_for "個別テンプレートは" do
        it "manifestations/show.rdf.builderを表示する" do
          response.should render_template("manifestations/show.rdf.builder")
        end
      end
      context "一致するデータがあるとき" do
        before do
          get :index, :format => 'rdf'
        end
        it "検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should_not be_empty
        end
        it_should_behave_like "テンプレートは"
      end
      context "検索語に一致するデータがないとき" do
        before do
          get :index, :format => 'rdf', :query => 'invalid'
        end
        it "空の検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should be_empty
        end
        it_should_behave_like "テンプレートは"
      end
      context "検索語に一致するデータがあるとき" do
        before do
          get :index, :format => 'rdf', :query => 'ruby'
        end
        it "検索結果が取得できる " do
          response.should be_success
          assigns(:manifestations).should_not be_empty
        end
        it_should_behave_like "テンプレートは"
      end

      context "IDを指定したとき" do
        before do
          get :show, :format => 'rdf', :id => 1
        end
        it "そのIDを持つ資料の詳細が取得できる " do
          response.should be_success
          assigns(:manifestation) == Manifestation.find(1)
        end
        it_should_behave_like "個別テンプレートは"
      end
    end

    context "admin がログインしているとき" do
      before do
        login :admin
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200, :format => 'rdf'
        end
        it "管理者のみ閲覧できるレコードを含む" do
          assigns(:manifestations).collect(&:id).should be_include 210
        end
      end
    end

    context "librarian がログインしているとき" do
      before do
        login :librarian1
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
        login :user1
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200, :format => 'rdf'
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
        get :index, :format => 'rdf'
      end
      context "検索語を入力したとき" do
        before do
          get :index, :query => 'web', :format => 'rdf'
        end
        it "検索結果が出力される" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "全件を取得するとき" do
        before do
          get :index, :per_page => 200, :format => 'rdf'
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

  describe "新規レコードの作成は" do
    context "管理者がログインしているとき" do
      before do
        login :admin
        get :new, :format => 'rdf'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "図書館員がログインしているとき" do
      before do
        login :librarian1
        get :new, :format => 'rdf'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ユーザがログインしているとき" do
      before do
        login :user1
        get :new, :format => 'rdf'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ログインしていないとき" do
      before do
        get :new, :format => 'rdf'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
  end
end
