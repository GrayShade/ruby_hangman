# frozen_string_literal: false

require 'yaml'
require 'matrix'
require 'ostruct'

require_relative 'display'
require_relative 'human_player'
require_relative 'computer_logic'

# This is main class of game & is abstracted from other classes
class Game
  attr_accessor :display_obj, :player_obj, :logic_obj, :secrt_word, :fname,
                :rem_moves, :wrong_move_arr, :dashes_arr, :move, :move_result_arr

  def run_game
    create_objects
    # to check which instance_variables belong to an object:
    # p self.instance_variables
    display_obj.show_menu
    choice = player_obj.input_choice

    case choice
    when 1
      game_result_arr = play_game(choice)
      end_game(game_result_arr)
    when 2
      # when game is loaded from save, only [:@display_obj, :@player_obj, :@logic_obj] are present as
      # rest are not initialized yet in current object. And attr_accessor does not initialize instance variables.
      #  It only creates getter and setter methods for the instance variables. The instance variables
      # themselves are still initialized to nil when the object is created. So they are not created yet. It
      #  means you have to initialize them to be able to use them.
      loaded_obj = load_game
      # Remember that below we are doing loaded_obj.play_game(). That means we are now running play_game()
      # function of previous object but it just means that play_game now has all data of previous object
      #  but outside of play_game, when it ends, we have access to our new object only. Like secrt_word.
      # If we have a object A. We load object B.  On replaying game, if we use Game.new, then its a new
      # object C which can now load object B but object A data wasted.

      # Only result of loaded_obj.play_game(2) contains previous object & outside of it, previous
      #  object does not exist. Result will be saved as game_result_arr.
      end_game(loaded_obj.play_game(2))
    when 0
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
    end
  end

  def create_objects
    self.display_obj = Display.new
    self.player_obj = HumanPlayer.new
    self.logic_obj = ComputerLogic.new
  end

  def play_game(choice) 
    # if game is loaded from save, then all self here are refering to loaded object & not
    # current object
    # below choice check is for preventing loaded games to prevent below instance variables from
    # being re written:
    if choice == 1
      self.secrt_word = create_secrt_word
      self.rem_moves = secrt_word.length
      self.wrong_move_arr = []
      self.dashes_arr = Array.new(secrt_word.length.to_i, '_')
    end
    display_obj.process_choice_output(choice, secrt_word, fname)

    self.move_result_arr = [rem_moves, dashes_arr, wrong_move_arr]
    display_obj.display_turns(move_result_arr) if choice == 2
    game_end = false
    while rem_moves >= 0 && game_end == false
      self.move_result_arr = play_round
      self.rem_moves = move_result_arr[0]
      self.dashes_arr = move_result_arr[1]
      game_end = true if rem_moves.zero? || dashes_arr.sort == secrt_word.split('').sort
    end
    [rem_moves, dashes_arr, secrt_word] # this is game_result_arr
  end

  def create_secrt_word
    self.secrt_word = ''
    if File.exist?('dictionary.txt')
      File.open('dictionary.txt', 'r') do |f|
        # split below is used to remove new line chracter from each element which read is adding.
        self.secrt_word = f.read.split("\n").select { |word| word.length > 5 && word.length < 12 }.sample
      end
    end
    secrt_word
  end

  def play_round
    self.move = player_obj.input_turn_choice(wrong_move_arr, dashes_arr)
    save_or_quit if %(9 0).include? move
    self.move_result_arr = process_turn
    display_obj.display_turns(move_result_arr)
    move_result_arr
  end

  def save_or_quit
    case move
    when '9'
      Dir.mkdir('saves') unless Dir.exist? 'saves'
      self.fname = 'save.yml' # Only one save allowed for now per game. Also prevents cheating.
      File.open("saves/#{fname}", 'w') { |file| file.write(YAML.dump(self)) }
      puts "\nGame saved as #{fname}"
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
    when '0'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
    end
  end

  def process_turn
    if secrt_word.include?(move) && !dashes_arr.include?(move)
      secrt_word.split('').each_with_index do |ele, idx|
        dashes_arr[idx] = move if ele == move
      end
    else
      self.rem_moves = rem_moves - 1
      wrong_move_arr << move
    end
    [rem_moves, dashes_arr, wrong_move_arr]
  end

  def end_game(game_result_arr)
    # In case of end_game function when loaded a save, we can only use game_result_arr for rem_moves,
    # dashes_arr, secrt_word as the array elements in it are not initialized yet. For sake of change...
    winner = check_winner(game_result_arr)
    display_obj.announce_winner(winner, game_result_arr[2])
    display_obj.show_replay_message
    replay_or_quit(player_obj.input_replay_choice)
  end

  def load_game
    # YAML.unsafe_load_file('saves/yaml.yml')
    # if below line does not work, above can be used, though unsafe:
    self.fname = 'save.yml'
    YAML.safe_load_file("saves/#{fname}", aliases: true, permitted_classes: [Matrix, OpenStruct, Symbol, Game, Display,
                                                                             HumanPlayer, ComputerLogic, Range])
  end

  def check_winner(game_result_arr)
    # game_result_arr is an array containing rem_moves, dashes_arr & secrt_word:
    return 'human' if game_result_arr[0].positive? && game_result_arr[1].sort == game_result_arr[2].split('').sort

    'computer'
  end

  def replay_or_quit(replay_choice)
    exit if replay_choice != 'y' # exit game
    # a multiplateform solution to clear terminal when opted for replaying game:
    system('clear') || system('cls')
    # not creating the new object below because previous won't be deleted as code is stil
    # running. This will retain unnessary objects as many times as game is loaded during same
    # program life cycle
    run_game # re-run game
  end
end

game_obj = Game.new
game_obj.run_game
