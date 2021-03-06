module MinimedRF
  class Message
    attr_accessor :bits

    def initialize(data)
      @bits = data.unpack("B*").first
    end

    def self.check_bit_block_definitions
      used_bits = {}
      bit_blocks.each do |key, block|
        ((block.first)..(block.first+block.last-1)).each do |bit|
          raise "Bit block #{key} redefines bit #{bit} already defined by #{used_bits[bit]}" if used_bits.include?(bit)
          used_bits[bit] = key
        end
      end
    end

    def self.from_hex(hex_str)
      new([hex_str].pack('H*'))
    end

    def hex_str
      [@bits].pack("B*").unpack("H*").first
    end

    def bit_blocks
      self.class.bit_blocks
    end

    def b(name)
      range = bit_blocks[name]
      raise "Unknown bit block: #{name}" if range.nil?
      #puts "b(#{name.inspect}) = #{range}"
      Integer("0b" + @bits.send("[]", *range))
    end

    def print_bit_differences(other)
      (0..(@bits.length-1)).each do |idx|
        if bits[idx] == other.bits[idx]
          print bits[idx]
        else
          print bits[idx].colorize(:red)
        end
      end
      print "\n"
    end

    def print_unused_bytes
    end

    def print_unused_bits
      blocks = bit_blocks.values.sort_by {|b| b.first}
      idx = 0
      output = []
      blocks.each do |b|
        raise "Invalid range: #{b.inspect}." if b.first < idx
        if idx < b.first
          output << [(idx..(b.first-1)), :unused]
        end
        output << [(b.first)..(b.first+b.last-1), :used]
        idx = b.first + b.last
      end
      if idx < @bits.length - 1
        output << [(idx..(@bits.length-1)), :unused]
      end
      output.each do |block|
        print @bits[block.first].colorize(block.last == :used ? :white : :light_grey)
      end
      print "\n"
      nil
    end
  end
end
