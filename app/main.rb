# $gtk.reset

require_relative "tetris"

def tick(args)
  args.state.game ||= Tetris::Game.new(args)
  args.state.game.tick
end
