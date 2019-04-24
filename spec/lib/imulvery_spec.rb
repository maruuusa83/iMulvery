require "spec_helper"
require "imulvery"

describe "BlockDiagram" do
  it "can be generated from a observable" do
    observable = Mulvery::Observable.from_array([1, 2, 3])
    instance = IMulvery::BlockDiagram.from_observable(observable)
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

