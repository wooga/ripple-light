class Car
  include Ripple::Document

  property :name,     String, :short => :n

  many :tire, :class_name => 'Tire', :short => :t

end