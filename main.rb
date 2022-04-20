# frozen_string_literal: true

$LOAD_PATH << '.'

require_relative 'game_board'
require_relative 'computer_solve'
require 'pry-byebug'

# Error to raise when invalid code is given from user
class InvalidCodeError < StandardError
  def initialize(msg = 'Invalid code given.')
    super
  end
end

# Figure out if player is creating code or solving it
puts 'Enter 1 to be the code maker, anything else to be code breaker:'
if gets.chomp == '1'
  puts "\nPlease enter your code as 4 capital letters separated by a space. "
  print "Choose from: (Y)ellow, (P)urple, (G)reen, (R)ed, (W)hite, (B)lue\n"

  user_code = gets.chomp.upcase.gsub(/\s+/, ' ').strip

  raise InvalidCodeError if user_code.match?(/[^YPGRWB ]/)

  game = ComputerBoard.new(user_code.split(' '))
  # binding.pry
  loop do
    still_playing = game.take_turn
    game.display_turn if still_playing
    if game.won?
      game.victory_message
      break
    end
  end
else
  game = PlayerBoard.new(user_code || nil)

  loop do
    guess = game.user_guess
    next unless guess # repeat if not a valid guess

    if game.correct_guess?(guess)
      game.game_win
      break
    end

    game.key_pegs(game.code, game.current_guess)

    if game.guess_count < 1
      game.game_loss
      break
    end
  end
end
