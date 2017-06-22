## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
  * [akamai-edgerid](#akamai-edgerid)
* [Installation](#installation)
* [Usage](#usage)
  * [Configuration](#configuration)
    * [edgerc](#edgerc)
    * [txt](#txt)
  * [Inside your script](#inside-your-script)
    * [Secret](#secret)
    * [Invalidating](#invalidating)
    * [Deleting](#deleting)
    * [Reuse client](#reuse-client)
  * [CLI](#cli)
    * [Help](#help)
    * [ccu_invalidate](#ccu_invalidate)
    * [ccu_delete](#ccu_delete)
    * [Bulk operation](#bulk-operation)
    * [Redirecting output](#redirecting-output)
    * [Overwriting options](#overwriting-options)
  * [Possible issues](#possible-issues)

## Scope
This gem is a minimal wrapper of the [Akamai Content Control Utility](https://developer.akamai.com/api/purge/ccu/overview.html) APIs used to purge Edge content by request.  
The library is compliant with [CCU API V3](https://developer.akamai.com/api/purge/ccu/resources.html), based on the *Fast Purge* utility.

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

## Usage

### Configuration
This gem requires you have a valid Akamai Luna Control Center account, enabled to use the CCU APIs.  
Akamai relies on a credentials file with three secret keys and a dedicated host for API authorization.  
Detailing how to get this file is out of the scope of this readme, check Akamai's [official documentation](https://developer.akamai.com/introduction/Conf_Client.html) for that.  
Suffice to say you have two main options:

#### edgerc
You can generate (by facility script or by hand) a specific file named `.edgerc`:
```
[default]
client_secret = xxx=
host = akaa-baseurl-xxx-xxx.luna.akamaiapis.net/
access_token = akab-access-token-xxx-xxx
client_token = akab-client-token-xxx-xxx
max-body = 131072
```

#### txt
You can download a plain text file directly from Luna Control Center `Manage APIs` page:
```
client_secret = xxx=

host = akaa-baseurl-xxx-xxx.luna.akamaiapis.net/

access_token = akab-access-token-xxx-xxx

client_token = akab-client-token-xxx-xxx
```

### Inside your script
You can obviously use the gem directly inside your Ruby's script:

#### Secret
Once you've got APIs credentials, you can instantiate the secret object aimed to generate the authorization header:
```ruby
require "akamai_ccu"

# by .edgerc
secret = AkamaiCCU::Secret.by_edgerc(".edgerc")

# by txt file
secret = AkamaiCCU::Secret.by_txt("tokens.txt")

# by specifying arguments
secret = AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", max_body: 131072)
```

#### Invalidating
The CCU V3 APIs allow for invalidating the contents by URL or content provider (CP) code:
```ruby
# invalidating resources on staging by url
AkamaiCCU::Wrapper.invalidate_by_url(%w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html], secret)

# invalidating resources on production (mind the "!") by CP code
AkamaiCCU::Wrapper.invalidate_by_cpcode!([12345, 98765], secret)
```

#### Deleting
You can also delete the contents by URL or CP code, just be aware of the consequences:
```ruby
# deleting resources on staging by CP code
AkamaiCCU::Wrapper.delete_by_cpcode([12345, 98765], secret)

# deleting resources on production (mind the "!") by url
AkamaiCCU::Wrapper.delete_by_url!(%w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js], secret)
```

#### Reuse client
By default `Wrapper` class methods create a brand new Net::HTTP client on each call.  
If this is an issue for you, you can use the `Wrapper#call` instance method and update the `endpoint` collaborator to switch API:
```ruby
wrapper = AkamaiCCU::Wrapper.new(secret: secret, endpoint: AkamaiCCU::Endpoint.by_name("invalidate_by_url"))
wrapper.call(%w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.css])

# switch to deleting on production
wrapper.endpoint = AkamaiCCU::Endpoint.by_name("delete_by_cpcode!")
wrapper.call([12345, 98765])
```

#### Response
The Net::HTTP response is wrapped by an utility struct:
```ruby
res = AkamaiCCU::Wrapper.invalidate_by_cpcode([12345, 98765], secret)
puts res 
# status=201; detail=Request accepted; purge_id=e535071c-26b2-11e7-94d7-276f2f54d938; support_id=17PY1492793544958045-219026624; copletion_at=20170620T11:19:16+0000
```

### CLI
You can use the CLI by:

#### Help
Calling the help for the specific action:
```shell
ccu_invalidate -h
Usage: invalidate --edgerc=./.edgerc --production --cp="12345, 98765"
    -e, --edgerc=EDGERC              Load secret by .edgerc file
    -t, --txt=TXT                    Load secret by TXT file
    -c, --cp=CP                      Specify contents by provider (CP) codes
    -u, --url=URL                    Specify contents by URLs
    -b, --bulk=BULK                  Specify bulk contents in a file
        --headers=HEADERS            Specify HTTP headers to sign
    -p, --production                 Purge on production network
    -h, --help                       Prints this help
```

#### ccu_invalidate
You can request for contents invalidation by calling:
```shell
ccu_invalidate --edgerc=~/.edgerc \ 
               --url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.css,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js \
               --production
```

#### ccu_delete
You can request for contents deletion by calling:
```shell
ccu_delete --txt=~/tokens.txt \ 
           --cp=12345,98765 \
           --headers=Accept,Content-Length
```

#### Bulk operation
In case you have multiple contents to work with, it could be impractical to write several entries on the CLI.  
Just specify them on a separate file and use the bulk option:

`urls.txt` file with each url/CP code specified on one line:
```txt
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.css
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js
https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/static/*.html
```

Specify the bulk option by using the file path:
```shell
ccu_invalidate --edgerc=~/.edgerc --bulk=urls.txt
```

##### Do not mix content types
You cannot specify both CP codes and URLs on the same bulk file, mind being consistent!

#### Redirecting output
In case you're calling the CLI from another program (like your Jenkins script), just redirect the output to your log file:
```shell
ccu_invalidate --edgerc=~/.edgerc --cp=12345,98765 > mylog.log
```

#### Overwriting options
The CLI does allow only one option to specify the secret file and the content objects.  
If multiple options for the same scope are provided, the program runs by giving precedence to:

##### Secret file
The `edgerc` option has always precedence over the `txt` one:
```shell
# will load secret from ~/.edgerc
ccu_invalidate --txt=~/tokens.txt \
               --edgerc=~/.edgerc \
               --cp=12345,98765
```

##### Content objects
The `bulk` option has always precedence over the `cp` one, that has precedence over the `url`:

This command will invalidate by urls:
```shell
ccu_invalidate --txt=~/tokens.txt \
               --cp=12345,98765
               --bulk=urls.txt
```

This command will delete by CP codes:
```shell
ccu_delete --txt=~/tokens.txt \
           --cp=12345,98765
           --url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.css,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js
```

### Possible Issues
It happens you can get a `bad request` response by Akamai like this:
```shell
status=400; title=Bad request; detail=Invalid timestamp; request_id=2ce206fd; method=POST; requested_at=2017-06-21T12:33:10Z
```

This happens since Akamai APIs only tolerate a clock skew of at most 30 seconds to defend against certain network attacks (described [here](https://community.akamai.com/docs/DOC-1336)).  
In order to fix this annoying issue please do synchronize you server clock by:
* `NTP` if you are on a UX server
* `manually` versus an atomic clock site (check Internet) by using your workstation GUI
