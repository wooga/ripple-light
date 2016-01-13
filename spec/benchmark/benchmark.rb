require 'benchmark/ips'
require 'riak'
require 'ripple/serializers'

user_state = JSON.parse(File.read('./spec/data/20kstate.json'), symbolyze_names: true)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("uncompressed") do |times|
    i = 0
    while i < times
      binary = Riak::Serializers['application/json'].dump(user_state)
      Riak::Serializers['application/json'].load(binary)
      i += 1
    end
  end

  x.report("compressed") do |times|
    i = 0
    while i < times
      binary = Riak::Serializers['application/x-snappy'].dump(user_state)
      Riak::Serializers['application/x-snappy'].load(binary)
      i += 1
    end
  end

  x.compare!
end
