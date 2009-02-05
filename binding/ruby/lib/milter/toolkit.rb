module Milter
  class Logger
    @@domain = "milter-manager"
    class << self
      def domain
        @@domain
      end

      def domain=(domain)
        @@domain = domain
      end

      def error(message)
        default.log(:error, message, 1)
      end

      def critical(message)
        default.log(:critical, message, 1)
      end

      def message(message)
        default.log(:message, message, 1)
      end

      def warning(message)
        default.log(:warning, message, 1)
      end

      def debug(message)
        default.log(:debug, message, 1)
      end

      def info(message)
        default.log(:info, message, 1)
      end

      def statistics(message, n_call_depth=nil)
        default.log(:statistics, message, 1)
      end
    end

    def log(level, message, n_call_depth=nil)
      unless level.is_a?(Milter::LogLevelFlags)
        level = Milter::LogLevelFlags.from_string(level.to_s)
      end
      n_call_depth ||= 0
      file, line, info = caller[n_call_depth].split(/:(\d+):/, 3)
      ensure_message(message).each_line do |one_line_message|
        log_full(self.class.domain, level, file, line.to_i, info,
                 one_line_message.chomp)
      end
    end

    private
    def ensure_message(message)
      case message
      when nil
        ''
      when String
        message
      when Exception
        "#{message.class}: #{message.message}:\n#{message.backtrace.join("\n")}"
      else
        message.inspect
      end
    end
  end

  module SocketAddress
    class IPv4
      def local?
        bit1, bit2, bit3, bit4 = address.split(/\./).collect {|bit| bit.to_i}
        return true if bit1 == 127
        return true if bit1 == 10
        return true if bit1 == 172 and (16 <= bit2 and bit2 < 32)
        return true if bit1 == 192 and bit2 == 168
        false
      end
    end

    class IPv6
      def local?
        abbreviated_before, abbreviated_after = address.split(/::/)
        bits_before = abbreviated_before.split(/:/)
        bits_after = (abbreviated_after || '').split(/:/)
        abbreviated_bits_size = 8 - bits_before.size - bits_after.size
        bits = bits_before + (["0"] * abbreviated_bits_size) + bits_after
        bits = bits.collect {|bit| bit.to_i(16)}
        return true if bits == [0, 0, 0, 0, 0, 0, 0, 0x0001]
        return true if bits[0] == 0xfe80
        false
      end
    end

    class Unix
      def local?
        true
      end
    end
  end

  class ProtocolAgent
    def set_macros(context, macros)
      macros.each do |name, value|
        set_macro(context, name, value)
      end
    end
  end
end
