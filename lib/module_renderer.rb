require 'pango'

module IMulvery
  class ModuleRenderer
    PIN_LEN = 10
    PIN_WID = 2
    
    attr_accessor :width, :height, :module_width, :module_height

    def initialize(name, inputs, outputs, pos)
      @name = name
      @inputs = inputs
      @outputs = outputs
      @pos = pos

      surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, 300, 200)
      context = Cairo::Context.new(surface)

      # caluculating body size
      @bus_num = inputs.length < outputs.length ? outputs.length : inputs.length

      @max_width_pin_name = 0
      inputs.each do |key, _|
        pl = context.create_pango_layout
        pl.text = key.to_s
        @max_width_pin_name \
            = @max_width_pin_name < pl.pixel_size[0] ? pl.pixel_size[0] : @max_width_pin_name
      end
      outputs.each do |key, _|
        pl = context.create_pango_layout
        pl.text = key.to_s
        @max_width_pin_name \
            = @max_width_pin_name < pl.pixel_size[0] ? pl.pixel_size[0] : @max_width_pin_name
      end

      ## calculating a width of the module name textbox
      pl = context.create_pango_layout
      pl.text = name
      @name_size = pl.pixel_size

      @module_width = @name_size[0] + (@max_width_pin_name * 2) + 20
      @module_height = (@bus_num + 1) * 25

      @width = @module_width + PIN_LEN * 2
      @height = @module_height
    end

    def render(context)
      @context = context

      @context.save do
        @context.translate(@pos[0], @pos[1])

        @context.push_group do
          # body
          @context.translate(PIN_LEN, 0)

          @context.set_source_rgb(0.6, 0.7, 1)
          @context.rounded_rectangle(0, 0, @module_width, @module_height, 8)
          @context.fill

          @context.save do
            @context.translate((@module_width - @name_size[0]) / 2, (@module_height - @name_size[1]) / 2)
            
            @context.set_source_rgb(0, 0, 0)
            pl = @context.create_pango_layout
            pl.text = @name
            @context.show_pango_layout(pl)
          end

          # input pins
          pin_span = @module_height / (@inputs.length + 1)
          @context.save do
            @context.set_source_rgb(0, 0, 0)

            @inputs.each do |key, bass_width|
              @context.translate(0, pin_span)
              @context.rectangle(0, 0, -PIN_LEN, PIN_WID)
              @context.fill

              @context.save do
                pl = @context.create_pango_layout
                pl.text = key.to_s
                size = pl.pixel_size
                @context.translate(4, -size[1] / 2)
                @context.show_pango_layout(pl)
              end
            end
          end

          pin_span = @module_height / (@outputs.length + 1)
          @context.save do
            @context.translate(module_width, 0)
            @context.set_source_rgb(0, 0, 0)

            @outputs.each do |key, bass_width|
              @context.translate(0, pin_span)
              @context.rectangle(0, 0, PIN_LEN, PIN_WID)
              @context.fill

              @context.save do
                pl = @context.create_pango_layout
                pl.text = key.to_s
                size = pl.pixel_size
                @context.translate(-size[0] - 4, -size[1] / 2)
                @context.show_pango_layout(pl)
              end
            end
          end
        end

        @context.paint(1)
      end

      return self
    end

  end
end
