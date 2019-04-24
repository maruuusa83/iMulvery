module Mulvery

class Matrix
  def initialize(array)
    check = _validity_check(array)
    if check.kind_of?(StandardError)
      raise check
    end

    @data = array
  end

  def [](pos)
    return @data[pos]
  end

  def transpose
    return Matrix.new(@data[0].zip(*@data[1..-1]))
  end

  def transpose!
    return @data = @data[0].zip(*@data[1..-1])
  end

  def to_array
    return @data
  end

  def row_size
    return @data.size
  end

  def column_size
    return @data[0].size
  end

  class InvalidElementType < StandardError
  end

  private
  def _validity_check(array)
    array.each do |col|
      unless col.kind_of?(Array)
        raise InvalidElementType
      end

      col.each do |element|
        unless element.kind_of?(Numeric)
          raise InvalidElementType
        end
      end
    end

    return true
  end
end

end
