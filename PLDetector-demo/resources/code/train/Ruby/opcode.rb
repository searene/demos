module Dvi::Opcode
  class Error < StandardError; end
  class NotImplemented < StandardError; end

  # Base is a super class for all Opcode classes.
  class Base
    # Sets the range of opcode byte.
    def self.set_range(r)
      if r.kind_of?(Range)
        @range = r
      else
        @range = r..r
      end
    end

    # Returns the range of opcode byte.
    def self.range
      return @range
    end

    def self.read(cmd, io) #:nodoc:
      return self.new
    end

    def interpret(ps) #:nodoc:
      raise NotImplemented, self
    end
  end

  # SetChar is a class for set_char_0 ... set_char_127 opcodes.
  class SetChar < Base
    set_range 0..127
    attr_reader :index

    # index:: character index
    def initialize(index)
      raise ArgumentError unless 0 <= index && index < 256
      @index = index
    end

    def self.read(cmd, io) #:nodoc:
      return self.new(cmd)
    end

    # Appends a character and changes the current position.
    def interpret(ps)
      # append a new character
      ps.chars << char = Dvi::TypesetCharacter.new(@index, ps.h, ps.v, ps.font)
      # change the current position
      unless self.kind_of?(Put)
        ps.h += ps.font.design_size * char.metric.width
      end
    end
  end

  # PrintChar is a base class for set/put opcodes.
  class SetPutBase < SetChar

    # index:: character index
    # n:: read byte length
    def initialize(index, n)
      if case n
         when 1; 0 <= index && index < 256
         when 2; 0 <= index && index < 65536
         when 3; 0 <= index && index < 16777216
         when 4; -2147483648 <= index && index < 2147483648
         end
      then
        @index = index
      else
        raise ArgumentError, [index, n]
      end
    end

    def self.read(cmd, io) #:nodoc:
      base = if self == Set then 127 else 132 end
      n = cmd - base
      f = if n < 4 then "read_uint" + n.to_s else "read_int4" end
      return self.new(io.__send__(f), n)
    end
  end

  # Set is a class for set1 ... set4 opcodes.
  class Set < SetPutBase
    set_range 128..131
  end

  # Put is a class for put1 ... put4 opcodes.
  class Put < SetPutBase
    set_range 133..136
  end

  # RuleBase is a base class for SetRule/PutRule opcodes.
  class RuleBase < Base
    attr_reader :height, :width

    def initialize(height, width)
      unless (-2147483648..2147483647).include?(height) and
          (-2147483648..2147483647).include?(width)
        raise ArgumentError
      end

      @height = height
      @width = width
    end

    def self.read(cmd, io)
      return self.new(io.read_int4, io.read_int4)
    end

    def interpret(ps)
      # append a new rule.
      ps.rules << rule = Dvi::Rule.new(ps.h, ps.v, @height, @width)
      # change the current position.
      ps.h += @width unless self.kind_of?(PutRule)
    end
  end

  # SetRule is a class for set_rule opcode.
  class SetRule < RuleBase
    set_range 132
  end

  # PutRule is a class for put_rule opcode.
  class PutRule < RuleBase
    set_range 137
  end

  # Nop is a class for nop opcode. The nop opcode means "no operation."
  class Nop < Base
    set_range 138
    # do nothing.
    def interpret(ps); end
  end

  # Bop is a class for bop opcode. The bop opcode means "begging of a page."
  class Bop < Base
    set_range 139
    attr_reader :counters, :previous

    def initialize(counters, previous)
      raise ArgumentError if counters.size != 10
      # \count0 ... \count9
      @counters = counters
      # previous bop
      @previous = previous
    end

    def self.read(cmd, io) #:nodoc:
      # read \count0 ... \count9
      counters = (0..9).map{ io.read_int4 }
      # read previous bop position
      previous = io.read_int4
      return self.new(counters, previous)
    end

    def interpret(ps)
      # clear register
      ps.h = 0
      ps.v = 0
      ps.w = 0
      ps.x = 0
      ps.y = 0
      ps.z = 0
      # set the stack empty
      ps.stack.clear
      # set current font to an undefined value
      ps.font = nil
      # !!! NOT IMPLEMENTED !!!
      # Ci?
    end
  end

  # Eop is a class for eop opcode. The eop opcode means "end of page."
  class Eop < Base
    set_range 140
    def interpret(ps)
      # the stack should be empty.
      ps.stack.clear
    end
  end

  # Push is a class for push opcode.
  class Push < Base
    set_range 141
    def interpret(ps)
      # push current registry to the stack.
      ps.stack.push([ps.h, ps.v, ps.w, ps.x, ps.y, ps.z])
    end
  end

  # Pop is a class for pop opcode.
  class Pop < Base
    set_range 142
    def interpret(ps)
      # pop the stack and set it to current registry.
      ps.h, ps.v, ps.w, ps.x, ps.y, ps.z = ps.stack.pop
    end
  end

  class ChangeRegister0 < Base
    def self.read(cmd, io)
      base = case cmd
             when Right.range; 142
             when W.range; 148
             when X.range; 152
             when Down.range; 156
             when Y.range; 161
             when Z.range; 166
             else return self.new
             end
      return self.new(io.__send__("read_int" + (cmd - base).to_s))
    end
  end

  class ChangeRegister < ChangeRegister0
    attr_reader :size

    def initialize(size)
      @size = size
    end
  end

  # Right is a class for right1 ... right4 opcodes.
  class Right < ChangeRegister
    set_range 143..146
    def interpret(ps)
      # move right.
      ps.h += @size
    end
  end

  # W0 is a class for w0 opcode.
  class W0 < ChangeRegister0
    set_range 147
    def interpret(ps)
      # move right.
      ps.h += ps.w
    end
  end

  # W is a class for w1 ... w4 opcodes.
  class W < ChangeRegister
    set_range 148..151
    def interpret(ps)
      # change w.
      ps.w = @size
      # move right.
      ps.h += @size
    end
  end

  # X0 is a class for x0 opcode.
  class X0 < ChangeRegister0
    set_range 152
    def interpret(ps)
      # move right.
      ps.h += ps.x
    end
  end

  # X is a class for x1 ... x4 opcodes.
  class X < ChangeRegister
    set_range 153..156
    def interpret(ps)
      # change x.
      ps.x = @size
      # move right.
      ps.h += ps.x
    end
  end

  # Down is a class for down1 ... down4 opcodes.
  class Down < ChangeRegister
    set_range 157..160

    def interpret(ps)
      # move down.
      ps.v += @size
    end
  end

  # Y0 is a class for y0 opcode.
  class Y0 < ChangeRegister0
    set_range 161
    def interpret(ps)
      # move down.
      ps.v += ps.y
    end
  end

  # Y is a class for y1 ... y4 opcodes.
  class Y < ChangeRegister
    set_range 162..165
    def interpret(ps)
      # change y.
      ps.y = @size
      # move down.
      ps.v += @size
    end
  end

  # Z0 is a class for z0 opcode.
  class Z0 < ChangeRegister0
    set_range 166

    # Moves down processor's z.
    def interpret(ps)
      ps.v += ps.z
    end
  end

  # Z is a class for z1 ... z4 opcode.
  class Z < ChangeRegister
    set_range 167..170

    # Changes processor's z and moves down z.
    def interpret(ps)
      # change z.
      ps.z = @size
      # move down.
      ps.v += @size
    end
  end

  # FunNum is a class for fnt_num_0 ... fnt_num_63 opcodes.
  class FntNum < Base
    set_range 171..234
    attr_reader :index

    def initialize(index)
      raise ArgumentError unless 0 <= index && index <= 63
      @index = index
    end

    def self.read(cmd, io)
      return self.new(cmd - 171)
    end

    # Changes the current processor's font.
    # The font should be defined by fnt_def1 .. fnt_def4.
    def interpret(ps)
      raise Error unless ps.fonts.has_key?(@index)
      ps.font = ps.fonts[@index]
    end
  end

  # Fnt is a class for fnt1 ... fnt4 opcodes.
  class Fnt < FntNum
    set_range 235..238

    def initialize(index, n)
      unless case n
         when 1; 0 <= index && index < 256
         when 2; 0 <= index && index < 65536
         when 3; 0 <= index && index < 16777216
         when 4; -2147483648 <= index && index < 2147483648
         else false end
        raise ArgumentError
      end
    end

    def self.read(cmd, io)
      n = cmd - 234
      f = if n < 4 then "read_uint" + n.to_s else "read_int" + n.to_s end
      return self.new(io.__send__(f), n)
    end
  end

  # XXX is a class for xxx1 ... xxx4 opcodes.
  class XXX < Base
    set_range 239..242
    attr_reader :content

    def initialize(content, n)
      @content = content
    end

    def self.read(cmd, io)
      n = cmd - 238
      size = buf.__send__("read_uint" + n.to_s)
      content = io.read(size)
      return self.new(content, n)
    end

    # do nothing
    def interpret(ps); end
  end

  # FntDef is a class for fnt_def1 ... fnt_def4 opcodes.
  class FntDef < Base
    set_range 243..246
    attr_reader :num, :checksum, :scale, :design_size, :area, :fontname

    def initialize(num, checksum, scale, design_size, area, fontname)
      @num = num
      @checksum = checksum
      @scale = scale
      @design_size = design_size
      @area = area
      @fontname = fontname
    end

    def self.read(cmd, io)
      n = cmd - 242
      num = if n < 4 then io.__send__("read_uint" + n.to_s) else io.read_int4 end
      checksum = io.read_uint4
      scale = io.read_uint4
      design_size = io.read_uint4
      a = io.read_uint1
      l = io.read_uint1
      area = io.read(a)
      fontname = io.read(l)
      return self.new(num, checksum, scale, design_size, area, fontname)
    end

    def interpret(ps)
      tfm = Dvi::Tfm.read(ps.lsr.find(@fontname + ".tfm"))
      ps.fonts[@num] =
        Dvi::Font.new(@checksum, @scale, @design_size, @area, @fontname, tfm)
    end
  end

  # Pre is a class for preamble opcode.
  class Pre < Base
    set_range 247
    attr_reader :version, :num, :den, :mag, :comment

    def initialize(version, num, den, mag, comment)
      raise ArgumentError unless num > 0 && den > 0 && mag > 0
      @version = version # maybe version is 2
      @num = num         # maybe 25400000 = 254cm
      @den = den         # maybe 473628672 = 7227*(2**16)
      @mag = mag         # mag / 1000
      @comment = comment # not interpreted
    end

    def self.read(cmd, io)
      version = io.read_uint1
      num = io.read_uint4
      den = io.read_uint4
      mag = io.read_uint4
      size = io.read_uint1
      comment = io.read(size)
      return self.new(version, num, den, mag, comment)
    end

    def interpret(ps)
      ps.dvi_version = @version
      ps.numerator = @num
      ps.denominator = @den
      ps.mag = @mag
    end
  end

  # Post is a class for post opcode.
  class Post < Base
    set_range 248
    attr_reader :final_bop, :num, :den, :mag, :l, :u, :stack_depath, :pages

    def initialize(pointer, num, den, mag, l, u, stack_depth, total_pages)
      @final_bop = pointer # final bop pointer
      @num = num           # same as preamble
      @den = den           # same as preamble
      @mag = mag           # same as preamble
      @l = l               # height plus depth of the tallest page
      @u = u               # width of the widest page
      @stack_depth = stack_depth # maximum stack depth
      @total_pages = total_pages # total number of pages
    end

    def self.read(cmd, io)
      pointer = io.read_uint4
      num = io.read_uint4
      den = io.read_uint4
      mag = io.read_uint4
      l = io.read_uint4
      u = io.read_uint4
      stack_size = io.read_uint2
      pages = io.read_uint2
      return self.new(pointer, num, den, mag, l, u, stack_size, pages)
    end

    def interpret(ps)
      ps.total_pages = @total_pages
    end
  end

  # PostPost is a class for post_post opcode.
  class PostPost < Base
    set_range 249

    def initialize(pointer)
      @pointer = pointer # a pointer to the post command
    end

    def self.read(cmd, io) #:nodoc:
      pointer = io.read_uint4
      dvi_version = io.read_uint1
      # read padding 233
      io.read.unpack("C*").each do |i|
        raise Error unless i == 223
      end
      return self.new(pointer)
    end

    def interpret(ps)
      # ???
    end
  end

  BASIC_OPCODES = [SetChar, Set, SetRule, Put, PutRule, Nop, Bop, Eop, Push, Pop,
                   Right, W0, W, X0, X, Down, Y0, Y, Z0, Z, FntNum, XXX, FntDef,
                   Pre, Post, PostPost]
end
