require "spec_helper"
require "imulvery"

require "rx"

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


