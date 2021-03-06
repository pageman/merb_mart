require "bigdecimal"

module Mart
  module Shipping
    class Weight

      include DataMapper::Resource

      property :id,         Integer,     :serial => true
      property :min_weight, Float,      :default => 0.0, :nullable => false
      property :max_weight, Float,      :default => 0.0, :nullable => false
      property :price,      BigDecimal, :default => 0.0, :nullable => false
      property :order_shipping_type_id, Integer  # foreign-key

      belongs_to :type

    end
  end
end
