# frozen_string_literal: true

$LOAD_PATH << '.'

# Modules
require 'set'
require 'pry-byebug'

# Class for when computer solves the game
class ComputerBoard
  attr_reader :turns, :guess, :perms

  def initialize(code)
    @code = code
    @turns = 0
    @perms = %w[Y P G R W B].repeated_permutation(4).to_a.to_set
  end

  def color_count(peg_list)
    guess_color_count = Hash.new(0)
    peg_list.each { |color| guess_color_count[color] += 1 }
    guess_color_count
  end

  # key pegs assuming solution of 'act' and guess of 'check'
  def key_pegs(act, check)
    full_correct = 0

    act.each_with_index { |val, idx| full_correct += (val == check[idx] ? 1 : 0) }
    check2, act2 = remove_equal_elements(check, act)
    guess_color_count = color_count(act2)
    partial_correct = array_similar_elements(check2, act2, guess_color_count)

    [full_correct, partial_correct]
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

  def viable?(check, act, num_red, num_white)
    new_red, new_white = key_pegs(act, check)

    return false if new_red != num_red || (4 - new_red) < num_white

    return false if new_white != num_white

    true
  end

  def take_turn
    @guess = @perms.to_a.sample
    return false if @guess == @code

    @turns += 1
    key_results = key_pegs(@code, @guess)
    @perms.each { |perm| @perms.delete(perm) unless viable?(perm, @guess, key_results[0], key_results[1]) }
    true
  end

  def display_turn
    puts "\nTurn # #{@turns}: Computer Guessed #{@guess}"
    puts "Actual Code is: #{@code}"
    puts 'Press any key to move to the next turn.'
    gets
  end

  def won?
    return true if @perms.length == 1 || @guess == @code

    false
  end

  def victory_message
    puts "The computer cracked your code in #{@turns+1}! Better luck next time!"
    winning_code = @perms.length == 1 ? @perms.to_a[0] : @guess
    puts "Computer Guess #{winning_code}"
    puts "Actual Code: #{@code}"
  end
end
