require "helper"

describe AkamaiCCU::CLI do
  let(:io) { StringIO.new }

  it "must warn if no contents are specified" do
    AkamaiCCU::CLI.new(args: ["none"], action: "invalidate", io: io).call
    Stubs.strip_log(io.string).must_equal "WARN -- : specify contents to purge by bulk, CP codes or urls"
  end

  it "must warn if no secret is specified" do
    AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}"], action: "invalidate", io: io).call
    Stubs.strip_log(io.string).must_equal "WARN -- : specify path to the secret file either by edgerc or by txt"
  end

  it "must warn if secret file does not exist" do
    AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}", "--edgerc=noent"], action: "invalidate", io: io).call
    Stubs.strip_log(io.string).must_equal "WARN -- : specified secret file does not exist"
  end

  it "must print the help" do
    begin
      AkamaiCCU::CLI.new(args: %w[--help], action: "invalidate", io: io).call
    rescue SystemExit
      io.string.must_equal "Usage: invalidate --edgerc=./.edgerc --production --cp=\"12345, 98765\"\n    -e, --edgerc=EDGERC              Load secret by .edgerc file\n    -t, --txt=TXT                    Load secret by TXT file\n    -c, --cp=CP                      Specify contents by provider (CP) codes\n    -u, --url=URL                    Specify contents by URLs\n    -b, --bulk=BULK                  Specify bulk contents in a file\n        --headers=HEADERS            Specify HTTP headers to sign\n    -p, --production                 Purge on production network\n    -h, --help                       Prints this help\n"
    end
  end

  it "must call invalidate on staging by cp code" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}", "--txt=#{Stubs.txt_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=tokens.txt;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765"
  end

  it "must call delete on production by cp url" do
    cli = AkamaiCCU::CLI.new(args: ["--url=#{Stubs.urls.join(",")}", "--edgerc=#{Stubs.edgerc_path}", "--production"], action: "delete", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/delete/url/production;objects=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js"
  end

  it "must call invalidate on production by bulk urls" do
    cli = AkamaiCCU::CLI.new(args: ["--bulk=#{Stubs.bulk_urls.path}", "--edgerc=#{Stubs.edgerc_path}", "--production"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/url/production;objects=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js"
  end

  it "must call delete on staging by bulk cpcodes" do
    cli = AkamaiCCU::CLI.new(args: ["--bulk=#{Stubs.bulk_codes.path}", "--edgerc=#{Stubs.edgerc_path}"], action: "delete", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/delete/cpcode/staging;objects=12345,98765"
  end

  it "must consider only CP codes when mixing entries in bulk file" do
    cli = AkamaiCCU::CLI.new(args: ["--bulk=#{Stubs.bulk_mixed.path}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765"
  end

  it "must warn of no contents when entries in bulk file are invalid" do
    cli = AkamaiCCU::CLI.new(args: ["--bulk=#{Stubs.bulk_invalid.path}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "WARN -- : specify contents to purge by bulk, CP codes or urls"
  end

  it "must give precedence to cp option if also url one is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--url=#{Stubs.urls.join(",")}", "--cp=#{Stubs.cpcodes.join(",")}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765"
  end

  it "must give precedence to bulk if also url option is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--url=#{Stubs.urls.join(",")}", "--bulk=#{Stubs.bulk_codes.path}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765"
  end

  it "must give precedence to bulk if also cpcode option is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}", "--bulk=#{Stubs.bulk_urls.path}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/url/staging;objects=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html,https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js"
  end

  it "must give precedence to edgerc if also txt option is specified" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}", "--txt=#{Stubs.txt_path}", "--edgerc=#{Stubs.edgerc_path}"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=.edgerc;endpoint=ccu/v3/invalidate/cpcode/staging;objects=12345,98765"
  end

  it "must accept headers to sign" do
    cli = AkamaiCCU::CLI.new(args: ["--cp=#{Stubs.cpcodes.join(",")}", "--txt=#{Stubs.txt_path}", "--headers=Accept,Content-Length"], action: "invalidate", io: io, wrapper_klass: Stubs::Wrapper, secret_klass: Stubs::Secret, endpoint_klass: Stubs::Endpoint)
    cli.call
    Stubs.strip_log(io.string).must_equal "INFO -- : secret=tokens.txt;endpoint=ccu/v3/invalidate/cpcode/staging;headers=Accept,Content-Length;objects=12345,98765"
  end
end
