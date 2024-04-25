# word-jam

## Overview
Word Jam is a tile-based word-finder game app for Android devices. 
Letter tiles are slid around the game board to form English language words. Each time a valid word is made, the 
corresponding letters will be removed from the board and new letters added.
It has various configurable options to make play more challenging.
Configurable options include board size, minimum word length, word colours and game time.

## Technology
The app is written in Lua using the [Solar 2D](https://solar2d.com/) game engine.

## Structure
The app entry point is in the `main.lua` file in the repo root. 
Word libraries  used within the app are found in the root and correspond to the naming pattern `words_NN.json` where `NN` represents the number of letters in each word within the file. Also provided are separate files corresponding to the pattern `freqs_NN.json`which contain the frequency of occurrence of each letter within all words of the given length.

## Link to Published App
The app has been published to the Google Play Store:
https://play.google.com/store/apps/details?id=com.crankangle.wordjam