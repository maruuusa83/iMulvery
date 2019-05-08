require "spec_helper"
require "imulvery"
require "matrix"

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

  it "can reduce its stream" do
    ob1 = Mulvery::Observable.from_array([1, 2, 3, 4])

    ob1.reduce { |reg, d|
      reg += d
    }
  end

  it "s reduce can be called after zip" do
    ob1 = Mulvery::Observable.from_array([1, 2, 3, 4])
    ob2 = Mulvery::Observable.from_array([1, 2, 3, 4])

    ob1.zip(ob2).reduce { |reg, d|
      reg += d[0] + d[1]
    }
  end
end

describe "InputBus" do
  it "shuld foward passed data when sample_input_from_array is called" do
    ob = Mulvery::Observable.from_input

    ob.reduce { |reg, d|
      reg += d
    }
    .subscribe { |d|
      expect(d).to eq 15 unless d == nil
    }

    ob.sample_input_from_array([1, 2, 3, 4, 5])
    ob.execute
  end

  it "shuld calcurates scolor-multiply of vectors" do
    ob_1 = Mulvery::Observable.from_input
    ob_2 = Mulvery::Observable.from_input

    result = ob_1
      .zip(ob_2)
      .reduce do |reg, d|
        reg += d[0] * d[1]
      end
      .subscribe do |data|
        expect(data).to eq 70 unless data == nil
      end

    a_1 = [1, 2, 3, 4]
    a_2 = [5, 6, 7, 8]
    ob_1.sample_input_from_array(a_1)
    ob_2.sample_input_from_array(a_2)
    ob_1.execute
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
    matrix_2 = [[1, 1, 1, 1],
                [2, 2, 2, 2],
                [3, 3, 3, 3],
                [4, 4, 4, 4]]

    matrix_2 = Mulvery::Matrix.new(matrix_2).transpose.to_array
    
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
  end
end


