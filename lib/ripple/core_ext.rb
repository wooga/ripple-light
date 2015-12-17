require 'active_support/json/encoding'

class Integer
  #def self.ripple_cast(value)
  #  value ? value.to_i : nil
  #end
end

class String
  def self.ripple_cast(value)
    value ? value.to_s : nil
  end
end

class Time
  def self.ripple_cast(value)
    value ? value.to_time : nil
  end

  def as_json(options={})
    self.utc.send(Ripple.date_format)
  end
end

NilClass.class_eval do
  def attributes_for_persistence
    nil
  end
end