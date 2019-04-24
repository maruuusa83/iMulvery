module Mulvery

class Observable
  def initialize(source)
    @module_list = [source]

    _add_module(source)
  end

  def self.from_array(array)
    Observable.new(ObservableNode.new(:source, {type: :from_array, array: array}))
  end

  def zip(*args)
    args.each { |d|
      if !d.kind_of?(Observable)
        raise RuntimeError, "Illigal argment type, expected Observable"
      end
    }

    _add_module(ObservableNode.new(:zip, {observables: args}))
    
    return self
  end

  def reduce(&blk)
    _add_module(ObservableNode.new(:reduce, {lambda_abs: blk}))

    return self
  end

  private
  def _add_module(source)
    if !source.kind_of?(ObservableNode)
        raise RuntimeError, "Illigal argment type, expected ObservableNode"
    end

    @module_list.push(source)
  end

  class ObservableNode
    def initialize(type, info)
      @type = type
      @info = info
    end
  end
end

end
