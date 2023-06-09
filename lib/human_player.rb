# frozen_string_literal: false

require_relative 'utility_mod'

# HumanPlayer class is for taking & cleansing inputs from human player
class HumanPlayer
  include UtilityMod

  def initialize; end

  def input_starting_choice
    print "\n\nEnter your choice: "
    choice = gets.chomp.strip.downcase
    # Using %() makes a string not escapt quotes. So it will return true if input is a string & you check
    # like %('9') == "'".
    until %w[1 2 6 0].include?(choice) && choice != '' # choice != '' prevents error on pressing enter key
      puts "\nWrong choice!!! Try Again:\t( Choose 1, 2, 6 or 0 )"
      choice = gets.chomp.strip.downcase
    end
    choice.to_i
  end

  def input_move(wrong_move_arr, dashes_arr)
    print "\nMake a move  :\t "
    check = false
    while check == false
      move = gets.chomp.strip.downcase
      return move if %w[9 0].include?(move) && !move.empty?

      if !('a'..'z').to_a.include?(move) || move.length != 1 || ('0'..'9').to_a.include?(move.to_i)
        print "\n\nOnly alphabets allowed!!!\nMake a move:\t "
        next
      elsif dashes_arr.include? move
        print "\n\nAlready found '#{move}' as correct.\nMake a move:\t "
        next
      elsif wrong_move_arr.include? move
        print "\n\nAlready found '#{move}' as wrong.\nMake a move:\t "
        next
      end
      check = true
    end
    move
  end

  def input_yes_no
    choice = gets.chomp.strip.downcase
    until %w[y n].include?(choice.downcase) && choice != '' # choice != '' prevents error on pressing enter key
      puts 'Choose Y or N:'
      choice = gets.chomp.strip.downcase
    end
    choice
  end

  def input_file_name(input_type)
    ovrwrite_prmison = 'n'
    while ovrwrite_prmison == 'n'
      puts "\nEnter file name to #{input_type}:\t (without extension) "
      choice = gets.chomp.strip.downcase
      # choice != '' prevents error on pressing enter key
      until choice.split('').all? { |ele| [*'a'..'z', *'0'..'9'].include?(ele) } && choice != '' && choice.length <= 15
        print "\nOnly alphabets, numbers & no extension!!! \t(max 15 chracters)\n"
        puts "Enter file name to #{input_type}:\t"
        choice = gets.chomp.strip.downcase
      end

      # to number files & remove save directory, trailing extension from file list:
      files_list = obtain_files_list.map { |file| File.basename(file, '.*') }

      if input_type == 'load' && !(files_list.include? choice)
        print "\nNo such file exists!!!"
        next
      end

      # if its a load operation, return at at this point:
      return choice unless input_type == 'save'

      # to number files & remove save directory, trailing extension from file list:
      files_list = obtain_files_list.map { |file| File.basename(file, '.*') }

      return choice unless files_list.include?(choice)

      puts 'Overwrite existing file? (Press y or n):'

      ovrwrite_prmison = input_yes_no
    end
    choice
  end
end
