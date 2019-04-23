require "spec_helper"
require "imulvery"

require "rx"

describe "Observable" do
  it "can be generated from array" do
    array = [1, 2, 3, 4]
    Mulvery::Observable.from_array(array)
  end

  it "will be zipped with Observables" do
    array1 = [1, 2, 3, 4]
    array2 = [1, 2, 3, 4]
    array3 = [1, 2, 3, 4]
    ob1 = Mulvery::Observable.from_array(array1)
    ob2 = Mulvery::Observable.from_array(array2)
    ob3 = Mulvery::Observable.from_array(array3)

    zipped = ob1.zip(ob2)
    zipped = ob1.zip(ob2, ob3)

    expect {
      zipped = ob1.zip(array1)
    }.to raise_error(RuntimeError)
  end
end

describe "Mulvery" do
  before do
    @instance = IMulvery::BlockDiagram.new
  end

  it "can generate a block diagram" do
    matrix_1 = [[1, 1, 1, 1],
                [2, 2, 2, 2],
                [3, 3, 3, 3],
                [4, 4, 4, 4]]
    matrix_2 = [[1, 2, 3, 4],
                [1, 2, 3, 4],
                [1, 2, 3, 4],
                [1, 2, 3, 4]]

    result = matrix_2.map { |vec_2|
      matrix_1.map { |vec_1|
        v_1_o = Rx::Observable.from_array(vec_1)
        v_2_o = Rx::Observable.from_array(vec_2)

        v_1_o.zip(v_2_o)
          .reduce(0) { |reg, d|
            reg + (d[0] * d[1])
          }
      }
    }

    check = []
    result.each { |d|
      d.each { |v|
        v.subscribe { |e| check.push(e) }
      }
    }

    p check
  end
end


