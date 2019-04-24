require "spec_helper"
require "matrix"

describe "Matrix" do
  it "can be generated" do
    Mulvery::Matrix.new([[1, 2, 3], [1, 2, 3], [1, 2, 3]])
    Mulvery::Matrix.new([[1, 2, 3]])

    expect {
      Mulvery::Matrix.new([1, 2, 3])
    }.to raise_error(Mulvery::Matrix::InvalidElementType)

    expect {
      Mulvery::Matrix.new([[1, 2, 3], ['x', 2, 3], [1, 2, 3]])
    }.to raise_error(Mulvery::Matrix::InvalidElementType)
  end

  it "can transpose itself" do
    result = Mulvery::Matrix.new([[1, 2, 3]]).transpose
    expect(result.to_array).to eq([[1], [2], [3]])

    result = Mulvery::Matrix.new([[1, 2, 3], [4, 5, 6], [7, 8, 9]]).transpose
    expect(result.to_array).to eq([[1, 4, 7], [2, 5, 8], [3, 6, 9]])
  end
end

