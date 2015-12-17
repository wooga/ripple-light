class Customer
  include Ripple::Document

  property :name,     String, :short => :n

  one :email, :class_name => 'Email', :short => :e

end