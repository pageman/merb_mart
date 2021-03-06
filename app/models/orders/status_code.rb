module Mart
  module Orders
    class StatusCode

      include DataMapper::Resource

      property :id,   Integer, :serial => true
      property :name, String, :length => 30, :nullable => false

      has n, :orders

    end
  end
end
