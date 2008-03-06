# A section is an organizational unit for content nodes.
#
# Sections can be applied to pages or snippets, but really are
# only meant for blogs.
#
class Section < DataMapper::Base
  
  has_and_belongs_to_many :content_nodes
  has_and_belongs_to_many :blogs,
    :join_table => 'content_nodes_sections',
    :association_foreign_key => 'content_node_id',
    :conditions => "content_nodes.type = 'Blog'",
    :order => 'display_on DESC'
    
  property :name, :string, :length => 100, :default => "", :nullable => false
  property :rank, :integer
  #property :parent_id --> 
    
  #validates_presence_of :name
  #validates_uniqueness_of :name
  is_a_tree :order => 'rank' # '-rank DESC'
  
  # Most used finder function for tags.
  # Selects by alpha sort.
  def self.find_alpha
    all  #:order => 'name ASC')
  end
  
  # Finds ordered parent tags.
  def self.find_ordered_parents
    all(:conditions => "parent_id IS NULL OR parent_id = 0")
      #:order => "-rank DESC"
  end
  
  # Returns the number of products tagged with this item
  def content_count
    @cached_content_count ||= self.content_nodes.count
  end
  
end