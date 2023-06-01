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
                :rem_turns, :wrong_move_arr, :dashes_arr, :move, :turn_result_arr

  # :loaded

  def initialize
    # self.display_obj = Display.new
    # self.player_obj = HumanPlayer.new
    # self.logic_obj = ComputerLogic.new
    # self.rem_turns = @rem_turns
  end

  def run_game
    create_objects
    display_obj.show_menu
    # choice = 2
    choice = player_obj.input_choice

    case choice
    when 1
      game_result = play_game(choice)
      end_game(game_result)
    when 2
      loaded = load_game
      # loaded object is in array as first and only element, so using loaded[0] to access object:
      game_result = loaded.play_game(choice = 2)
      end_game(game_result)
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
      self.rem_turns = secret_word.length
      self.wrong_move_arr = []
      self.dashes_arr = Array.new(secret_word.length.to_i, '_')
      display_obj.process_choice_output(choice, secret_word, dashes_arr)
    end
    self.turn_result_arr = [rem_turns, dashes_arr, wrong_move_arr]
    display_obj.display_turns(move, secret_word, turn_result_arr) if choice == 2
    game_end = false
    while rem_turns >= 0 && game_end == false
      self.turn_result_arr = play_round
      self.rem_turns = turn_result_arr[0]
      self.dashes_arr = turn_result_arr[1]
      # print "#{dashes_arr.sort} #{secret_word.split('').sort}"
      game_end = true if rem_turns.zero? || dashes_arr.sort == secret_word.split('').sort
    end
    [rem_turns, dashes_arr, secret_word] # this is game_result
  end

  def create_secret_word
    self.secret_word = ''
    if File.exist?('dictionary.txt')
      file = File.open('dictionary.txt', 'r') do |f|
        f = f.read.split("\n") # split is used to remove new line chracter from each element which
        # read is adding
        self.secret_word = f.select { |word| word.length > 5 && word.length < 12 }.sample
      end
    end
    secret_word
  end

  def play_round
    self.move = player_obj.input_turn_choice(wrong_move_arr, dashes_arr)
    # self.move = '9'
    # if dashes_arr[0] == 'a'
    #   move = 's'
    #   else
    #     move = 'a'
    # end
    # move = '9'
    save_or_quit if %(9 0).include? move

    self.turn_result_arr = process_turn
    display_obj.display_turns(move, secret_word, turn_result_arr)
    turn_result_arr
  end

  def save_or_quit
    case move
    when '9'
      Dir.mkdir('saves') unless Dir.exist? 'saves'
      # file = File.open('saves/yaml.yml', 'w') do |f|
      #   f.puts(YAML.dump(self))
      # File.open('saves/yaml.yml', 'w') { |file| file.write(to_yaml) }
      File.open('saves/yaml.yml', 'w') { |file| file.write(YAML.dump(self)) }
      puts 'Thanks for playing...'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
      # replay_or_quit('y')
      # end
      # file.close
    when '0'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_replay_choice)
      # replay_or_quit('y')
    end
  end

  def process_turn
    if secret_word.include?(move) && !dashes_arr.include?(move)
      secret_word.split('').each_with_index do |ele, idx|
        dashes_arr[idx] = move if ele == move
      end
    else
      self.rem_turns = rem_turns - 1
      wrong_move_arr.push move
    end
    [rem_turns, dashes_arr, wrong_move_arr]
  end

  def end_game(game_result)
    self.secret_word = game_result[2]
    winner = check_winner(game_result)
    display_obj.announce_winner(winner, secret_word)
    display_obj.show_replay_message
    replay_or_quit(player_obj.input_replay_choice)
    # replay_or_quit('y')
  end

  def load_game
    # load = YAML.unsafe_load_file('saves/yaml.yml')
    # if below line does not work, above can be used, though unsafe:
    YAML.safe_load_file('saves/yaml.yml', aliases: true, permitted_classes: [Matrix, OpenStruct, Symbol, Game, Display,
                                                                             Range, HumanPlayer, ComputerLogic])
  end

  def check_winner(game_result)
    # game_result is an array containing rem_turns, dashes_arr & secret_word:
    return 'human' if game_result[0].positive? && game_result[1].sort == game_result[2].split('').sort

    'computer'
  end

  def replay_or_quit(replay_choice)
    if replay_choice == 'y'
      # a multiplateform solution to clear terminal when opted for replaying game:
      system('clear') || system('cls')
      game_obj = Game.new
      game_obj.run_game # re-run game
    else
      exit # exit game
      # play = 'n'
    end
    # exit
  end
end

game_obj = Game.new
game_obj.run_game # re-run game
