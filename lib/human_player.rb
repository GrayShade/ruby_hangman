# frozen_string_literal: false

# HumanPlayer class is for taking & cleansing inputs from human player
class HumanPlayer
  def initialize; end

  def input_choice
    puts "\nEnter your choice: "
    choice = gets.chomp.strip.downcase
    # i think using %() makes a string instead of %w that makes an array:
    until %(1 2 0).include?(choice) && choice != '' # choice != '' prevents error on pressing enter key
      puts 'Wrong choice!!! Try Again:'
      choice = gets.chomp.strip.downcase
    end
    choice.to_i
  end

  def input_turn_choice(wrong_move_arr, dashes_arr)
    puts 'Make a turn: (9 to save or 0 to quit)'
    check = false
    while check == false
      turn = gets.chomp.strip.downcase
      return turn if %('9' '0').include? turn

      if !('a'..'z').to_a.include?(turn) && turn.length != 1
        puts 'Wrong move!!! Try Again:'
        next
      elsif dashes_arr.include? turn
        puts "\n#{turn} already found as correct. Choose other:"
        next
      elsif wrong_move_arr.include? turn
        puts "\n#{turn} already found as wrong. Choose other:"
        next
      elsif turn == ''
        puts 'here'
        next
      end
      check = true
    end
    turn
  end

  def input_replay_choice
    choice = gets.chomp.strip.downcase
    until %(y n).include?(choice.downcase) && choice != '' # choice != '' prevents error on pressing enter key
      puts 'Press Y to play again or N to quit:'
      choice = gets.chomp.strip.downcase
    end
    choice
  end
end
