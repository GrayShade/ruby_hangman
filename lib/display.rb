# frozen_string_literal: false

class Display
  attr_accessor :dashes

  def initialize; end

  def show_menu
    puts
    puts 'Welcome to Hangman Game...'
    # puts 'Choose an option below: '
    puts "\nPress 1 to Start Game"
    puts 'Press 2 to load Game'
    puts 'Press 0 to quit game'
  end

  def process_choice_output(choice, secret_word, dashes_arr)
    # p input == '1'
    case choice
    when 1
      puts
      puts 'Game Started...'
      puts 'Computer player choosing a secret word...'
      print 'Secret Word: '
      self.dashes = 1..secret_word.length.times { print '_ ' }
      puts "(#{secret_word})"
      puts
      # show_starting_display(secret_word.length)
    when 2
      # whatshere?
    when 0
      show_quit_display
    end
  end

  # def show_starting_display(sec_word_length)

  # end

  def display_turns(turn, secret_word, turn_result)
    print "\nSecret Word: "
    turn_result[1].each { |dash| print "#{dash} " }
    puts "\nChances Left: #{turn_result[0]} "
    puts "Wrong finds: #{turn_result[2].join('')}"
  end

  def announce_winner(winner)
    if winner == 'human'
      puts "\nHuman player wins"
    else
      puts "\nComputer player wins"
      puts "Secret word was: #{secret_word}"
    end
    puts
  end

  def show_replay_message
    puts "\nGame over. Replay?"
    puts "Press Y to play again or N to quit:\n"
  end
end
