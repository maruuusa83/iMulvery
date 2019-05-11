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
    pin_conns = []
    max_width = 0
    pos_y = 10
    observables_old = @observables.dup
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
        when :map then
          if mod.info.key?(:observables)
            mod.info[:observables].each do |obs|
              @observables.push(obs)
            end
          end
          mod_info = {name: "map", inputs: {in: 1}, outputs: {out: 1}, pos: [pos_x, pos_y]}
        when :dummy then
          next
        end

        mr = ModuleRenderer
          .new(
            mod_info[:name],
            mod_info[:inputs],
            mod_info[:outputs],
            mod_info[:pos])

        modules.push(mr)
        mod.info[:renderer] = mr
       
        # layout
        pos_x += mr.width + 30
        if max_height < mr.height
          max_height = mr.height
        end

        if max_width < pos_x
          max_width = pos_x
        end

        if mod.type == :subscribe
          pos_x = 0
          pos_y += max_height + 20
        end
      end

      pos_y += max_height + 20
    end
    @observables = observables_old

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

    # Write wires
    pin_conns = []
    @observables.each do |observable|
      pin_conns += render_wire(observable)
    end
    pin_conns.each_slice(2) do |s, e|
      break if e == nil
      context.save do
        context.set_source_rgb(0, 0, 0)
        context.move_to(s[0], s[1])
        context.line_to(e[0], e[1])
        context.stroke
      end
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

  def render_wire(obs)
    pin_conns = []
    obs.data_path.each do |mod|
      # in
      mr = mod.info[:renderer]

      if (mr.inputs.length != 0)
        pin_span = mr.height / (mr.inputs.length + 1)
        pin_conns.push([mr.pos[0], mr.pos[1] + pin_span + 1])

        if (mod.type == :zip)
          mod.info[:observables].each_with_index do |obs, i|
            pin_conns += render_wire(obs)
            pin_conns.push([mr.pos[0], mr.pos[1] + pin_span * (i + 2) + 1])
          end
        end
      end

      # out
      if (mr.outputs.length != 0)
        pin_span = mr.height / (mr.outputs.length + 1)
        pin_conns.push([mr.pos[0] + mr.width, mr.pos[1] + pin_span + 1])
      end
    end

    pin_conns
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
