require 'zoom'
require 'spec_helper'


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def zoom_request(request = '@attr 1=4 sea')
  result = ''
  ZOOM::Connection.open('10.68.86.19', 80) do |conn|
    conn.database_name = 'enju'
    result = conn.search(request)
  end
  result[0..(result.size)].collect{|zm| zm.to_s}
end

describe ManifestationsController do
  fixtures :users, :patrons, :roles, :roles_users, :manifestations,
    :library_groups
  include LoginHelper
  describe "SRUでの検索テスト" do
    describe "出力は" do
      context "一致するデータがあるとき" do
        before do
          @result = zoom_request '@attr 1=4 ruby'
        end
        it "マッチする検索セットが取得できる " do
          @result.should_not be_empty
          @result.each{|xml| xml.should match /title>.*ruby.*</i}
        end
      end
      context "一致するデータがないとき" do
        before do
          @result = zoom_request '@attr 1=4 web2'
        end
        it "検索結果が0件であること " do
          @result.should be_empty
        end
      end
    end
  end
end

