# $gtk.reset

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

  GRID_WIDTH = 10
  GRID_HEIGHT = 20

  def initialize(args, grid_x = nil, grid_y = nil, box_size: 31)
    @args = args
    @grid = Array.new(GRID_HEIGHT, Array.new(GRID_WIDTH, 0))

    @box_size = box_size
    @grid_x = grid_x || (1280 - @box_size * GRID_WIDTH) / 2
    @grid_y = grid_y || (720 - @box_size * GRID_HEIGHT) / 2
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

  def box_in_grid(col, row, color)
    x = @grid_x + col * @box_size
    y = @grid_y + row * @box_size
    box(x, y, color)
  end

  def box(x, y, color, padding: 2)
    padded_size = @box_size - (padding * 2)
    out.solids << [x + padding, y + padding, padded_size, padded_size, *color]
  end

  def render
    background
    box_in_grid(0, 0, BLUE)
    box_in_grid(1, 0, GREEN)
    box_in_grid(2, 0, PINK)
    box_in_grid(3, 0, YELLOW)
    box_in_grid(4, 0, PEACH)
    box_in_grid(5, 0, CYAN)
    box_in_grid(6, 0, VIOLET)
    box_in_grid(7, 0, BLUE)
    box_in_grid(8, 0, BLUE)
    box_in_grid(9, 0, BLUE)

    box_in_grid(9, 19, BLUE)
    box_in_grid(0, 19, BLUE)
  end

  def tick
    render
  end
end

def tick(args)
  args.state.game ||= TetrisGame.new(args)
  args.state.game.tick
end
