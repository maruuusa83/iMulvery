require_relative './mulvery'

require_relative './module_renderer'
require 'pango'

module IMulvery
  class BlockDiagram
    def self.from_observable(observable)
      return BlockDiagram.new
    end

    def initialize()
      @modules = []
    end

    def add_module(name, i_pins, o_pins)
      @modules.push({name: name, inputs: i_pins, outputs: o_pins})
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
  end

  class BlockConnection
    def initialize()
      @modules = []
      @adjacency_mat = [[]]
    end

    def add_module(mod)
      @modules.push(mod)
      
    end
  end
end
