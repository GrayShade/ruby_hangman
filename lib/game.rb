# frozen_string_literal: false

# we require below three classes for safe_load_file
require 'yaml'
require 'matrix'
require 'ostruct'
require 'fileutils' # for using FileUtils.rm_rf

require_relative 'display'
require_relative 'human_player'

require_relative 'utility_mod'

# This is main class of game & is abstracted from other classes
class Game
  include UtilityMod

  attr_accessor :display_obj, :player_obj, :logic_obj, :secrt_word, :fname,
                :rem_moves, :wrong_move_arr, :dashes_arr, :move, :move_result_arr

  def run_game
    create_objects
    # to check which instance_variables belong to an object:
    # p self.instance_variables
    display_obj.show_menu
    choice = player_obj.input_starting_choice
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

    when 6
      display_obj.display_startng_choice_output(6, '', '', '')
      delete_request = player_obj.input_yes_no
      process_delete_request if delete_request == 'y'
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_yes_no)

    when 0
      display_obj.show_replay_message
      replay_or_quit(player_obj.input_yes_no)
    end
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
    # fname below is for load game:
    display_obj.display_startng_choice_output(choice, secrt_word, rem_moves, fname)

    self.move_result_arr = [rem_moves, dashes_arr, wrong_move_arr]
    display_obj.display_move_output(move_result_arr) if choice == 2
    game_end = false
    while rem_moves >= 0 && game_end == false
      self.move_result_arr = play_round
      self.rem_moves = move_result_arr[0]
      self.dashes_arr = move_result_arr[1]
      game_end = true if rem_moves.zero? || dashes_arr.sort == secrt_word.split('').sort
    end
    [rem_moves, dashes_arr, secrt_word] # this is game_result_arr
  end

  private

  # private block starting here
  begin
    def create_objects
      self.display_obj = Display.new
      self.player_obj = HumanPlayer.new
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
      self.move = player_obj.input_move(wrong_move_arr, dashes_arr)
      save_or_quit if %(9 0).include? move
      self.move_result_arr = process_turn
      display_obj.display_move_output(move_result_arr)
      move_result_arr
    end

    def save_or_quit
      case move
      when '9'
        Dir.mkdir('saves') unless Dir.exist? 'saves'
        # files_list = obtain_files_list.map.with_index { |file, idx| "#{idx + 1}) #{File.basename(file, '.*')}" }
        # Only one save allowed for now per game. Also prevents cheating.
        self.fname = player_obj.input_file_name('save')
        File.open("saves/#{fname}.yml", 'w') { |file| file.write(YAML.dump(self)) }
        puts "\nGame saved as #{fname}.yml"
        display_obj.show_replay_message
        replay_or_quit(player_obj.input_yes_no)
      when '0'
        display_obj.show_replay_message
        replay_or_quit(player_obj.input_yes_no)
      end
    end

    def process_turn
      if secrt_word.include?(move) && !dashes_arr.include?(move)
        secrt_word.split('').each_with_index { |ele, idx| dashes_arr[idx] = move if ele == move }
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
      replay_or_quit(player_obj.input_yes_no)
    end

    def load_game
      print "\nSaved files list:\t(last modified order)\n\n"
      # to number files & remove save directory, trailing extension from obtained file list:
      files_list = obtain_files_list.map.with_index { |file, idx| "#{idx + 1}) #{File.basename(file, '.*')}" }
      if files_list.count.zero?
        print "No files to load...\n"
        display_obj.show_replay_message
        replay_or_quit(player_obj.input_yes_no)
      end
      puts files_list
      self.fname = player_obj.input_file_name('load')
      # YAML.unsafe_load_file('saves/yaml.yml')
      # if below line does not work, above can be used, though unsafe:
      YAML.safe_load_file("saves/#{fname}.yml", aliases: true, permitted_classes: [Matrix, OpenStruct, Symbol, Game, Display,
                                                                                   HumanPlayer, Range])
    end

    def check_winner(game_result_arr)
      # game_result_arr is an array containing rem_moves, dashes_arr & secrt_word:
      return 'human' if game_result_arr[0].positive? && game_result_arr[1].sort == game_result_arr[2].split('').sort

      'computer'
    end

    # input validation ensures replay choice is y or n
    def replay_or_quit(replay_choice)
      exit if replay_choice == 'n' # exit game
      # a multiplateform solution to clear terminal when opted for replaying game:
      system('clear') || system('cls')
      # not creating the new object below because previous won't be deleted as code is stil
      # running. This will retain unnessary objects as many times as game is loaded during same
      # program life cycle
      run_game # re-run game
    end

    def process_delete_request
      FileUtils.rm_rf(Dir.glob('saves/*.yml'))
      files_count = obtain_files_list.count
      if files_count == 0
        puts "\nAll files deleted"
      else
        puts "\nSome issue in deletion"
      end
    end
  end
end

game_obj = Game.new
game_obj.run_game
