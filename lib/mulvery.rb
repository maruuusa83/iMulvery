module Mulvery

class Observable
  def initialize(source)
    @data_path = []

    _add_module(source)
  end

  attr_accessor :data_path

  class << self
    def from_array(array)
      Observable.new(ObservableNode.new(:source, {type: :from_array, array: array}))
    end

    def from_input
      InputBus.new(ObservableNode.new(:source, {type: :from_in}))
    end
  end

  def first
    forward_data
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

  def subscribe(&blk)
    _add_module(ObservableNode.new(:subscribe, {lambda_abs: blk}))

    return self
  end

  def execute
    raise "The end of this observable is not subscribe." if @data_path[-1].type != :subscribe
    while !@data_path[0].reg.empty?
      forward_data
    end
  end

  def dump
    count = 0
    @data_path.each do |element|
      print "#{count}: #{element.type}, #{element.info}\n"

      count += 1
    end
  end

  class ObservableNode
    def initialize(type, info)
      @type = type
      @info = info

      @reg = 0
    end

    def receive(*arg)
      case @type
      when :source
        @reg.shift
      when :reduce
        if arg[0] == :end_signal
          result = @reg
          @reg = :end_signal
          result
        else
          if @reg == :end_signal
            :end_signal
          else
            @reg = @info[:lambda_abs].call(@reg, arg[0])
            nil
          end
        end
      when :zip
        @reg = [arg[0]]
        @info[:observables].each do |obs|
          @reg.push(obs.first)
        end

        if @reg.include?(:end_signal)
          :end_signal
        else
          @reg
        end
      when :subscribe
        if arg[0] != nil && arg[0] != :end_signal
          @info[:lambda_abs].call(arg[0])
        end
      end
    end

    attr_accessor :type, :info, :reg
  end

  private
  def _add_module(source)
    if !source.kind_of?(ObservableNode)
        raise RuntimeError, "Illigal argment type, expected ObservableNode"
    end

    @data_path.push(source)
  end

  def forward_data
    before_data = nil
    for i in 0...@data_path.size
      before_data = @data_path[i].receive(before_data)
    end

    before_data
  end
end

class InputBus < Observable
  def sample_input_from_array(array)
    array.push(:end_signal)
    @data_path[0].reg = array

    self
  end
end

end
