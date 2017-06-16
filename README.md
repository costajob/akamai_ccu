## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)

## Scope
This gem is a minimal wrapper of the [Akamai Content Control Utility API](https://developer.akamai.com/api/purge/ccu/overview.html) APIs used to purge Edge content by request.  
The library is compliant with *CCU API V3*, based on the *Fast Purge* utility.

## Motivation
A gem to interact with Akamai APIs layer already exists: [akamai-edgegrid](https://github.com/akamai/AkamaiOPEN-edgegrid-ruby).
The gem is aimed to sign the HTTP request in order for the Akamai endpoint to recognise the client.  
I've rewritten the akamai-edgegrid functionality for several reasons:
* the gem is not written with idiomatic ruby, indeed it resembles a Perl script
* the Net::HTTP class is extended, when decorating the request object is preferable
* the gem ignore the single responsibility principle by encapsulating the whole logic into a single class
* i prefer not relying on external dependencies for such a small library
* my library also includes a client to ease the connection with the CCU interface

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
