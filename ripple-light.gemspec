Gem::Specification.new do |spec|
  spec.name = "ripple-light"
  spec.version = "1.0.0"
  spec.authors = ["Stefan Mees", "Giuseppe Modarelli"]
  spec.email = ["stefan.mees@wooga.net", "giuseppe.modarelli@wooga.net"]

  spec.summary     = "Riak KV ORM"
  spec.description = "Document based ORM for the Riak KV store"
  spec.homepage    = "http://github.com/wooga/ripple-light"
  spec.license     = "MIT"

  spec.date = "2013-03-27"
  spec.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 3.2.12"
  spec.add_dependency "activemodel", "~> 3.2.12"
  spec.add_dependency "riak-client", "~> 1.4.3"
  spec.add_dependency "json", "~> 1.8.6"
  spec.add_dependency "snappy", "~> 0.0.12"

  spec.add_development_dependency "byebug", "~> 9.1.0"
  spec.add_development_dependency "rspec", "~> 3.6.0"
  spec.add_development_dependency "rake", "~> 10.0.3"
  spec.add_development_dependency "benchmark-ips", "~> 2.3.0"
  spec.add_development_dependency "ruby-prof", "~> 0.15.8"
end

