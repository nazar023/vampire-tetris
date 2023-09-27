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

  class Grid
    GRID_WIDTH = 10
    GRID_HEIGHT = 20

    BLANK_ROW = Array.new(GRID_WIDTH, 0).freeze

    def initialize
      @grid_array = Array.new(GRID_HEIGHT) { Array.new(GRID_WIDTH, 0) }
    end

    def width
      GRID_WIDTH
    end

    def height
      GRID_HEIGHT
    end

    def row(index)
      @grid_array[index] || BLANK_ROW
    end

    def cell(col, row)
      self.row(row)[col]
    end

    def cell_occupied?(col, row)
      cell(col, row) != 0
    end

    def cannot_plant_shape?(shape)
      shape.top_row >= height || shape.bottom_row < 0
    end

    def plant_shape(shape)
      shape.each_box do |col, row, color_index|
        real_row(row)[col] = color_index
      end
    end

    def real_row(index)
      @grid_array[index]
    end

    def each_box
      @grid_array.each_with_index do |grid_row, row_index|
        grid_row.each_with_index do |color_index, col_index|
          next if color_index == 0

          yield(col_index, row_index, color_index)
        end
      end
    end
  end

  class Shape
    class Projection
      def initialize(shape)
        @shape = shape
      end

      def each_box(&block)
        @shape.each_box(row: @shape.projection_bottom_row, &block)
      end
    end

    def initialize(shape_array, col = nil, row = nil, grid:)
      @shape_array = shape_array
      @grid = grid
      @col = col || ((grid.width / 2) - (width / 2)).floor
      @row = row || grid.height
    end

    attr_reader :row, :col
    alias_method :bottom_row, :row

    def top_row
      bottom_row + height - 1
    end

    def width
      @shape_array[0].length
    end

    def height
      @shape_array.length
    end

    def can_descend?
      can_be_placed_on?(row: row - 1)
    end

    def can_be_placed_on?(col: col, row: row)
      return false if col < 0 || row < 0

      each_box(col: col, row: row) do |box_col, box_row, _|
        return false if @grid.cell_occupied?(box_col, box_row)
      end

      true
    end

    def cannot_descend?
      !can_descend?
    end

    def descend
      @row -= 1
    end

    def find_projection_bottom_row
      return row if row <= 0

      projection_row = row - 1
      while can_be_placed_on?(row: projection_row) do
        projection_row -= 1
      end

      projection_row + 1
    end

    def projection_bottom_row
      @projection_bottom_row ||= find_projection_bottom_row
    end

    def projection
      @projection ||= Projection.new(self)
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
    @grid = Grid.new

    @box_size = box_size
    @grid_x = grid_x || (1280 - @box_size * @grid.width) / 2
    @grid_y = grid_y || (720 - @box_size * (@grid.height + 1)) / 2

    @frames_per_move = 6
    @current_frame = 0

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
    @current_shape = Shape.new(SHAPES.sample, grid: @grid)
  end

  def render
    background

    render_boxes(@grid)
    render_boxes(@current_shape)
    render_boxes(@current_shape.projection, solid: false)
  end

  def iterate
    @current_frame += 1
    return if @current_frame < @frames_per_move

    @current_frame = 0

    if @current_shape.can_descend?
      @current_shape.descend
      return
    end

    if @grid.cannot_plant_shape?(@current_shape)
      # TODO: game over!
      $gtk.reset
      return
    end

    @grid.plant_shape(@current_shape)
    spawn_shape
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
