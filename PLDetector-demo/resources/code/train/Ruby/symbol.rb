class Symbol
  def to_json(options = {}) #:nodoc:
    ActiveSupport::JSON.encode_sentence(to_s, options)
  end
end
