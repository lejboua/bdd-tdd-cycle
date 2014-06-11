class Movie < ActiveRecord::Base

  attr_accessible :title, :rating, :description, :release_date, :director

  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  def self.all_ratings_hash
    Hash[all_ratings.map {|rating| [rating, rating]}]
  end
end

