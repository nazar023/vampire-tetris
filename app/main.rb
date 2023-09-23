$gtk.reset

class TetrisGame
  BACKGROUND = [34, 33, 44].freeze
  FRAME = [245, 245, 239, 30].freeze

  BLUE = [40, 194, 255].freeze
  GREEN = [138, 255, 128].freeze
  PINK = [255, 128, 191].freeze
  YELLOW = [255, 255, 128].freeze
  PEACH = [255, 149, 128].freeze
  CYAN = [128, 255, 234].freeze
  VIOLET = [149, 128, 255].freeze

  COLORS_INDEX = [
    BACKGROUND,
    BLUE,
    CYAN,
    GREEN,
    YELLOW,
    PEACH,
    PINK,
    VIOLET
  ].freeze

  J_BLOCK = [
    [1, 0, 0].freeze,
    [1, 1, 1].freeze
  ].reverse!.freeze
  I_BLOCK = [
    [2, 2, 2, 2].freeze
  ].freeze
  S_BLOCK = [
    [0, 3, 3].freeze,
    [3, 3, 0].freeze
  ].reverse!.freeze
  O_BLOCK = [
    [4, 4].freeze,
    [4, 4].freeze
  ].freeze
  L_BLOCK = [
    [0, 0, 5].freeze,
    [5, 5, 5].freeze
  ].reverse!.freeze
  Z_BLOCK = [
    [6, 6, 0].freeze,
    [0, 6, 6].freeze
  ].reverse!.freeze
  T_BLOCK = [
    [0, 7, 0].freeze,
    [7, 7, 7].freeze
  ].reverse!.freeze

  SHAPES = [
    J_BLOCK, I_BLOCK, S_BLOCK, O_BLOCK, L_BLOCK, Z_BLOCK, T_BLOCK
  ].freeze

  GRID_WIDTH = 10
  GRID_HEIGHT = 20

  class Shape
    def initialize(shape_array, col = nil, row = nil)
      @shape_array = shape_array
      @col = col || ((GRID_WIDTH / 2) - (width / 2)).floor
      @row = row || GRID_HEIGHT
    end

    attr_reader :row, :col

    def width
      @shape_array[0].length
    end

    def height
      @shape_array.length
    end

    def descend
      @row -= 1
    end

    def each_box(col: col, row: row)
      @shape_array.each_with_index do |shape_row, row_index|
        shape_row.each_with_index do |color_index, col_index|
          next if color_index == 0

          yield(col + col_index, row + row_index, color_index)
        end
      end
    end
  end

  # TetrisGame
  def initialize(args, grid_x: nil, grid_y: nil, box_size: 31)
    @args = args
    @grid = Array.new(GRID_HEIGHT, Array.new(GRID_WIDTH, 0))

    @box_size = box_size
    @grid_x = grid_x || (1280 - @box_size * GRID_WIDTH) / 2
    @grid_y = grid_y || (720 - @box_size * (GRID_HEIGHT + 1)) / 2

    @frames_per_move = 60
    @current_frame = 0

    spawn_shape
  end

  def out
    @args.outputs
  end

  def background
    # out.solids << [0, 0, 1280, 720, *BACKGROUND]
    out.background_color = BACKGROUND

    for x in -1..GRID_WIDTH do
      box_in_grid(x, -1, FRAME)
      box_in_grid(x, GRID_HEIGHT, FRAME)
    end

    for y in 0...GRID_HEIGHT do
      box_in_grid(-1, y, FRAME)
      box_in_grid(GRID_WIDTH, y, FRAME)
    end
  end

  def render_shape(shape)
    shape.each_box do |col, row, color_index|
      box_in_grid(col, row, COLORS_INDEX[color_index])
    end
  end

  def box_in_grid(col, row, color)
    x = @grid_x + col * @box_size
    y = @grid_y + row * @box_size
    box(x, y, color)
  end

  def box(x, y, color, padding: 2)
    padded_size = @box_size - (padding * 2)
    out.solids << [x + padding, y + padding, padded_size, padded_size, *color]
  end

  def spawn_shape
    @current_shape = Shape.new(SHAPES.sample)
  end

  def render
    background

    render_shape(@current_shape)
    SHAPES.each_with_index { |s, row| render_shape(Shape.new(s, 0, row * 3)) }
  end

  def iterate
    @current_frame += 1
    if @current_frame >= @frames_per_move
      @current_frame = 0
      # @current_shape.descend
      spawn_shape
    end
  end

  def tick
    iterate
    render
  end
end

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end
