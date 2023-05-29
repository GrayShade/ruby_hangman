# frozen_string_literal: false

require_relative 'display'
require_relative 'human_player'
require_relative 'computer_logic'

# This is main class of game & is abstracted from other classes
class Game
  attr_accessor :display_obj, :player_obj, :logic_obj

  # :guessed_arr, :turns_remaining

  def initialize; end

  def run_game
    create_objects
    display_obj.show_menu
    choice = player_obj.input_choice
    # choice = 1
    game_result = play_game(choice) if choice == 1
    end_game(game_result)
  end

  def create_objects
    self.display_obj = Display.new
    self.player_obj = HumanPlayer.new
    self.logic_obj = ComputerLogic.new
  end

  def play_game(choice)
    # secret_word = create_secret_word if choice == 1
    secret_word = 'afternoon'
    rem_turns = secret_word.length
    wrong_move_arr = []
    game_end = false
    dashes_arr = Array.new(secret_word.length.to_i, '_')
    display_obj.process_choice_output(choice, secret_word, dashes_arr)

    while rem_turns >= 0 && game_end == false
      turn_result = play_round(secret_word, rem_turns, wrong_move_arr, dashes_arr)
      rem_turns = turn_result[0]
      dashes_arr = turn_result[1]
      # print "#{dashes_arr.sort} #{secret_word.split('').sort}"
      game_end = true if rem_turns.zero? || dashes_arr.sort == secret_word.split('').sort
    end
    [rem_turns, dashes_arr, secret_word] # this is game_result
  end

  def create_secret_word
    secret_word = ''
    if File.exist?('dictionary.txt')
      file = File.open('dictionary.txt', 'r') do |f|
        f = f.read.split("\n") # split is used to remove new line chracter from each element which
        # read is adding
        secret_word = f.select { |word| word.length >= 5 }.sample
        # puts secret_word
      end
    end
    secret_word
  end

  def play_round(secret_word, rem_turns, wrong_move_arr, dashes_arr)
    # puts "Make a turn: (s to save or 0 to quit)"
    move = player_obj.input_turn_choice(wrong_move_arr, dashes_arr)

    # move = 'o'
    turn_result = process_turn(move, secret_word, rem_turns, wrong_move_arr, dashes_arr)
    display_obj.display_turns(move, secret_word, turn_result)
    turn_result
  end

  def process_turn(move, secret_word, rem_turns, wrong_move_arr, dashes_arr)
    if secret_word.include?(move) && !dashes_arr.include?(move)
      secret_word.split('').each_with_index do |ele, idx|
        dashes_arr[idx] = move if ele == move
      end
    else
      rem_turns -= 1
      wrong_move_arr.push move
    end
    [rem_turns, dashes_arr, wrong_move_arr]
  end

  def end_game(game_result)
    winner = check_winner(game_result)
    display_obj.announce_winner(winner)
    display_obj.show_replay_message
    replay_input = player_obj.input_replay_choice
  end

  def check_winner(game_result)
    winner = ''
    # game_result is an array containing rem_turns, dashes_arr, wrong_move_arr
    rem_turns = game_result[0]
    dashes_arr = game_result[1]
    secret_word = game_result[2]
    if rem_turns.positive? && dashes_arr.sort == secret_word.split('').sort # positive? returns true if greater than 0
      winner = 'human'

    else
      winner = 'computer'
    end
    winner
  end
end

game_obj = Game.new
game_obj.run_game

