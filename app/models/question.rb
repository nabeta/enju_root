class Question < ActiveRecord::Base
  belongs_to :user, :counter_cache => true, :validate => true
  has_many :answers

  validates_associated :user
  validates_presence_of :user, :body
  acts_as_soft_deletable
  acts_as_solr :fields => [:body, :answer_body, {:login => :string}, {:created_at => :date}, {:updated_at => :date}, {:private_question => :boolean}], :auto_commit => false

  cattr_reader :per_page
  @@per_page = 10

  def answer_body
    text = ""
    self.reload
    self.answers.each do |answer|
      text += answer.body
    end
    return text
  end

  def login
    self.user.login
  end

  def self.refkyo_search(query, startrecord = 1)
    doc = nil
    if startrecord < 1
      startrecord = 1
    end
    url = "http://api.porta.ndl.go.jp/servicedp/opensearch?dpid=refkyo&any=#{URI.escape(query)}&cnt=#{Manifestation.per_page}&idx=#{startrecord}"
    open(url){|f|
      doc = REXML::Document.new(f)
    }
    results = {}
    resources = []
    total_count = doc.elements['/rss/channel/openSearch:totalResults/text()'].to_s.strip.to_i
    doc.elements.each('/rss/channel/item') do |item|
      resources << item
    end
    refkyo_resources = []
    resources.each do |ref|
      r = {}
      r[:title] = ref.elements['title/text()'].to_s
      r[:link] = ref.elements['link/text()'].to_s
      refkyo_resources << r
    end 
    results[:total_count] = total_count
    results[:resources] = refkyo_resources
    return results
  end

end
