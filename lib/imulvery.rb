require_relative './mulvery'

require_relative './module_renderer'
require 'pango'

module IMulvery

class BlockDiagram
  def self.from_observable(observable)
    return BlockDiagram.new.add_observable(observable)
  end

  def initialize()
    @modules = []
    @observables = []
  end

  def add_module(name, i_pins, o_pins)
    @modules.push({name: name, inputs: i_pins, outputs: o_pins})

    return self
  end

  def add_observable(observable)
    unless observable.kind_of?(Mulvery::Observable)
      raise RuntimeError, "Illigal Type"
    end

    @observables.push(observable)

    return self
  end

  def build_map
    # Generate Modules
    modules = []
    max_width = 0
    pos_y = 10
    @observables.each do |observable|
      pos_x = 10
      max_height = 0

      observable.data_path.each do |mod|
        mod_info = {}
        
        case mod.type
        when :source then
          mod_info = {name: "src", inputs: {}, outputs: {out: 1}, pos: [pos_x, pos_y]}
        when :zip then
          inputs = {}
          for i in 0..mod.info[:observables].size
            inputs["din_#{i}"] = 1
          end
          mod_info = {name: "zip", inputs: inputs, outputs: {out: 1}, pos: [pos_x, pos_y]}
          mod.info[:observables].each do |obs|
            @observables.push(obs)
          end
        when :reduce then
          mod_info = {name: "reduce", inputs: {in: 1}, outputs: {out: 1}, pos: [pos_x, pos_y]}
        when :subscribe then
          mod_info = {name: "subscribe", inputs: {in: 1}, outputs: {}, pos: [pos_x, pos_y]}
        end

        mr = ModuleRenderer
          .new(
            mod_info[:name],
            mod_info[:inputs],
            mod_info[:outputs],
            mod_info[:pos])

        modules.push(mr)

        pos_x += mr.width + 30
        if max_height < mr.height
          max_height = mr.height
        end
      end

      if max_width < pos_x
        max_width = pos_x
      end

      pos_y += max_height + 20
    end

    # Initialize Cairo
    canbus_width  = max_width + 10
    canbus_height = pos_y + 10
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, canbus_width, canbus_height)
    context = Cairo::Context.new(surface)

    # Write Backgrownd
    context.set_source_rgb(0.9, 0.9, 0.9)
    context.rectangle(0, 0, canbus_width, canbus_height)
    context.fill

    # Write Modules
    modules[0].render(context)
    for i in 1...modules.size
      modules[i].render(context)
    end


    # Write image to StringIO
    buffer = StringIO.new

    surface.write_to_png(buffer)

    buffer.pos = 0
    return buffer.read
  end

  def read
    # Initialize Cairo
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, 300, 200)
    context = Cairo::Context.new(surface)

    # Write Backgrownd
    context.set_source_rgb(0.9, 0.9, 0.9)
    context.rectangle(0, 0, 300, 200)
    context.fill

    # Write Modules
    @modules.each do |mod|
      context.save do
        context.translate(40, 10)

        ModuleRenderer
          .new(
            mod[:name],
            mod[:inputs],
            mod[:outputs])
          .render(context)

        context.paint(1)
      end
    end

    # Write image to StringIO
    buffer = StringIO.new

    surface.write_to_png(buffer)

    buffer.pos = 0
    return buffer.read
  end

  class PlaceRouteMap
    def initialize
      @map = Array.new(12){ Array.new(15, nil) }
      @pos_x = 0
      @pos_y = 0
    end

    def add_module(mod)
      case mod.type
      when :source then
        @map[@pos_y][@pos_x] = Pin.new(:input)
        @map[@pos_y][@pos_x + 1] = Pin.new(:output)
        @pos_x += 2
      when :zip then
        for i in 0..mod.info[:observables].size
          @map[@pos_y + i][@pos_x] = Pin.new(:input)
        end
        @map[@pos_y][@pos_x + 1] = Pin.new(:output)
        @pos_x += 2
      when :reduce then
        # IN : {din, v_din}
        # OUT: {dout, v_dout}
        @map[@pos_y][@pos_x] = Pin.new(:input)
        @map[@pos_y][@pos_x + 1] = Pin.new(:output)
        @pos_x += 2
      end
    end

    def show
      @map.each do |col|
        col.each do |cell|
          case cell
          when Pin then
            if cell.io == :input
              print ">"
            else
              print "<"
            end
          when Wire then
            print "+"
          else
            print "."
          end
        end
        print "\n"
      end
    end

    class Pin
      def initialize(io)
        @io = io
      end

      attr_accessor :io
    end

    class Wire
    end
  end
end

end
