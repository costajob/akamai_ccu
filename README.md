## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
  * [akamai- edgerid](#akamai-edgerid)
* [Installation](#installation)
* [Usage](#usage)

## Scope
This gem is a minimal wrapper of the [Akamai Content Control Utility](https://developer.akamai.com/api/purge/ccu/overview.html) APIs used to purge Edge content by request.  
The library is compliant with *CCU API V3*, based on the *Fast Purge* utility.

## Motivation
The gem has two main responsibilities:
1. sign the request to send to Akamai with proper Authorization headers
2. provide a wrapper around the Akamai CCU V3 APIs

### akamai-edgerid
There is an official gem to sign HTTP headers by Akamai: [akamai-edgegrid](https://github.com/akamai/AkamaiOPEN-edgegrid-ruby).
I've decided to go with my own implementation for the following reasons:
* the gem is not written in idiomatic ruby
* Net::HTTP core class is extended, ignoring composition
* the single responsibility principle is broken by a single class
* i prefer to not rely on external dependencies ;)

## Installation
Add this line to your application's Gemfile:
```ruby
gem "akamai_ccu"
```

And then execute:
```shell
bundle
```

Or install it yourself as:
```shell
gem install akamai_ccu
```

## Usage
You can use this library by including it directly into your script or by relying on a command line interface:

### Inside your scripts
Include the library directly into your Ruby code:

### CLI
Call the CLI interface by:
