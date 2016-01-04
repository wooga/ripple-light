require 'benchmark/ips'
require 'ripple-light'
require 'model/user'

default_data = JSON.parse(File.read('./spec/data/90kstate.json'), symbolyze_names: true)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("uncompressed") do |times|
    user = User.new(id: "u1", text: "hello world")
    user.save

    user.update_from_json(default_data)

    i = 0
    while i < times
      $compress = false
      user.text = "Hello Uncompressed #{i}"
      user.save
      user.reload
      i += 1
    end
  end

  x.report("compressed") do |times|
    user = User.new(id: "u2", text: "hello world")
    user.save

    user.update_from_json(default_data)

    i = 0
    while i < times
      $compress = true
      user.text = "Hello Compressed World #{i}"
      user.save
      user.reload
      i += 1
    end
  end

  x.compare!
end
