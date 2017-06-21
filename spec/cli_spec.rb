require "helper"

describe AkamaiCCU::CLI do
  let(:io) { StringIO.new }

  it "must warn if no secret is specified" do
    AkamaiCCU::CLI.new(args: ["none"], action: "invalidate", io: io).call
    io.string.must_equal "Specify contents to purge either by cp codes or by urls\n"
  end

  it "must warn if no objects are specified" do
    AkamaiCCU::CLI.new(args: ["--cp=12345,98765"], action: "invalidate", io: io).call
    io.string.must_equal "Specify path to the secret file either by edgerc or by txt\n"
  end

  it "must print the help" do
    begin
      AkamaiCCU::CLI.new(args: %w[--help], action: "invalidate", io: io).call
    rescue SystemExit
      io.string.must_equal "Usage: invalidate --edgerc=./.edgerc --production --cp=\"12345, 98765\"\n    -e, --edgerc=EDGERC              Load secret by .edgerc file\n    -t, --txt=TXT                    Load secret by TXT file\n    -c, --cp=CP                      Specify contents by provider (CP) codes\n    -u, --url=URL                    Specify contents by URLs\n        --headers=HEADERS            Specify HTTP headers to sign\n    -p, --production                 Purge on production network\n    -h, --help                       Prints this help\n"
    end
  end

  it "must call invalidate on staging by cp code" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=12345,98765", "--txt=./tokens.txt"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    io.string.must_equal "secret=./tokens.txt;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765\n"
  end

  it "must call delete on production by cp url" do
    cli = AkamaiCCU::CLI.new(args: ["--url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js", "--edgerc=.edgerc", "--production"], action: "delete", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    io.string.must_equal "secret=.edgerc;endpoint=ccu/v3/delete/url/production;objects=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js\n"
  end

  it "must give precedence to cpcode if also url option is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--url=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/*.js", "--cp=12345,98765", "--edgerc=.edgerc"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    io.string.must_equal "secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765\n"
  end

  it "must give precedence to edgerc if also txt option is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=12345,98765", "--txt=./tokens.txt", "--edgerc=.edgerc"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    io.string.must_equal "secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765\n"
  end

  it "must accept headers to sign" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=12345,98765", "--txt=./tokens.txt", "--headers=Accept,Content-Length"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    io.string.must_equal "secret=./tokens.txt;endpoint=ccu/v3/invalidate/cpcode/staging;headers=Accept,Content-Length;objects=12345,98765\n"
  end
end
