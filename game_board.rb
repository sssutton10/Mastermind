# frozen_string_literal: true

$LOAD_PATH << '.'

# Re do key logic, modify guess count in victory message

# Constants for module
COLORS = %w[Y P G R W B].freeze

# Class for decoding board
class PlayerBoard
  attr_reader :code, :current_guess, :guess_count

  def initialize(code = nil)
    @guess_count = 1
    @code = code || generate_code
    @current_guess = []
    @guess_key_storage = Hash.new([])
    @guess_storage = Hash.new([])
  end

  def generate_code
    4.times.map { COLORS.sample }
  end

  def validate_guess?(guess_str)
    !guess_str.match?(/[^YPGRWB ]/)
  end

  def correct_guess?(guess_str)
    guess_list = guess_str.upcase.gsub(' ', '').split('')
    guess_list == @code
  end

  def store_guess(guess_list)
    @current_guess = guess_list
    @guess_storage[@guess_count] = guess_list
  end

  def color_count(peg_list)
    guess_color_count = Hash.new(0)
    peg_list.each { |color| guess_color_count[color] += 1 }
    guess_color_count
  end

  def remove_equal_elements(list1, list2)
    ret1 = [] # remove reds
    ret2 = [] # remove reds
    list1.each_index do |idx|
      if list1[idx] != list2[idx]
        ret1 << list1[idx]
        ret2 << list2[idx]
      end
    end

    [ret1, ret2]
  end

  def array_similar_elements(list1, list2, guess_color_count)
    similar_elements = 0
    list1.each do |peg|
      if list2.include?(peg) && guess_color_count[peg].positive?
        guess_color_count[peg] -= 1
        similar_elements += 1
      end
    end

    similar_elements
  end

  def key_pegs(act, check)
    full_correct = 0

    act.each_with_index { |val, idx| full_correct += (val == check[idx] ? 1 : 0) }
    check2, act2 = remove_equal_elements(check, act)
    guess_color_count = color_count(act2)
    partial_correct = array_similar_elements(check2, act2, guess_color_count)
    incorrect = 4 - full_correct - partial_correct

    @guess_key_storage[@guess_count] = [full_correct, partial_correct, incorrect] # Store for later display
    @guess_count += 1
  end

  # rubocop: disable Metrics/AbcSize, Style/StringConcatenation, Metrics/MethodLength
  def display_prior_guesses
    if @guess_count.zero?
      puts "\n"
      return
    end
    puts "\n" + ' ' * 10 + "Slot 1 | Slot 2 | Slot 3 | Slot 4 | Hit/ Partial/ Miss\n"
    puts '-' * 50 + "\n"
    @guess_storage.each do |key, value|
      print "Guess #{key}:" + ' ' * (6 - key.to_s.length) + "#{value[0]}   |    "
      print "#{value[1]}   |    #{value[2]}   |    #{value[3]}   |    "
      print "#{@guess_key_storage[key][0]} / #{@guess_key_storage[key][1]} / #{@guess_key_storage[key][2]}\n"
      puts '-' * 50 + "\n"
    end
  end
  # rubocop: enable Metrics/AbcSize, Style/StringConcatenation, Metrics/MethodLength

  def instructions
    print "Type in your guess (4 capital letters separated by a space)\n"
    print "Color Choices: (Y)ellow, (P)urple, (G)reen, (R)ed, (W)hite, (B)lue\n"
    print "#{13 - @guess_count} guesses remaining\n"
  end

  def user_guess
    display_prior_guesses
    instructions
    new_guess = gets.chomp
    if validate_guess?(new_guess)
      guess_list = new_guess.upcase.gsub(' ', '').split('')
      store_guess(guess_list)
      new_guess
    end
  end

  def game_win
    puts "Congrats, you solved the code in #{@guess_count} guesses!"
    puts "The code was #{@code.join(' ')}"
  end

  def game_loss
    puts "You lost! The code was #{@code.join(' ')}. Better luck next time!"
  end
end
