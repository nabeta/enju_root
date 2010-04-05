# To change this template, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Manifestation do
  fixtures :manifestations
  describe Openurl, 'での検索テスト' do
    describe "atitleの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含むタイトルの記事が検索できる" do
            openurl = Openurl.new({:atitle => "記事"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /記事/ }
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:atitle => "記事３"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "検索語を全て含むタイトルの記事が検索できる" do
            openurl = Openurl.new({:atitle => "記事 １月号"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /記事.*１月号|１月号.*記事/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:atitle => "記事 ３月号"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "btitleの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含むタイトルの図書が検索できる" do
            openurl = Openurl.new({:btitle => "プログラミング"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /プログラミング/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:btitle => "プログラミング２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合" do
        context "一致するデータがあるとき" do
          it "検索語を全て含むタイトルの図書が検索できる" do
            openurl = Openurl.new({:btitle => "プログラミング CGI"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /プログラミング.*CGI|CGI.*プログラミング/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:btitle => "プログラミング COBOL"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "titleの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含むタイトルの図書が検索できる" do
            openurl = Openurl.new({:title => "プログラミング"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /プログラミング/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:title => "プログラミング２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "検索語を全て含むタイトルの図書が検索できる" do
            openurl = Openurl.new({:title => "プログラミング CGI"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /プログラミング.*CGI|CGI.*プログラミング/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:title => "プログラミング COBOL"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "jtitleの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含むタイトルの雑誌が検索できる" do
            openurl = Openurl.new({:jtitle => "テスト"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /テスト/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:jtitle => "テスト２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "検索語を全て含むタイトルの雑誌が検索できる" do
            openurl = Openurl.new({:jtitle => "テスト １月号"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.original_title =~ /テスト.*１月号|１月号.*テスト/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:jtitle => "テスト ３月号"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "aulastの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含む著者の図書が検索できる" do
            openurl = Openurl.new({:aulast => "Administrator"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.creator.to_s =~ /Administrator/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:aulast => "Administrator２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        it "OpenurlQuerySyntaxErrorを返す" do
          lambda{ Openurl.new({:aulast => "テスト 名称"}) }.should raise_error(OpenurlQuerySyntaxError)
        end
      end
    end
    describe "aufirstの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含む著者の図書が検索できる" do
            openurl = Openurl.new({:aufirst => "名称"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.creator.to_s =~ /名称/
            }
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:aufirst => "名称２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        it "OpenurlQuerySyntaxErrorを返す" do
          lambda{ Openurl.new({:aufirst => "テスト 名称"}) }.should raise_error(OpenurlQuerySyntaxError)
        end
      end
    end
    describe "auの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含む著者の図書が検索できる" do
            openurl = Openurl.new({:au => "テスト"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.creator.to_s =~ /テスト/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:au => "テスト２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "検索語を全て含む著者の図書が検索できる" do
            openurl = Openurl.new({:au => "テスト 名称"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all { |result| result.creator.to_s =~ /テスト.*名称|名称.*テスト/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:au => "テスト 著者"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "pubの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語を含む出版社の図書が検索できる" do
            openurl = Openurl.new({:pub => "Administrator"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.publisher.to_s =~ /Administrator/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:pub => "Administrator２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "検索語を全て含む出版社の図書が検索できる" do
            openurl = Openurl.new({:pub => "テスト 出版"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.publisher.to_s =~ /テスト.*出版|出版.*テスト/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:pub => "試験 出版"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "isbnの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語で始まるISBNの図書が検索できる" do
            openurl = Openurl.new({:isbn => "4798"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.isbn =~ /\A4798/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:isbn => "798"})
            results = openurl.search
            results.should be_empty
          end
        end
        context "検索語が不正なとき" do
          context "桁数オーバーのとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {Openurl.new({:isbn => "12345678901234"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
          context "数字以外のとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {Openurl.new({:isbn => "1234567890abc"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
        end
      end
      context "検索語が複数ある場合は" do
        it "OpenurlQuerySyntaxErrorを返す" do
          lambda {Openurl.new({:isbn => "987 321"})}.should raise_error(OpenurlQuerySyntaxError)
        end
      end
    end
    describe "issnの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語で始まるISSNの図書が検索できる" do
            openurl = Openurl.new({:issn => "12345"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result| result.issn =~ /\A12345/}
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:issn => "23456"})
            results = openurl.search
            results.should be_empty
          end
        end
        context "検索語が不正なとき" do
          context "桁数オーバーのとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {Openurl.new({:issn => "123456789"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
          context "数字以外のとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {Openurl.new({:issn => "123abc56"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
        end
      end
      context "検索語が複数ある場合は" do
        it "OpenurlQuerySyntaxErrorを返す" do
          lambda {Openurl.new({:issn => "123 456"})}.should raise_error(OpenurlQuerySyntaxError)
        end
      end
    end
    describe "anyの検索では" do
      context "検索語が一語の場合は" do
        context "一致するデータがあるとき" do
          it "検索語をいずれかの項目に含む図書が検索できる" do
            openurl = Openurl.new({:any => "テスト"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result|
              [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].inject('') do |txt, mtd|
                  txt + result.send(mtd).to_s
              end =~ /テスト/
            }
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:any => "テスト２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
      context "検索語が複数ある場合は" do
        context "一致するデータがあるとき" do
          it "全ての検索語をいずれかの項目に含む図書が検索できる" do
            openurl = Openurl.new({:any => "テスト 出版"})
            results = openurl.search
            results.should_not be_empty
            results.should be_all {|result|
              [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].inject('') do |txt, mtd|
                txt + result.send(mtd).to_s
              end =~ /出版.*テスト|テスト.*出版/i
            }
          end
        end
        context "一致するデータがないとき" do
          it "検索結果は0件となる" do
            openurl = Openurl.new({:any => "テスト テスト２"})
            results = openurl.search
            results.should be_empty
          end
        end
      end
    end
    describe "複合検索で" do
      describe "atitle,aulast,aufirst,pubを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に含む記事が検索できる" do
              openurl = Openurl.new({:atitle => "テスト", :aufirst => "作者", :aulast => "ダミー", :pub => "会社"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /テスト/
                result.creator.to_s =~ /作者.*ダミー|ダミー.*作者/
                result.publisher.to_s =~ /会社/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:atitle => "テスト", :aufirst => "作者", :aulast => "ダミー", :pub => "テスト"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が複数ある場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に全て含む記事が検索できる" do
              openurl = Openurl.new({:atitle => "記事 １月号", :aufirst => "作者", :aulast => "ダミー", :pub => "会社 試験"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /記事.*１月号|１月号.*記事/
                result.creator.to_s =~ /作者.*ダミー|ダミー.*作者/
                result.publisher.to_s =~ /会社.*試験|試験.*会社/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:atitle => "記事 １月号", :aufirst => "テスト", :aulast => "ダミー", :pub => "会社 試験"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が不正なとき" do
          context "複数語指定できない項目があるとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {openurl = Openurl.new({:atitle => "記事 １月号", :aufirst => "作者 ダミー", :aulast => "ダミー", :pub => "会社 試験"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
        end
      end
      describe "btitle,au,isbnを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に含む図書が検索できる" do
              openurl = Openurl.new({:btitle => "単行本", :au => "正式", :isbn => "98765"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /単行本/
                result.creator.to_s =~ /正式/
                result.isbn =~ /\A98765/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:btitle => "試験", :au => "テスト",:isbn => "98765"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が複数ある場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に全て含む図書が検索できる" do
              openurl = Openurl.new({:btitle => "単行本 テスト", :au => "テスト 名称", :isbn => "9876"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /単行本.*テスト|テスト.*単行本/
                result.creator.to_s =~ /テスト.*名称|名称.*テスト/
                result.isbn =~ /\A9876/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:btitle => "単行本 テスト", :au => "テスト 名称", :isbn => "876"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が不正なとき" do
          context "複数語指定できない項目があるとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {openurl = Openurl.new({:btitle => "単行本 テスト", :au => "テスト 名称", :isbn => "987 654"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
        end
      end
      describe "jtitle,issnを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に含む雑誌が検索できる" do
              openurl = Openurl.new({:jtitle => "テスト", :issn => "123456"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /テスト/
                result.issn =~ /\A123456/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:jtitle => "テスト", :issn => "23456"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が複数ある場合は" do
          context "一致するデータがあるとき" do
            it "各検索語を指定の検索項目に全て含む雑誌が検索できる" do
              openurl = Openurl.new({:jtitle => "２月号 テスト", :issn => "123456"})
              results = openurl.search
              puts "results.size = #{results.size}"
              results.each do |result|
                  puts "result.original_title = #{result.original_title}"
              end
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /テスト.*２月号|２月号.*テスト/
                result.issn =~ /\A123456/
              }
            end
          end
          context "一致するデータがないとき" do
            it "検索結果は0件となる" do
              openurl = Openurl.new({:jtitle => "３月号 テスト", :issn => "123456"})
              results = openurl.search
              results.should be_empty
            end
          end
        end
        context "検索語が不正なとき" do
          context "複数語指定できない項目があるとき" do
            it "OpenurlQuerySyntaxErrorを返す" do
              lambda {openurl = Openurl.new({:jtitle => "テスト ２月号", :isbn => "12 345"})}.should raise_error(OpenurlQuerySyntaxError)
            end
          end
        end
      end
      describe "any,isbnを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "isbnによる検索は行わず、anyで指定した検索語をいずれかの項目に含む図書が検索できる" do
              openurl = Openurl.new({:any => "テスト", :isbn => "55555"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                [:title, :fulltext, :note, :creator, :editor, :publisher, :subject].inject('') do |txt, mtd|
                    txt + result.send(mtd).to_s
                end =~ /テスト/
              }
            end
          end
        end
      end
      describe "atitle, btitle, jtitleを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "指定の検索語を含む記事のみが検索できる" do
              openurl = Openurl.new({:atitle => "テスト", :btitle => "雑誌", :jtitle => "雑誌"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /記事/
              }
            end
          end
        end
      end
      describe "btitle, jtitleを指定した場合" do
        context "検索語が一語の場合は" do
          context "一致するデータがあるとき" do
            it "指定の検索語を含む記事のみが検索できる" do
              openurl = Openurl.new({:btitle => "テスト", :jtitle => "雑誌"})
              results = openurl.search
              results.should_not be_empty
              results.should be_all {|result|
                result.original_title =~ /記事/
              }
            end
          end
        end
      end
    end
  end
end
