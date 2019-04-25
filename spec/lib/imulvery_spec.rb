require "spec_helper"
require "imulvery"

describe "BlockDiagram" do
  it "can be generated from a observable" do
    observable = Mulvery::Observable.from_array([1, 2, 3])
    instance = IMulvery::BlockDiagram.from_observable(observable)

    result = instance.build_map
  end

  it "can be generated from a observable" do
    observable0 = Mulvery::Observable.from_array([1, 2, 3])
    observable1 = Mulvery::Observable.from_array([1, 2, 3])
    observable = observable0.zip(observable1).reduce
    instance = IMulvery::BlockDiagram.from_observable(observable)

    result = instance.build_map
  end

  it "can generate a block design" do
    @instance = IMulvery::BlockDiagram.new
    @instance.add_module(
      "test_module",
      {clk: 1, din: 32, valid: 1},
      {result: 32, enable: 1})
    result = @instance.read
  end
end

