require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = (1..10).map { |_x| ("A".."Z").to_a[rand(0..25)] }.join(" ")
    @start_time = Time.now
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].split(" ")
    @start_time = Time.new(params[:start_time])
    @end_time = Time.now

    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  private

  def make_hash(arr)
    hash_with_counter = {}
    arr.each do |element|
      hash_with_counter[element] ? hash_with_counter[element] += 1 : hash_with_counter[element] = 1
    end
    hash_with_counter
  end

  def not_included?(attempt, grid)
    attempt_hash = make_hash(attempt.upcase.split(""))
    grid_hash = make_hash(grid)
    not_included_count = 0
    attempt_hash.each do |key, value|
      not_included_count += 1 if grid_hash[key].nil? || value > grid_hash[key]
    end
    not_included_count
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def check_word(attempt)
    raw_json = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    parsed_json = JSON.parse(raw_json)
    return parsed_json["found"]
  end

  def run_game(attempt, grid, start_time, end_time)
    results_hash = { time: end_time - start_time }

    if not_included?(attempt, grid).positive?
      results_hash[:message] = "the given word is not in the grid"
    elsif !check_word(attempt)
      results_hash[:message] = "the given word is not an english word"
    else
      results_hash[:score] = compute_score(attempt, end_time - start_time)
      raise
      results_hash[:message] = "Well Done!"
    end
    results_hash
  end
end

# def generate_grid(grid_size)
#   # TODO: generate random grid of letters
#   (1..grid_size).map { |_x| ("A".."Z").to_a[rand(0..25)] }
# end

# def make_hash(arr)
#   hash_with_counter = {}
#   arr.each do |element|
#     hash_with_counter[element] ? hash_with_counter[element] += 1 : hash_with_counter[element] = 1
#   end
#   hash_with_counter
# end

# def not_included?(attempt, grid)
#   attempt_hash = make_hash(attempt.upcase.split(""))
#   grid_hash = make_hash(grid)
#   not_included_count = 0
#   attempt_hash.each do |key, value|
#     not_included_count += 1 if grid_hash[key].nil? || value > grid_hash[key]
#   end
#   not_included_count
# end

# def compute_score(attempt, time_taken)
#   time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
# end

# def check_word(attempt)
#   raw_json = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
#   parsed_json = JSON.parse(raw_json)
#   return parsed_json["found"]
# end

# def run_game(attempt, grid, start_time, end_time)
#   # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
#   results_hash = { time: end_time - start_time, score: 0 }

#   if not_included?(attempt, grid).positive?
#     results_hash[:message] = "the given word is not in the grid"
#   elsif !check_word(attempt)
#     results_hash[:message] = "the given word is not an english word"
#   else
#     results_hash[:score] = compute_score(attempt, end_time - start_time)
#     results_hash[:message] = "Well Done!"
#   end
#   results_hash
# end

# def generate_grid(grid_size)
#   # TODO: generate random grid of letters
#   (0..grid_size).map { ('a'..'z').to_a[rand(26)] }.join.upcase.split("")
# end

# def run_game(attempt, grid, start_time, end_time)
#   # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
# end

# require_relative "longest_word"

# puts "******** Welcome to the longest word-game!********"
# puts "Here is your grid:"
# grid = generate_grid(9)
# puts grid.join(" ")
# puts "*****************************************************"

# puts "What's your best shot?"
# start_time = Time.now
# attempt = gets.chomp
# end_time = Time.now

# puts "******** Now your result ********"

# result = run_game(attempt, grid, start_time, end_time)

# puts "Your word: #{attempt}"
# puts "Time Taken to answer: #{result[:time]}"
# puts "Your score: #{result[:score]}"
# puts "Message: #{result[:message]}"

# puts "*****************************************************"
