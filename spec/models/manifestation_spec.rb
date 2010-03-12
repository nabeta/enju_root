# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../masters_helper')

describe Manifestation do
  include MastersHelper
  describe "validate" do
    it "正しいデータ状態のとき、検証をとおる" do
      new_manifestation.should be_valid
    end

    describe "original_title" do
      it "ないとき検証エラーとなる" do
        manifestation = Manifestation.new
        manifestation.valid?.should be_false
        manifestation.errors.invalid?(:original_title).should be_true
      end
    end

    describe "start_page" do
      it "数字でないとき検証エラーとなる" do
        new_manifestation(:start_page => 'abc').should_not be_valid
      end
      it "数字であれば検証をとおる" do
        new_manifestation(:start_page => '10').should be_valid
      end
    end

    describe "end_page" do
      it "数字でないとき検証エラーとなる" do
        new_manifestation(:end_page => 'abc').should_not be_valid
      end
      it "数字であれば検証をとおる" do
        new_manifestation(:end_page => '10').should be_valid
      end
    end

    describe "nbn" do
      it "ユニークであるとき検証をとおる" do
        new_manifestation(:nbn => '123456').should be_valid
      end
      it "重複しているとき検証を通らない" do
        new_manifestation(:nbn => '123456').save!
        new_manifestation(:nbn => '123456').should_not be_valid
      end
    end
  end

  describe "url" do
    before do
      @manifestation = new_manifestation
      @manifestation.save!
    end
    it "LibraryGroup.url + 'manifestations/' + id の形になっていること" do
      @manifestation.url.should =~ /^#{LibraryGroup.url}manifestations\/#{@manifestation.id}$/
    end
  end

  describe "publisher" do
    context "パトロンが１つもないとき" do
      before do
        @manifestation = new_manifestation
      end
      it "空配列がかえる" do
        @manifestation.publisher.should be_empty
      end
    end
    context "パトロンが２つのとき" do
      before do
        @manifestation = new_manifestation
        @taro = new_patron(:full_name => 'Taro')
        @taro.save!
        @hanako = new_patron(:full_name => 'Hanako')
        @hanako.save!
        @manifestation.patrons << @taro
        @manifestation.patrons << @hanako
      end
      it "それぞれのnameの配列が返される" do
        @manifestation.publisher.size.should == 6
        @manifestation.publisher.should be_include('Taro')
        @manifestation.publisher.should be_include('Hanako')
      end
    end
  end

end

