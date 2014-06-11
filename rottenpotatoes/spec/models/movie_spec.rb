# Started with the example in http://pastebin.com/ELQfC8Je
# We're testing a Model => Unit tests
require 'spec_helper'

describe Movie do

  it 'has a valid factory' do
    FactoryGirl.create(:movie).should be_valid
  end

  describe 'simple read operations' do
    context 'happy paths' do
      before :each do
        @movieA = FactoryGirl.create(:movie, title: 'movieA')
      end
=begin
  # commented because HW assignment doesn't specify
  # if Movie has validations to assert
  it 'is invalid without a title' do
    FactoryGirl.create(:movie, title: nil).should_not be_valid
  end
  it 'is invalid without a release date'
  it 'is invalid without a rating'
=end
      it 'finds movies by id' do
        Movie.find_by_id(1).should_not be_nil
      end
      it 'finds movies by title' do
        Movie.find_by_title('movieA').should_not be_nil
      end
    end
    context 'sad paths' do
      before :each do
        @movieA = FactoryGirl.create(:movie, title: 'movieA')
      end
      it 'finds movies by id (sad path)' do
        Movie.find_by_id(99).should be_nil
      end
      it 'finds movies by title (sad path)' do
        Movie.find_by_title('movieZZZ').should be_nil
      end
    end
  end
  describe 'finds movies with the same director' do
    before :each do
      @movieA = FactoryGirl.create(:movie, director: 'DIRECTOR_A')
      @movieB = FactoryGirl.create(:movie, director: 'DIRECTOR_A')
      @movieC = FactoryGirl.create(:movie, director: 'DIRECTOR_B')
      @movieD = FactoryGirl.create(:movie, director: 'DIRECTOR_C')
    end
    context 'exist other movies with the same director' do
      it 'returns all the movies with the same director' do
        director_to_search = 'DIRECTOR_A'
        movie = FactoryGirl.create(:movie, director: director_to_search)

        result = Movie.find_movies_same_director(movie)
        result.count.should eq(3)
        result.map { |m| m.director }.each { |d| d.should eq(director_to_search) }
      end
    end
    context "didn't exist other movies with the same director" do
      it 'returns just this movie' do
        movie = FactoryGirl.create(:movie, director: 'DIRECTOR_X')

        result = Movie.find_movies_same_director(movie)
        result.count.should eq(1)
        result.should eq([movie])
      end
    end
  end
end
