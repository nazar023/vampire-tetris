module Tetris
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
end

require_relative "tetris/grid"
require_relative "tetris/shape"
require_relative "tetris/game"

