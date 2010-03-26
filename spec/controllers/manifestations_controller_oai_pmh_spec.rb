require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  describe "OpenURLでの検索テスト" do
    describe "Identifyが指定されていて" do
      context "引数が指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'Identify'
        end
        it "Identify情報が取得できること" do
          response.should be_success
          response.should render_template("manifestations/identify")
        end
        it "検索結果が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
    end

    describe "ListSetsが指定されていて" do
      context "引数が指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListSets'
        end
        it "Setsの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_sets")
        end
        it "検索結果が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
    end

    describe "ListMetadataFormatsが指定されていて" do
      context "引数が指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListMetadataFormats'
        end
        it "MetadataFormatの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_metadata_formats")
        end
        it "検索結果が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
    end

    describe "ListIdentifiersが指定されていて" do
      context "引数が指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers'
        end
        it "Identifierの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_identifiers")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers', :from => '2001-01-01'
        end
        it "Identifierの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_identifiers")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "untilが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers', :until => '2008-12-31'
        end
        it "Identifierの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_identifiers")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromとuntilが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers', :from => '2001-01-01', :until => '2008-12-31'
        end
        it "Identifierの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_identifiers")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromがuntilより後の日時を指定されたとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers', :from => '2008-12-31', :until => '2001-01-01'
        end
        it "Identifierの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_identifiers")
        end
        it "検索結果が存在しないこと" do
          assigns(:manifestations).should be_empty
        end
      end
    end

    describe "ListRecordsが指定されていて" do
      context "引数が指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords'
        end
        it "Recordの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords', :from => '2001-01-01'
        end
        it "Recordの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "untilが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords', :until => '2008-12-31'
        end
        it "Recordの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromとuntilが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords', :from => '2001-01-01', :until => '2008-12-31'
        end
        it "Recordの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が1件以上存在すること" do
          assigns(:manifestations).should_not be_empty
        end
      end
      context "fromがuntilより後の日時を指定されたとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords', :from => '2008-12-31', :until => '2001-01-01'
        end
        it "Recordの一覧が取得できること" do
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が空であること" do
          assigns(:manifestations).should be_empty
        end
      end
    end
    describe "GetRecordが指定されていて" do
      context "Identifierが指定されていないとき" do
        before do
          get :index, :format => 'oai', :verb => 'GetRecord'
        end
        it "エラーが取得できること" do
          response.should be_success
          response.should render_template("manifestations/index.oai.builder")
        end
        it "検索結果が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
      context "Identifierが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'GetRecord', :identifier => "oai:#{LIBRARY_WEB_HOSTNAME}:manifestations-1"
        end
        it "個別レコードの詳細に転送されること" do
          response.should be_redirect
          response.should redirect_to manifestation_url(1, :format => 'oai')
        end
        it "検索結果一覧が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
      context "無効なIdentifierが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'GetRecord', :identifier => "invalid"
        end
        it "エラーの詳細表示に転送されること" do
          response.should be_redirect
          response.should redirect_to manifestations_url(:format => 'oai')
        end
        it "検索結果一覧が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
      end
    end
  end
end