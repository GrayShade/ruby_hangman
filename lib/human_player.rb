# frozen_string_literal: false

# HumanPlayer class is for taking & cleansing inputs from human player
class HumanPlayer
  def initialize; end

  def input_starting_choice
    puts "\nEnter your choice: "
    choice = gets.chomp.strip.downcase
    # Using %() makes a string not escapt quotes. So it will return true if input is a string & you check
    # like %('9') == "'".
    until %w[1 2 0].include?(choice) && choice != '' # choice != '' prevents error on pressing enter key
      puts "\nWrong choice!!! Try Again:\t( Choose 1, 2 or 0 )"
      choice = gets.chomp.strip.downcase
    end
    choice.to_i
  end

  def input_turn_choice(wrong_move_arr, dashes_arr)
    puts "Make a move  :\t (9 => save game, 0 => quit)"
    check = false
    while check == false
      move = gets.chomp.strip.downcase
      # move = 's'
      return move if %w[9 0].include?(move) && !move.empty?

      if !('a'..'z').to_a.include?(move) || move.length != 1 || ('0'..'9').to_a.include?(move.to_i)
        puts 'Wrong move!!! Try Again:'
        next
      elsif dashes_arr.include? move
        puts "\n#{move} already found as correct. Choose other:"
        next
      elsif wrong_move_arr.include? move
        puts "\n#{move} already found as wrong. Choose other:"
        next
      elsif move == ''
        puts 'here'
        next
      end
      check = true
    end
    move
  end

  def input_replay_choice
    choice = gets.chomp.strip.downcase
    until %w[y n].include?(choice.downcase) && choice != '' # choice != '' prevents error on pressing enter key
      puts 'Choose Y to replay or N to quit:'
      choice = gets.chomp.strip.downcase
    end
    choice
  end

  def input_file_name
    puts "\nEnter save file name:\t (without extension) "
    choice = gets.chomp.strip.downcase
    # choice != '' prevents error on pressing enter key
    until choice.split('').all? { |ele| [*'a'..'z', *'0'..'9'].include?(ele) } && choice != '' && choice.length <= 15
      print "\nOnly alphabets, numbers & no extension!!! \t(max 15 chracters)\n"
      puts "Enter save file name:\t"
      choice = gets.chomp.strip.downcase
    end
    choice
  end
end
