require 'openssl'
@@traffic = []
class TCPSocket

  alias_method :orig_write, :write
  def write(str)
    @@traffic << ["write", str]
    orig_write(str)
  end

  alias_method :orig_sysread, :sysread
  def sysread(*args)
    output = orig_sysread(*args)
    @@traffic << ["gets", output]
    output
  end
end

module Macaw
  module Methods
    def macaw(host, port) 
      if ENV["MACAW"] then
        Socket.send(:alias_method, :orig_write, :write)
        Socket.send(:alias_method, :orig_sysread, :sysread)
        #Socket.extend(SocketOverrides)
=begin
        ::OpenSSL::SSL::SSLSocket.send(:alias_method, :orig_print, :print)
        ::OpenSSL::SSL::SSLSocket.send(:alias_method, :orig_gets, :gets)
        ::OpenSSL::SSL::SSLSocket.send(:alias_method, :orig_read, :read)
=end
        yield host, port
      else
        yield "localhost", 5200
      end
    end
  end


  module OpenSSLOverrides
    def print(str)
      @@traffic << ["print", str]
      orig_print(str)
    end

    def gets(*args)
      output = orig_gets(*args)
      @@traffic << ["gets", output]
      output
    end

    def read(str)
      output = orig_read(str)
      @@traffic << ["read", output]
      output
    end
  end
end
