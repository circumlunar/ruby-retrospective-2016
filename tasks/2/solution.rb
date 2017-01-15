class Hash
  def fetch_deep(path)
    keys = path.split('.', 2)
    value = try_get_value(keys.first)
    return value unless keys[1]
    return value.fetch_deep(keys[1]) if [Hash, Array].member? value.class
  end

  def reshape(shape)
    shape.map do |key, value|
      [key, (value.is_a? Hash) ? reshape(value) : fetch_deep(value)]
    end.to_h
  end

  private
  def try_get_value(key)
    key && (self[key] || self[key.to_sym])
  end
end

class Array
  def fetch_deep(path)
    keys = path.split('.', 2)
    value = self[keys[0].to_i]
    return value unless keys[1]
    return value.fetch_deep(keys[1]) if [Hash, Array].member? value.class
  end

  def reshape(shape)
    map { |hash| hash.reshape(shape) }
  end
end