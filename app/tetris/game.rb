module Tetris
  class Game
    def initialize(args, grid_x: nil, grid_y: nil, box_size: 31, start_frames_per_move: 42)
      @args = args
      @grid = Grid.new

      @box_size = box_size
      @grid_x = grid_x || (1280 - @box_size * @grid.width) / 2
      @grid_y = grid_y || (720 - @box_size * (@grid.height + 1)) / 2

      @frames_per_move = start_frames_per_move
      @current_frame = 0

      @kb = @args.inputs.keyboard
      @held_key_throttle_by = 0
      @should_plant = false

      spawn_shape
    end

    def out
      @args.outputs
    end

    def background
      # out.solids << [0, 0, 1280, 720, *BACKGROUND]
      out.background_color = BACKGROUND

      for x in -1..@grid.width do
        box_in_grid(x, -1, FRAME)
        box_in_grid(x, @grid.height, FRAME)
      end

      for y in 0...@grid.height do
        box_in_grid(-1, y, FRAME)
        box_in_grid(@grid.width, y, FRAME)
      end
    end

    def render_boxes(box_collection, **opts)
      box_collection.each_box do |col, row, color_index|
        box_in_grid(col, row, COLORS_INDEX[color_index], **opts)
      end
    end

    def box_in_grid(col, row, color, solid: true)
      x = @grid_x + col * @box_size
      y = @grid_y + row * @box_size
      solid ? box(x, y, color) : box_border(x, y, color)
    end

    def box(x, y, color, padding: 2)
      padded_size = @box_size - (padding * 2)
      out.solids << [x + padding, y + padding, padded_size, padded_size, *color]
    end

    def box_border(x, y, color, padding: 2)
      padded_size = @box_size - (padding * 2)
      out.borders << [x + padding, y + padding, padded_size, padded_size, *color]
      out.borders << [x + padding + 1, y + padding + 1, padded_size - 2, padded_size - 2, *color]
    end

    def spawn_shape
      @current_shape = Shape.sample(grid: @grid)
    end

    def throttle_held_key(by = 7)
      @held_key_throttle_by = by
    end

    def held_key_check
      @held_key_throttle_by -= 1

      @held_key_throttle_by <= 0
    end

    def handle_input
      if @kb.key_down.up
        @current_shape.rotate && postpone_game_move
      end
      if @kb.key_down.left || (@kb.key_held.left && held_key_check)
        @current_shape.move_left && postpone_game_move
        throttle_held_key
      end
      if @kb.key_down.right || (@kb.key_held.right && held_key_check)
        @current_shape.move_right && postpone_game_move
        throttle_held_key
      end
      if @kb.key_down.down || (@kb.key_held.down && held_key_check)
        @current_shape.move_down && postpone_game_move
        throttle_held_key(2)
      end
    end

    def postpone_game_move
      @current_frame >= 0 && @current_frame -= 10
    end

    def iterate
      handle_input
      game_move
    end

    def game_move
      @current_frame += 1
      return if @current_frame < @frames_per_move

      @current_frame = 0

      if @current_shape.can_descend?
        @current_shape.descend
        return
      end

      unless @should_plant
        @should_plant = true
        @current_frame = @frames_per_move - 6
        return
      end

      if @grid.cannot_plant_shape?(@current_shape)
        # TODO: game over!
        $gtk.reset
        return
      end

      @grid.plant_shape(@current_shape)
      @should_plant = false
      spawn_shape
    end

    def render
      background

      render_boxes(@grid)
      render_boxes(@current_shape)
      render_boxes(@current_shape.projection, solid: false)
    end

    def tick
      iterate
      render
    end
  end
end
