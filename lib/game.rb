# frozen_string_literal: false

require 'yaml'
require 'matrix'
require 'ostruct'

require_relative 'display'
require_relative 'human_player'
require_relative 'computer_logic'

# This is main class of game & is abstracted from other classes
class Game
  attr_accessor :display_obj, :player_obj, :logic_obj, :secret_word,
                :rem_moves, :wrong_move_arr, :dashes_arr, :move, :move_result_arr

  # :loaded

  def initialize; end

  def run_game
    create_objects
    # to check which instance_variables belong to an object:
    # p self.instance_variables
    display_obj.show_menu
    # choice = 2
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
      loaded = load_game
      # Remember that below we are doing loaded.play_game(). That means we are now running play_game()
      # function of previous object but it just means that play_game now has all data of previous object
      #  but outside of play_game, when it ends, we have access to our new object only. Like secret_word.
      # If we have a object A. We load object B.  On replaying game, if we use Game.new, then its a new
      # object C which can now load object B but object A data wasted.

      # Only game_result_arr contains previous object & outside of it, it does not exist:
      game_result_arr = loaded.play_game(choice = 2)
      # Here again starts current(non loaded) object:
      end_game(game_result_arr)
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
    # below choice check is for preventing loaded games to have below instance variables from
    # being re written:
    if choice == 1
      self.secret_word = create_secret_word
      # self.secret_word = 'afternoon'
      self.rem_moves = secret_word.length
      self.wrong_move_arr = []
      self.dashes_arr = Array.new(secret_word.length.to_i, '_')
      display_obj.process_choice_output(choice, secret_word, dashes_arr)
    end
    self.move_result_arr = [rem_moves, dashes_arr, wrong_move_arr]
    display_obj.display_turns(move, secret_word, move_result_arr) if choice == 2
    game_end = false
    while rem_moves >= 0 && game_end == false
      self.move_result_arr = play_round
      self.rem_moves = move_result_arr[0]
      self.dashes_arr = move_result_arr[1]
      game_end = true if rem_moves.zero? || dashes_arr.sort == secret_word.split('').sort
    end
    [rem_moves, dashes_arr, secret_word] # this is game_result_arr
  end

  def create_secret_word
    self.secret_word = ''
    if File.exist?('dictionary.txt')
      file = File.open('dictionary.txt', 'r') do |f|
        f = f.read.split("\n") # split is used to remove new line chracter from each element which
        # read is adding.
        self.secret_word = f.select { |word| word.length > 5 && word.length < 12 }.sample
      end
    end
    secret_word
  end

  def play_round
    self.move = player_obj.input_turn_choice(wrong_move_arr, dashes_arr)
    save_or_quit if %(9 0).include? move
    self.move_result_arr = process_turn
    display_obj.display_turns(move, secret_word, move_result_arr)
    move_result_arr
  end

  def save_or_quit
    case move
    when '9'
      Dir.mkdir('saves') unless Dir.exist? 'saves'
      File.open('saves/yaml.yml', 'w') { |file| file.write(YAML.dump(self)) }
      puts 'Thanks for playing...'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
    when '0'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
    end
  end

  def process_turn
    if secret_word.include?(move) && !dashes_arr.include?(move)
      secret_word.split('').each_with_index do |ele, idx|
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
    # dashes_arr, secret_word as the array elements in it are not initialized yet. For sake of change...
    winner = check_winner(game_result_arr)
    display_obj.announce_winner(winner, game_result_arr[2])
    display_obj.show_replay_message
    replay_or_quit(player_obj.input_replay_choice)
  end

  def load_game
    # YAML.unsafe_load_file('saves/yaml.yml')
    # if below line does not work, above can be used, though unsafe:
    YAML.safe_load_file('saves/yaml.yml', aliases: true, permitted_classes: [Matrix, OpenStruct, Symbol, Game, Display,
                                                                             HumanPlayer, ComputerLogic, Range])
  end

  def check_winner(game_result_arr)
    # game_result_arr is an array containing rem_moves, dashes_arr & secret_word:
    return 'human' if game_result_arr[0].positive? && game_result_arr[1].sort == game_result_arr[2].split('').sort

    'computer'
  end

  def replay_or_quit(replay_choice)
    if replay_choice == 'y'
      # a multiplateform solution to clear terminal when opted for replaying game:
      system('clear') || system('cls')
      # This will create a new object:
      game_obj = Game.new
      game_obj.run_game # re-run game
    else
      exit # exit game
    end
    # exit
  end
end

game_obj = Game.new
game_obj.run_game
