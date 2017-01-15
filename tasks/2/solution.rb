class Hash
  def fetch_deep(key_path)
    key, nested_key_path = key_path.split('.', 2)
    value = try_get_value(key)

    return value unless nested_key_path
    return value.fetch_deep(nested_key_path) if value
  end

  def reshape(shape)
    shape.map do |key, value|
      (value.is_a? Hash) ? [key, reshape(value)] : [key, fetch_deep(value)]
    end.to_h
  end

  private
  def try_get_value(key)
    key && (self[key] || self[key.to_sym])
  end
end

class Array
  def fetch_deep(key_path)
    key, nested_key_path = key_path.split('.', 2)
    value = self[key.to_i]

    return value unless nested_key_path
    return value.fetch_deep(nested_key_path) if value
  end

  def reshape(shape)
    map { |hash| hash.reshape(shape) }
  end
end
