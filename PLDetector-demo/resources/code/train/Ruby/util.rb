module Dvi::Util
  def read_uint1
    readchar
  end

  def read_uint2
    (readchar << 8) | readchar
  end

  def read_uint3
    (readchar << 16) | read_uint2
  end

  def read_uint4
    (readchar << 24) | read_uint3
  end

  def read_int1
    ui = read_uint1
    ui & 128 != 0 ? ui - 256 : ui
  end

  def read_int2
    ui = read_uint2
    ui & 32768 != 0 ? ui - 65536  : ui
  end

  def read_int3
    ui = read_uint3
    ui & 8388608 != 0 ? ui - 16777216 : ui
  end

  def read_int4
    ui = read_uint4
    ui & 2147483648 != 0 ? ui - 4294967296  : ui
  end
end
