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
  end
end

