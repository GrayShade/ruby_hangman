# frozen_string_literal: false

class Display
  attr_accessor :dashes

  def initialize; end

  def show_menu
    puts
    puts 'Welcome to Hangman Game...'
    puts "\nEnter 1 to Start Game"
    puts 'Enter 2 to load Game'
    puts 'Enter 6 to delete saved files'
    puts 'Enter 0 to quit game'
  end

  def display_startng_choice_output(choice, secrt_word, rem_moves, fname = '')
    case choice
    when 1
      puts
      puts 'Game Started...'
      puts 'Enter 9 to save game or 0 to quit...'
      puts 'Computer player choosing a secret word...'
      print "Secret Word  :\t "
      self.dashes = 1..secrt_word.length.times { print '_ ' }
      print "\nChances Left :\t #{rem_moves}"

      puts
    when 2
      puts
      puts "Game '#{fname}' loaded..."
      puts 'Enter 9 to save game or 0 to quit...'
    
    when 6
      puts
      puts 'This will delete all saved games...'
      puts "Are you sure?\t(Press y or n)"
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
      puts "\nComputer Wins!"
      puts "Secret word was: #{secrt_word}"
    end
    # puts
  end

  def show_replay_message
    puts "\nGame over. Replay?"
    puts "Enter Y to play again or N to quit:\n"
  end
end
