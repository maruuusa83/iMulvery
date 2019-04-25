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
end

