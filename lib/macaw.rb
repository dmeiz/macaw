require 'openssl'
require 'yajl'

TRAFFIC = []

class TCPSocket
  alias_method :orig_write, :write
  alias_method :orig_sysread, :sysread
end

module TCPSocketRecordOverrides
  def write(str)
    TRAFFIC << ["write", str]
    orig_write(str)
  end

  def sysread(*args)
    output = orig_sysread(*args)
    TRAFFIC << ["gets", output]
    output
  end
end

module TCPSocketPlaybackOverrides
  def write(str)
    TRAFFIC.shift[1].length
  end

  def sysread(*args)
    TRAFFIC.shift[1]
  end
end

module Macaw
  module Methods
    def macaw(name, &block)
      if ENV["MACAW"] then
        record(name, block)
      else
        playback(name, block)
      end
    end

  private
    def record(name, block)
      TCPSocket.send(:include, TCPSocketRecordOverrides)
      block.call
      File.open("test/#{name}.json", "w") do |f|
        Yajl::Encoder.encode(TRAFFIC, f)
      end
    end

    def playback(name, block)
      if File.exist?("test/#{name}.json")
        TRAFFIC.concat Yajl::Parser.new.parse(File.new("test/#{name}.json", "r"))
        TCPSocket.send(:include, TCPSocketPlaybackOverrides)
        block.call
      else
        record(name, block)
      end
    end
  end

  module OpenSSLOverrides
    def print(str)
      TRAFFIC << ["print", str]
      orig_print(str)
    end

    def gets(*args)
      output = orig_gets(*args)
      TRAFFIC << ["gets", output]
      output
    end

    def read(str)
      output = orig_read(str)
      TRAFFIC << ["read", output]
      output
    end
  end
end
