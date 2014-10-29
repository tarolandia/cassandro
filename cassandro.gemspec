# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cassandro"
  s.version = "0.1.0"
  s.summary = "Ruby ORM for Cassandra DB"
  s.license = "MIT"
  s.description = "Lightweight Cassandra ORM for Ruby"
  s.authors = ["Lautaro Orazi", "Leonardo Mateo"]
  s.email = ["orazile@gmail.com", "leonardomateo@gmail.com"]
  s.homepage = "https://github.com/tarolandia/cassandro"
  s.require_paths = ["lib"]
  s.add_dependency "cassandra-driver", '>= 1.0.0.beta.3'

  s.files = `git ls-files`.split("\n")
end
