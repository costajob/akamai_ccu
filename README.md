## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
  * [akamai-edgerid](#akamai-edgerid)
* [Installation](#installation)
  * [Configuration](#configuration)
    * [edgerc](#edgerc)
    * [txt](#txt)
* [Usage](#usage)
  * [Library](#library)
    * [Secret](#secret)
    * [Edge network](#edge-network)
    * [Invalidating](#invalidating)
    * [Deleting](#deleting)
  * [CLI](#cli)
    * [Help](#help)
    * [ccu_invalidate](#ccu_invalidate)
    * [ccu_delete](#ccu_delete)
    * [Bulk operation](#bulk-operation)
    * [Redirecting output](#redirecting-output)
    * [Overwriting options](#overwriting-options)
  * [Logging](#logging)
    * [Library logger](#library-logger)
    * [CLI logger](#cli-logger)
  * [Possible issues](#possible-issues)
    * [Invalid timestamp](#invalid-timestamp)
    * [No wildcard](#no-wildcard)
    * [Mixed bulk](#mixed-bulk)

## Scope
This gem is a minimal wrapper of the [Akamai Content Control Utility](https://developer.akamai.com/api/purge/ccu/overview.html) APIs used to purge Edge content by request.  
The library is compliant with [CCU API V3](https://developer.akamai.com/api/purge/ccu/resources.html), based on the *Fast Purge Utility*.

## Motivation
The gem has two main responsibilities:
1. sign the request with proper Authorization headers
2. provide a wrapper around the CCU V3 APIs

### akamai-edgerid
There's an official gem by Akamai to sign HTTP headers called [akamai-edgegrid](https://github.com/akamai/AkamaiOPEN-edgegrid-ruby).  
I've opted to go with my own implementation for the following reasons:
* the official gem is not written in idiomatic ruby
* Net::HTTP core class is extended, ignoring composition/decoration
* single responsibility principle is broken
* i prefer not relying on external dependencies when possible

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

### Configuration
This gem requires you have a valid Akamai Luna Control Center account, enabled to add APIs clients.  
Upon APIs client creation, you'll get the `client token` to be used to generate new APIs credentials data: these consist of a secret key, two token (client and access) and a dedicated host for API authorization.  
Check Akamai's [official documentation](https://developer.akamai.com/introduction/Conf_Client.html) for more details.  
You have two main options to import credentials data:

#### edgerc
You can generate (using a script or by hand) an INI file named `.edgerc`:
```
[default]
client_secret = xxx=
host = akaa-baseurl-xxx-xxx.luna.akamaiapis.net/
access_token = akab-access-token-xxx-xxx
client_token = akab-client-token-xxx-xxx
max-body = 131072
```

#### txt
You can download a plain text file upon credentials data creation:
```
client_secret = xxx=

host = akaa-baseurl-xxx-xxx.luna.akamaiapis.net/

access_token = akab-access-token-xxx-xxx

client_token = akab-client-token-xxx-xxx
```

## Usage

### Library
You can require the gem to use it as a library inside your scripts:

#### Secret
Once you've got APIs credentials, you can instantiate the secret object aimed to generate the authorization header:
```ruby
require "akamai_ccu"

# by file, both .edgerc or .txt one
secret = AkamaiCCU::Secret.by_file("~/tokens.txt") # default to ~/.edgerc

# by using initializer
secret = AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", max_body: 131072)
```

The next step is setting the `Wrapper` class with the secret object, the secret and Net::HTTP client instances are shared between calls:
```ruby
AkamaiCCU::Wrapper.setup(secret)
```

#### Edge network
Purging actions runs on the `staging` network by default.  
Switch to `production` network by just appending a shebang `!` on the method name.

#### Invalidating
The CCU V3 APIs allow for invalidating contents by URLs or content provider (CP) codes: currently only the former relies on the Fast Purge Utility.  
```ruby
# invalidating resources on staging by URLs
AkamaiCCU::Wrapper.invalidate_by_url(%w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html])

# invalidating resources on production (mind the "!") by CP code
AkamaiCCU::Wrapper.invalidate_by_cpcode!([12345, 98765])
```

#### Deleting
You can delete contents by URLs or CP codes as well, just be aware of what you're doing:
```ruby
# deleting resources on staging by CP codes
AkamaiCCU::Wrapper.delete_by_cpcode([12345, 98765])

# deleting resources on production (mind the "!") by URLs
AkamaiCCU::Wrapper.delete_by_url!(%w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js])
```

#### Response
The Net::HTTP response is wrapped by an utility struct:
```ruby
res = AkamaiCCU::Wrapper.invalidate_by_cpcode([12345, 98765])
puts res 
# status=201; detail=Request accepted; purge_id=e535071c-26b2-11e7-94d7-276f2f54d938; support_id=17PY1492793544958045-219026624; copletion_at=20170620T11:19:16+0000
```

### CLI
You can use the CLI by:

#### Help
Calling the help for the specific action:
```shell
ccu_invalidate -h
Usage: ccu_invalidate --secret=~/.edgerc --production --cp=12345,98765
    -s, --secret=SECRET              Load secret by file (default to ~/.edgerc)
    -c, --cp=CP                      Specify contents by provider (CP) codes
    -u, --url=URL                    Specify contents by URLs
    -b, --bulk=BULK                  Specify bulk contents in a file
        --headers=HEADERS            Specify any HTTP headers to sign
    -p, --production                 Purge on production network
    -h, --help                       Prints this help
```

#### ccu_invalidate
Do request for contents invalidation by:
```shell
ccu_invalidate --secret=~/.edgerc \ 
               --url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.css,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js \
               --production
```

#### ccu_delete
Do request for contents deletion by:
```shell
ccu_delete --secret=~/tokens.txt \ 
           --cp=12345,98765 \
           --headers=Accept,Content-Length
```

#### Bulk operation
In case you have multiple contents to work with, it could be impractical to write several entries on the CLI.  
Just specify them on a separate file and use the bulk option:

`urls.txt` file with URL entries specified on a new line:
```txt
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.css
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/static/index.html
```

Specify the bulk option by using the file path:
```shell
ccu_invalidate --secret=~/.edgerc --bulk=urls.txt
```

#### Redirecting output
In case you're calling the CLI from another program (like your Jenkins script), just redirect the output to your log file:
```shell
ccu_invalidate --secret=~/.edgerc --cp=12345,98765 >> mylog.log
```

#### Overwriting options
The CLI allows different options to specify the contents to be purged.  
If multiple options for contents are provided, the program runs by specific precedence rules:

##### Options precedence
The `bulk` option has always precedence over the `cp` one, that has precedence over  `url`:

This command will invalidate by URLs:
```shell
ccu_invalidate --secret=~/tokens.txt \
               --cp=12345,98765
               --bulk=urls.txt
```

This command will delete by CP codes:
```shell
ccu_delete --secret=~/tokens.txt \
           --cp=12345,98765
           --url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.css,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js
```

### Logging

#### Library logger
By default the `Wrapper` class accepts a logger pointing to `dev/null`. 
In case you want to replace it with yours, just use the class attribute writer:
```ruby
AkamaiCCU::Wrapper.logger = Logger.new(STDOUT)
```

#### CLI logger
CLI uses a logger writing to `STDOUT` by default with an `INFO` level.  
In case you want to control the log level, just pass an environment variable to the script:
```shell
LOG_LEVEL=DEBUG ccu_invalidate --secret=~/.edgerc --cp=12345,98765
```

### Possible Issues

#### Invalid timestamp
You could get a `bad request` response like this:
```shell
status=400; title=Bad request; detail=Invalid timestamp; request_id=2ce206fd; method=POST; requested_at=2017-06-21T12:33:10Z
```

This happens since Akamai APIs only tolerate a clock skew of at most 30 seconds to defend against certain network attacks (described [here](https://community.akamai.com/docs/DOC-1336)).  
In order to fix this annoying issue please do synchronize you server clock by:
* `NTP` versus a stratum 2 server, if you are running on UX OS
* `manually` versus an [atomic clock site](https://watches.uhrzeit.org/atomic-clock.php) by using your workstation GUI

#### No wildcard
Do keep in mind CCU V3 APIs doesn't support contents specification by wildcard.

#### Mixed bulk
When specifying contents by bulk on the CLI, you cannot include both CP codes and URLs resources on the same file. 
The library tries to detect which mode to use basing on entries kind: mixing them will generate unexpected behaviour.
