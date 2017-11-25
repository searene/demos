class Dvi::Tfm::Format
  class Error < StandardError; end
  class NotImplemented < StandardError; end

  # CharInfo is a class for char_info section.
  class CharInfo
    attr_reader :width_index, :height_index, :depth_index, :italic_index
    attr_reader :tag, :remainder
    def initialize(width_index, height_index, depth_index, italic_index,
                   tag, remainder)
      @width_index = width_index
      @height_index = height_index
      @depth_index = depth_index
      @italic_index = italic_index
      @tag = tag
      @remainder = remainder
    end
  end

  # LigKern is a class for lig/kern section.
  class LigKern
    attr_reader :skip_byte, :next_char, :op_byte, :remainder
    def initialize(skip_byte, next_char, op_byte, remainder)
      @skip_byte = skip_byte
      @next_char = next_char
      @op_byte = op_byte
      @remainder = remainder
    end
  end

  # ExtensibleRecipe is a class for extensible recipe section.
  class ExtensibleRecipe
    attr_reader :top, :mid, :bot, :rep
    def initialize(top, mid, bot, rep)
      @top = top
      @mid = mid
      @bot = bot
      @rep = rep
    end
  end

  attr_reader :lf, :lh, :bc, :ec, :nw, :nh, :nd, :ni, :nl, :nk, :ne, :np
  attr_accessor :checksum, :design_size, :font_coding_scheme, :font_identifier
  attr_accessor :seven_bit_safe_flag, :face
  attr_reader :charinfo, :lig_kern_table, :kern_table, :extensible_recipe, :param

  def initialize(io)
    raise ArgumentError unless io.kind_of?(IO)
    read_tfm_header(io)
    read_header_data(io)
    read_char_info_table(io)
    read_width_table(io)
    read_height_table(io)
    read_depth_table(io)
    read_italic_table(io)
    read_lig_kern_table(io)
    read_kern_table(io)
    read_extensible_recipes(io)
    read_params(io)
  end

  def build
    @chars = Array.new
    @char_info_table.each_with_index do |char_info, idx|
      unit = (2**(-20.0))

      # sizes
      w = @width_table[char_info.width_index] * unit
      h = @height_table[char_info.height_index] * unit
      d = @depth_table[char_info.depth_index] * unit
      i = @italic_table[char_info.italic_index] * unit

      # lig/kern
      k = Hash.new
      l = Hash.new

      case char_info.tag
      when 0
        # do nothing
      when 1
        idx = char_info.remainder
        next_lig_kern = true

        while next_lig_kern do
          lk = @lig_kern_table[idx]

          if lk.op_byte >= 128
            # kerning
            amount = @kern_table[256*(lk.op_byte-128)+lk.remainder]
            k[lk.next_char] = Dvi::Tfm::Kerning.new(lk.next_char, amount)
          else
            # ligature
            a, b, c = case lk.op_byte
                      when 0; [0, 0, 0]
                      when 1; [0, 0, 1]
                      when 2; [0, 1, 0]
                      when 3; [0, 1, 1]
                      when 5; [1, 0, 0]
                      when 6; [1, 1, 0]
                      when 7; [1, 1, 1]
                      when 11; [2, 1, 1]
                      else raise Error end
            l[lk.next_char] = Dvi::Tfm::Ligature.new(a, b, c, lk.remainder)
          end

          # next?
          if lk.skip_byte >= 128
            next_lig_kern = false
          else
            idx += (1 + lk.skip_byte)
          end
        end
      when 2
        raise NotImplemented
      when 3
        raise NotImplemented
      else
        raise Error
      end

      @chars << Dvi::Tfm::Char.new(w, h, d, i, k, l)
    end
    Dvi::Tfm::Data.new(@design_size,
                       @font_coding_scheme,
                       @font_identifier,
                       @chars,
                       @param)
  end

  ### PRIVATE ###

  private

  def read_tfm_header(io) #:nodoc:
    # change the position
    io.seek(0)

    # section positions
    @lf, @lh, @bc, @ec, @nw, @nh, @nd, @ni, @nl, @nk, @ne, @np =
      io.read(24).unpack("n12")

    # set positions
    @pos = Hash.new
    @pos[:ci] = (6 + @lh) * 4
    @pos[:nw] = @pos[:ci] + (@ec - @bc + 1) * 4
    @pos[:nh] = @pos[:nw] + @nw * 4
    @pos[:nd] = @pos[:nh] + @nh * 4
    @pos[:ni] = @pos[:nd] + @nd * 4
    @pos[:nl] = @pos[:ni] + @ni * 4
    @pos[:nk] = @pos[:nl] + @nl * 4
    @pos[:ne] = @pos[:nk] + @nk * 4
    @pos[:np] = @pos[:ne] + @ne * 4

    # validation
    raise Error unless @bc - 1 <= @ec and @ec <= 255 and ne <= 256
    lf = 7 + @lh + @ec - @bc + @nw + @nh + @nd + @ni + @nl + @nk + @ne + @np
    raise Error unless @lf == lf
  end

  def read_header_data(io) #:nodoc:
    # change the position
    io.seek(24)

    # checksum
    @checksum = io.read(4)

    # design size
    @real_design_size = io.read(4).unpack("N").first
    @design_size = @real_design_size * (2**(-20.0))

    # font coding scheme
    if @lh > 2
      size = io.read(1).unpack("C").first
      @font_coding_scheme = io.read(size)
    end

    # font identifier / font family
    if @lh > 12
      io.seek(72)
      size = io.read(1).unpack("C").first
      @font_identifier = io.read(size)
    end

    # other data
    if @lh > 17
      io.seek(92)
      byte = io.read(4).unpack("C4")
      @seven_bit_safe_flag = byte[0]
      @face = byte[3]
    end
  end

  def read_char_info_table(io) #:nodoc:
    # change the position
    io.seek @pos[:ci]

    @char_info_table = (0..(@ec - @bc)).map do
      # read 4 bytes
      byte = io.read(4).unpack("c4")

      CharInfo.new(byte[0],              # width index  (8 bits)
                   byte[1] >> 4,         # height index (4 bits)
                   byte[1] & 0b00001111, # depth index  (4 bits)
                   byte[2] >> 2,         # italic index (6 bits)
                   byte[2] & 0b00000011, # tag index    (2 bits)
                   byte[3])              # remainder    (8 bits)
    end
  end

  def read_width_table(io)
    # change the position
    io.seek @pos[:nw]

    # collect each word
    @width_table = (1..@nw).map{ io.read(4).unpack("N").first }

    # validation
    raise Error unless @width_table[0] == 0
  end

  def read_height_table(io)
    # change the position
    io.seek @pos[:nh]

    # collect each word
    @height_table = (1..@nh).map{ io.read(4).unpack("N").first }

    # validation
    raise Error unless @height_table[0] == 0
  end

  def read_depth_table(io)
    # change the position
    io.seek @pos[:nd]

    # collect each word
    @depth_table = (1..@nd).map{ io.read(4).unpack("N").first }

    # validation
    raise Error unless @depth_table[0] == 0
  end

  def read_italic_table(io)
    # change the position
    io.seek @pos[:ni]

    # collect each word
    @italic_table = (1..@ni).map{ io.read(4).unpack("N").first }

    # validation
    raise Error unless @italic_table[0] == 0
  end

  def read_lig_kern_table(io)
    # change the position
    io.seek @pos[:nl]

    # collect each word
    @lig_kern_table = (1..@nl).map{ LigKern.new(*io.read(4).unpack("C4")) }
  end

  def read_kern_table(io)
    # change the position
    io.seek @pos[:nk]

    # collect each word
    @kern_table = (1..@nk).map do
      # signed long little endian
      io.read(4).unpack("N").pack("l").unpack("l").first
    end
  end

  def read_extensible_recipes(io)
    # change the position
    io.seek @pos[:ne]

    # collect each word
    @extensible_recipe = (1..@ne).map do
      ExtensibleRecipe.new(*io.read(1).unpack("C4"))
    end
  end

  def read_params(io)
    # change the position
    io.seek @pos[:np]

    # collect each word
    @param = (1..@np).map{ io.read(4).unpack("N").first }
  end
end
