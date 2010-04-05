# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../masters_helper')

module SearchHelper
  def search(text, count)
    it text + "は#{count}件" do
      @sru = Sru.new({:query => text})
      @sru.search
      @sru.manifestations.size.should == count
    end
  end
end
include SearchHelper

describe Manifestation do
  include MastersHelper

  fixtures :manifestations, :expressions, :works, :embodies, :items, :exemplifies, :patrons,
    :reserves, :users, :roles, :languages, :reifies, :realizes, :creates, :produces,
    :frequencies, :form_of_works, :content_types, :carrier_types, :countries, :patron_types

  describe Sru, 'での検索テスト' do
    describe 'publisherの検索では' do
      context "検索語を'='でつないだ場合は部分一致で" do
        it "検索語を含む発行者の図書が検索できる" do
          @manifestations = Sru.new({:query => 'publisher=Ruby'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.publisher.to_s.should match /Ruby/i}
        end
      end
    end
    describe 'titleの検索では' do
      context "検索語を'='でつないだ場合は部分一致で" do
        it "タイトルに検索語を含む図書が検索できる" do
          @manifestations = Sru.new({:query => 'title=Ruby'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.title.to_s.should match /Ruby/i}
        end
      end
      context "検索語の先頭に'^'を付けた場合は先頭一致で" do
        it "タイトルの先頭に検索語がある図書が検索できる" do
          @manifestations = Sru.new({:query => 'title=^ruby'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.title.to_s.should match /^Ruby/i}
        end
        it "検索語に空白が含まれてても同様に検索できる" do
          @manifestations = Sru.new({:query => 'title="^Ruby Cook"'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.title.to_s.should match /^Ruby\sCook/i}
        end
      end
      context "検索語を' EXACT 'でつないだ場合は完全一致で" do
        it "タイトルが検索語とまったく同じ図書が検索できる" do
          @manifestations = Sru.new({:query => 'title EXACT Ruby'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.title.to_s.should match /\ARuby\Z/i}
        end
      end
    end
    describe "複数指定では" do
      context "ALLを指定した場合は" do
        it "タイトルに全ての検索語を部分一致で含む図書が検索できる" do
          @manifestations = Sru.new({:query => 'title ALL "awk sed"'}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.title.to_s.should match /sed.*awk|awk.*sed/i
          end
        end
      end
      context "ANYを指定した場合は" do
        it "タイトルに全ての検索語を部分一致で含む図書が検索できる" do
          @manifestations = Sru.new({:query => 'title ANY "ruby awk"'}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.title.to_s.should match /ruby|awk/i
          end
        end
      end
    end
    describe "ISBN の検索では" do
      describe "完全一致とみなして"  do
        it "ISBN が一致する図書一件だけが検索される" do
          @manifestations = Sru.new({:query => 'isbn=9784797340044'}).search
          @manifestations.size.should == 1
          @manifestations.first.isbn.should include '9784797340044'
        end
        it "十桁の ISBN でも同様に検索される" do
          @manifestations = Sru.new({:query => 'isbn=4797340045'}).search
          @manifestations.size.should == 1
          @manifestations.first.isbn.should include '9784797340044'
        end
        it "桁が合わない場合は検索されない" do
          @manifestations = Sru.new({:query => 'isbn=978479734004'}).search
          @manifestations.should be_empty
        end
      end
    end
    describe "日付の検索では" do
      describe "from 検索は" do
        it "出版日が指定日以降の図書が検索される" do
          @manifestations = Sru.new({:query => 'from = 2001-03-20'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.date_of_publication.should >= Time.utc(2001,3,20)}
        end
      end
      describe "until 検索は" do
        it "出版日が指定日以前の図書が検索される" do
          @manifestations = Sru.new({:query => 'until = 2006-08-05'}).search
          @manifestations.should_not be_empty
          @manifestations.each{|m| m.date_of_publication.should <= Time.utc(2006,8,05)}
        end
      end
      describe "両方指定すると" do
        it "両日の間の出版日の図書が検索される" do
          @manifestations = Sru.new({:query => "from = 2000-09-01 AND until = 2001-11-01"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.date_of_publication.should >= Time.utc(2000,9,1)
            m.date_of_publication.should <= Time.utc(2001,11,1)
          end
        end
        it " OR で接続しても両日の間の出版日の図書が検索される" do
          @manifestations = Sru.new({:query => "from = 2000-09-01 OR until = 2001-11-01"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.date_of_publication.should >= Time.utc(2000,9,1)
            m.date_of_publication.should <= Time.utc(2001,11,1)
          end
        end
      end
      describe "月日を省略した場合の検索文字列は" do
        it "日を省略すると 01 日を補う" do
          @sru = Sru.new({:query => "from = 2000-09"})
          @sru.cql.to_sunspot.should == 'date_of_publication_d:[2000-09-01T00:00:00Z TO *]'
        end
        it "月日を省略すると 01 月 01 日を補う" do
          @sru = Sru.new({:query => "until = 2001"})
          @sru.cql.to_sunspot.should == 'date_of_publication_d:[* TO 2001-01-01T00:00:00Z]'
        end
      end
    end
    describe "複合検索で" do
      describe "title と日付の場合" do
        it "指定日以降に出版されたタイトルに検索語を含む図書が検索される" do
          @manifestations = Sru.new({:query => "from = 2000-10-01 AND title=プログラミング"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.title.to_s.should match /プログラミング/i
            m.date_of_publication.should >= Time.utc(2000,10,1)
          end
        end
        it "指定日以前に出版されたタイトルに検索語を含む図書が検索される" do
          @manifestations = Sru.new({:query => "until = 2009-01-01 AND title=プログラミング"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.title.to_s.should match /プログラミング/i
            m.date_of_publication.should <= Time.utc(2009,1,1)
          end
        end
        it "開始日と終了日の間に出版されたに検索語を含む図書が検索される" do
          @manifestations = Sru.new({:query => "from = 1993-02-24 AND until = 2006-08-05 AND title=プログラミング"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.title.to_s.should match /プログラミング/i
            m.date_of_publication.should >= Time.utc(1993,2,24)
            m.date_of_publication.should <= Time.utc(2006,8,5)
          end
        end
        it "指定日以降に出版されているか、タイトルに検索語を含む図書が検索される" do
          @manifestations = Sru.new({:query => "from = 2007 OR title=awk"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            m.should satisfy{|a| a.title.to_s =~ /awk/i or a.date_of_publication >= Time.utc(2007,1,1)}
          end
        end
      end
    end
    describe "anywhere の検索では" do
      describe "text 属性の index を対象にして検索を行い" do
        it "検索語がタイトルや発行者などに含まれる図書が検索される" do
          @manifestations = Sru.new({:query => "anywhere=Ruby"}).search
          @manifestations.should_not be_empty
          @manifestations.should be_all{|m|
            [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].any? do |mtd|
              m.send(mtd).to_s =~ /Ruby/i
            end
          }
        end
      end
      context "ALL を指定した場合は" do
        it "全ての検索文字列がいずれかの項目に含まれる図書が検索される" do
          @manifestations = Sru.new({:query => "anywhere ALL Ruby オーム社"}).search
          @manifestations.should_not be_empty
          @manifestations.each do |m|
            [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].inject('') do |txt, mtd|
              txt + m.send(mtd).to_s
            end.should match /Ruby.*オーム社|オーム社.*Ruby/i
          end
        end
      end
      context "ANY を指定した場合は" do
        it "いずれかの検索文字列がいずれかの項目に含まれる図書が検索される" do
          @manifestations = Sru.new({:query => "anywhere ANY Ruby 出版社"}).search
          @manifestations.should_not be_empty
          @manifestations.should be_all{|m|
            [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].any? do |mtd|
              m.send(mtd).to_s =~ /Ruby|出版社/i
            end
          }
        end
      end
    end
  end

end

