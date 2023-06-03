# ruby_hangman

## Description:

This is an object oriented based game project completed in ruby as part of [The Odin Project](https://www.theodinproject.com/). At the time of writing, link for this particular project is [Project: Hangman](https://www.theodinproject.com/lessons/ruby-hangman).

### How It Works:
This is basically a game in which a human player plays against the computer. There is a dictionary file in root project directory with a massive list of words. Computer picks a random word from it. Player has to guess it. Player chances are equal to number of characters of word picked by computer. Player has the option to save a game state but only once per game. Player can also load a game state. There are also options to quit game or delete all saved files to free up space. Previous correct & incorrect guesses within current game are also shown. On each incorrect guess, a chance is subtracted. Player loses if chance become 0. Player wins if he is able to guess the word without chances being becoming 0. No chances are subtracted on entering any correct or wrong guess again.

### Structural Overview:
On the note of structure, this project comprises of three class files. `display.rb` contains class `Display` which is basically used to output data to the console terminal. `game.rb` contains `Game` class which is main class of project & is used to communicate to the other classes via objects. No other class can communicate to this class directly. `Game` class also comprises of most of its methods as private methods. `human_player.rb` file contains class named as `HumanPlayer` used to take almost all sort of inputs from player & validate them. Last but not least, `utility_mod.rb` is a module file. It just contains a function shared between `Game` class & `HumanPlayer` class. These files exist within lib directory in root of folder & there is also a `saves` folder in the root. Root also contains a `dictionary.txt` file.

## How To Run:
cd to project root directory via terminal or open terminal there pointing to root directory. In terminal, use:
```
ruby lib/game.rb
```
## Thoughts:
This project was first project I made utilizing the capabilities of file handling & serialization. Saving & loading game files is sure a neat skill to have. Afterwards I am confident to do any sort of basic tasks using files & manipulating them from now on. File handling & data saving, retrieving to & from them was a thing I was always interested in. I took quite a time to fine grain this project. I focused on it quite a bit even to the point of neglecting to eat for whole 24 hours last day minus sleep!!!. I am quite proud of it.

## Future Ideas / Intentions:
Not in any specific order or final but:
1. Change the UI to be colorful & vibrant.

Not having any other ideas as it was given so much time & focus already with attention to details.



