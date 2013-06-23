class Expression < ActiveRecord::Base
  belongs_to :content_type
  attr_accessible :original_title, :content_type_id, :work_id,
    :manifestation_id, :note, :language,
    :manifestation_url
  has_one :reify
  has_one :work, :through => :reify
  has_many :realizes, :dependent => :destroy, :foreign_key => 'expression_id'
  has_many :contributors, :through => :realizes, :source => :person #, :order => 'realizes.position'
  has_many :embodies
  has_many :manifestations, :through => :embodies
  has_many :children_relationships, :foreign_key => 'parent_id', :class_name => 'WorkRelationship', :dependent => :destroy
  has_many :parents_relationships, :foreign_key => 'child_id', :class_name => 'WorkRelationship', :dependent => :destroy
  has_many :children, :through => :children_relationships, :source => :child
  has_many :parents, :through => :parents_relationships, :source => :parent

  validates :original_title, :presence => true
  #validates :manifestation_url, :presence => true, :on => :create

  after_save :generate_graph if Setting.generate_graph

  searchable do
    text :original_title
    integer :work_id do
      work.id if work
    end
    integer :manifestation_ids, :multiple => true
  end

  attr_accessor :work_id, :manifestation_id, :manifestation_url

  def generate_graph
    begin
    return nil unless work
    work.generate_graph
    g = GraphViz::new("G", :type => :graph, :use => "dot")
    g.node[:shape] = "box"
    g.node[:color] = "blue"
    g.node[:fontsize] = 10

    e = g.add_nodes("[E#{id}] #{language} #{content_type.name}", "URL" => "/expressions/#{id}", :fontcolor => "red", :shape => 'box', :color => 'blue')
    w = g.add_nodes("[W#{work.id}] #{work.original_title}", "URL" => "/works/#{work.id}", :shape => 'box', :color => 'blue')
    g.add_edges(w, e)

    manifestations.each do |manifestation|
      m = g.add_nodes("[M#{manifestation.id}] #{manifestation.cinii_title}", "URL" => "/manifestations/#{manifestation.id}")
      g.add_edges(e, m)
      manifestation.expressions.each do |expression|
        if expression != self
          e2 = g.add_nodes("[E#{expression.id}] #{expression.language} #{expression.content_type.name}", "URL" => "/expressions/#{expression.id}")
          g.add_edges(e2, m)

          w2 = g.add_nodes("[W#{expression.work.id}] #{expression.work.original_title}", "URL" => "/works/#{expression.work.id}")
          g.add_edges(w2, e2)
        end
      end
    end
    g.output(:png => "#{Rails.root.to_s}/public/expressions/#{id}.png")
    g.output(:svg => "#{Rails.root.to_s}/public/expressions/#{id}.svg")
  rescue
    nil
  end
  end
end
