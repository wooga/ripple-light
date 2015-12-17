class Email
  include Ripple::EmbeddedDocument

  property :address,     String, :short => :a

  embedded_in :customer

end