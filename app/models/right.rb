
class Right
  
  include DataMapper::Resource
  
  many_to_many  :roles

  property :id,         Fixnum, :serial => true
  property :name,       String
  property :controller, String
  property :actions,    String

end