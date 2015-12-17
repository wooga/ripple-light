class Bar
  include Ripple::Document

  property :foo,     String, :short => :f
  property :default, String, :short => :d, :default => 'bar'
end