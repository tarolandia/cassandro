# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "cassandro"
  s.version = "0.3.1"
  s.summary = "Ruby ORM for Apache Cassandra"
  s.license = "MIT"
  s.description = "Lightweight Apache Cassandra ORM for Ruby"
  s.authors = ["Lautaro Orazi", "Leonardo Mateo"]
  s.email = ["orazile@gmail.com", "leonardomateo@gmail.com"]
  s.homepage = "https://github.com/tarolandia/cassandro"
  s.require_paths = ["lib"]
  s.add_dependency "cassandra-driver", '>= 1.0.0.rc.1'
  s.add_development_dependency "protest", '~> 0.5.3'

  s.files = `git ls-files`.split("\n")
end
