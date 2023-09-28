module Tetris
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
end
