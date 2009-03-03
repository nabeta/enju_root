class Question < ActiveRecord::Base
  include LibrarianOwnerRequired
  named_scope :public_questions, :conditions => {:shared => true}
  named_scope :private_questions, :conditions => {:shared => false}
  belongs_to :user, :counter_cache => true, :validate => true
  has_many :answers

  validates_associated :user
  validates_presence_of :user, :body
  acts_as_soft_deletable
  acts_as_solr :fields => [:body, :answer_body, {:login => :string}, {:created_at => :date}, {:updated_at => :date}, {:shared => :boolean}], :auto_commit => false

  cattr_reader :per_page
  @@per_page = 10
  cattr_reader :crd_per_page
  @@crd_per_page = 5

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
    url = "http://api.porta.ndl.go.jp/servicedp/opensearch?dpid=refkyo&any=#{URI.escape(query)}&cnt=#{Question.crd_per_page}&idx=#{startrecord}"
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

  def is_readable_by(user, parent = nil)
    true if user == self.user || self.shared? || user.has_role?('Librarian')
  rescue
    false
  end

end
