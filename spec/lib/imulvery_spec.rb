require "spec_helper"
require "imulvery"

describe "BlockDiagram" do
  before do
    @instance = IMulvery::BlockDiagram.new
  end

  it "can generate a block design" do
    @instance.add_module(
      "test_module",
      {clk: 1, din: 32, valid: 1},
      {result: 32, enable: 1})
    result = @instance.read
  end
end

