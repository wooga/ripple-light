class Tire
  include Ripple::EmbeddedDocument

  property :foo,     Integer, :short => :a

  embedded_in :car

end