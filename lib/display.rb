# frozen_string_literal: false

# Class for showing terminal output
class Display
  attr_accessor :dashes

  def initialize; end

  def show_menu
    print "\nWelcome to Hangman Game...\n\nEnter 1 to Start Game"
    print "\nEnter 2 to load Game\nEnter 6 to delete saved files\nEnter 0 to quit game"
  end

  def display_startng_choice_output(choice, secrt_word, rem_moves, fname = '')
    case choice
    when 1
      print "\n\nGame Started...\nEnter 9 to save game or 0 to quit..."
      print "\nComputer player choosing a secret word...\n\nSecret Word  :\t "
      self.dashes = 1..secrt_word.length.times { print '_ ' }
      print "\nChances Left :\t #{rem_moves}\n"
    when 2
      print "\n\nGame '#{fname}' loaded...\nEnter 9 to save game or 0 to quit..."
    when 6
      puts "\nThis will delete all saved games...\nAre you sure?\t(Press y or n)"
    when 0
      show_quit_display
    end
  end

  def display_move_output(move_result_arr)
    print "\nSecret Word  :\t "
    move_result_arr[1].each { |dash| print "#{dash} " }
    puts "\nChances Left :\t #{move_result_arr[0]} "
    puts "Wrong finds  :\t #{move_result_arr[2].join('')}"
  end

  def announce_winner(winner, secrt_word)
    if winner == 'human'
      puts "\nYou Win!"
    else
      puts "\nComputer Wins!\nSecret word was: #{secrt_word}"
    end
    # puts
  end

  def show_replay_message
    print "\n\nGame over. Replay?\nEnter Y to play again or N to quit:\n"
  end
end
