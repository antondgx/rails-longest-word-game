require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @grid = (1..10).map { |_x| ("A".."Z").to_a[rand(0..25)] }.join(" ")
    @start_time = Time.now.to_f
  end

  def score
    @attempt = params[:attempt]
    @grid = params[:grid].split(" ")
    @start_time = params[:start_time].to_f
    @end_time = Time.now.to_f

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
    results_hash = {}

    if not_included?(attempt, grid).positive?
      results_hash[:message] = "the given word is not in the grid"
    elsif !check_word(attempt)
      results_hash[:message] = "the given word is not an english word"
    else
      results_hash[:score] = compute_score(attempt, end_time - start_time)
      results_hash[:message] = "Well Done!"
    end
    results_hash
  end
end
