# Cassandro [![Gem Version](https://badge.fury.io/rb/cassandro.svg)](http://badge.fury.io/rb/cassandro)

Cassandro is a small Ruby ORM for Apache Cassandra 2.0 and CQL 3.0. Cassandro uses the new [Datastax Ruby Driver](https://github.com/datastax/ruby-driver)

## Install
 
`gem install cassandro`

## Changelog

### v2.0
* Support `cassandra-driver` >= 2.0
* Allow registering indexes in model's definition

### v1.2
* TTL
 * Model-wide TTL
 * Single record TTL
* Support `:set` datatype
* Ignore columns not definied on model

## Documentation

* [Getting Started](docs/getting_started.md)
* [Migrations](docs/migrations.md)
* [Modeling](docs/modeling.md)
* [Querying](docs/querying.md)
* [Advanced Features](docs/advanced_features.md)

## TODO

* Improve querying

## How to collaborate

If you find a bug or want to collaborate with the code, you can:

* Report issues trhough the issue tracker
* Fork the repository into your own account and submit a Pull Request
