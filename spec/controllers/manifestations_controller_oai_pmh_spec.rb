require 'spec_helper'

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  integrate_views

  describe "OAI-PMHでの検索テスト" do
    share_examples_for '管理者が取得できるレコードになる' do
      it "管理者のみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 210
      end
      it "図書館員のみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 211
      end
      it "ユーザのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 213
      end
      it "ゲストのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 215
      end
      it "リポジトリに公開していないレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 216
      end
    end
    share_examples_for '図書館員が取得できるレコードになる' do
      it "管理者のみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 210
      end
      it "図書館員のみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 211
      end
      it "ユーザのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 213
      end
      it "ゲストのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 215
      end
      it "リポジトリに公開していないレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 216
      end
    end
    share_examples_for 'ユーザが取得できるレコードになる' do
      it "管理者のみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 210
      end
      it "図書館員のみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 211
      end
      it "ユーザのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 213
      end
      it "ゲストのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 215
      end
      it "リポジトリに公開していないレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 216
      end
    end
    share_examples_for 'ゲストが取得できるレコードになる' do
      it "管理者のみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 210
      end
      it "図書館員のみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 211
      end
      it "ユーザのみ閲覧できるレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 213
      end
      it "ゲストのみ閲覧できるレコードを含む" do
        assigns(:manifestations).collect(&:id).should be_include 215
      end
      it "リポジトリに公開していないレコードを含まない" do
        assigns(:manifestations).collect(&:id).should_not be_include 216
      end
    end

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
          assigns(:from_time).should == Time.zone.parse('2008-12-31')
          response.should be_success
          response.should render_template("manifestations/list_records")
        end
        it "検索結果が空であること" do
          assigns(:manifestations).should be_empty
        end
        it "noRecordsMatchエラーを含むこと" do
          response.should have_tag 'error[code="noRecordsMatch"]'
        end
      end
      context "無効なresumptionTokenが指定されたとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords', :resumptionToken => 'invalidToken'
        end
        it "badResumptionTokenエラーを含むこと" do
          response.should have_tag 'error[code="badResumptionToken"]'
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
        it "個別レコードの詳細を表示すること" do
          response.should be_success
          response.should render_template('manifestations/show.oai.builder')
        end
        it "検索結果一覧が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
        it "identifier要素が含まれていること" do
          response.should have_tag 'identifier'
        end
      end
      context "無効なIdentifierが指定されているとき" do
        before do
          get :index, :format => 'oai', :verb => 'GetRecord', :identifier => "invalid"
        end
        it "エラーの詳細を表示すること" do
          response.should be_success
          response.should render_template('manifestations/index.oai.builder')
        end
        it "検索結果一覧が存在しないこと" do
          assigns(:manifestations).should be_nil
        end
        it "idDoesNotExistエラーを含むこと" do
          response.should have_tag 'error[code="idDoesNotExist"]'
        end
      end
    end

    describe "無効なverbが指定されたとき" do
      before do
        get :index, :format => 'oai', :verb => 'InvalidVerb'
      end
      it "badVerbエラーを含むこと" do
        response.should have_tag 'error[code="badVerb"]'
      end
    end

    context "admin がログインしているとき" do
      before do
        sign_in :admin
      end
      context "ListIdentifiersで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers'
        end
        it_should_behave_like '管理者が取得できるレコードになる'
      end
      context "ListRecordsで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords'
        end
        it_should_behave_like '管理者が取得できるレコードになる'
      end
    end

    context "librarian がログインしているとき" do
      before do
        sign_in :librarian1
      end
      context "ListIdentifiersで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers'
        end
        it_should_behave_like '図書館員が取得できるレコードになる'
      end
      context "ListRecordsで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords'
        end
        it_should_behave_like '図書館員が取得できるレコードになる'
      end
    end

    context "user がログインしているとき" do
      before do
        sign_in :user1
      end
      context "ListIdentifiersで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers'
        end
        it_should_behave_like 'ユーザが取得できるレコードになる'
      end
      context "ListRecordsで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords'
        end
        it_should_behave_like 'ユーザが取得できるレコードになる'
      end
    end

    context "ログインしていないとき" do
      context "ListIdentifiersで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListIdentifiers'
        end
        it_should_behave_like 'ゲストが取得できるレコードになる'
      end
      context "ListRecordsで取得するとき" do
        before do
          get :index, :format => 'oai', :verb => 'ListRecords'
        end
        it_should_behave_like 'ゲストが取得できるレコードになる'
      end
    end
  end

  describe "新規レコードの作成は" do
    context "管理者のとき" do
      before do
        sign_in :admin
        get :new, :format => 'oai'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "図書館員がログインしているとき" do
      before do
        sign_in :librarian1
        get :new, :format => 'oai'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ユーザがログインしているとき" do
      before do
        sign_in :user1
        get :new, :format => 'oai'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
    context "ログインしていないとき" do
      before do
        get :new, :format => 'oai'
      end
      it "受け付けられない" do
        response.status.should =~ /406/
      end
    end
  end
end
