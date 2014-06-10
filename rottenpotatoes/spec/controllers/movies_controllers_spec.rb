# spec/controllers/movie_controller_spec.rb
require 'spec_helper'

describe MoviesController do

  describe "GET #index" do
    it "populates an array of movies" do
      movie = FactoryGirl.create(:movie)
      get :index
      assigns(:movies).should eq([movie])
    end
    it "renders the :index template" do
      get :index
      # response tem de coincidir com o render_template do :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested movie to @movie" do
      movie = FactoryGirl.create(:movie)
      get :show, id: movie
      assigns(:movie).should eq(movie)
    end
    it "renders the :show template" do
      get :show, id: FactoryGirl.create(:movie)
      response.should render_template :show
    end
  end

  describe "GET #new" do
    it "renders the :new template" do
      get :new
      response.should render_template :new
    end
  end

  describe "POST #create" do
    it "create a new movie in the database" do
      expect {
        post :create, movie: FactoryGirl.attributes_for(:movie)
      }.to change(Movie, :count).by(1)
    end

    it "redirects to the home page" do
      post :create, movie: FactoryGirl.attributes_for(:movie)
      response.should redirect_to movies_path
    end
    it "shows a success message" do
      movie_params = FactoryGirl.attributes_for(:movie)
      post :create, movie: movie_params

      flash[:notice].should_not be_nil
      flash[:notice].should eq("#{movie_params[:title]} was successfully created.")
    end
  end

  describe "GET #edit" do
    it "assigns an existing movie to @movie" do
      movie = FactoryGirl.create(:movie)
      get :edit, id: movie
      assigns(:movie).should eq(movie)
    end

    it "renders the :edit template" do
      movie = FactoryGirl.create(:movie)
      get :edit, id: movie
      response.should render_template :edit
    end
  end

  describe "PUT #update" do
    before :each do
      @movie = FactoryGirl.create(:movie)

    end
    it "locates an existing movie in the database" do
      put :update, id: @movie, movie: FactoryGirl.attributes_for(:movie)
      assigns(:movie).should eq(@movie)
    end

    it "updates an existing movie in the database" do
      put :update, id: @movie,
        movie: FactoryGirl.attributes_for(:movie,
                                          title: 'Updated Title',
                                          director: 'Updated Director')
        # refreshes the previously created @movie (from DB)
        @movie.reload
        @movie.title.should eq('Updated Title')
        @movie.director.should eq('Updated Director')
    end

    it "redirects to the home page" do
      put :update, id: @movie, movie: FactoryGirl.attributes_for(:movie)
      response.should redirect_to @movie
    end

    it "shows a success message" do
      movie_params = FactoryGirl.attributes_for(:movie)
      put :update, id: @movie, movie: FactoryGirl.attributes_for(:movie)

      flash[:notice].should_not be_nil
      flash[:notice].should eq("#{movie_params[:title]} was successfully updated.")
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @movie = FactoryGirl.create(:movie)
    end
    it "deletes an existing movie from the database" do
      expect {
        delete :destroy, id: @movie
      }.to change(Movie, :count).by(-1)
    end
    it "redirects to the home page" do
        delete :destroy, id: @movie
        response.should redirect_to movies_path
    end
    it "shows a success message" do
        delete :destroy, id: @movie
        flash[:notice].should_not be_nil
        flash[:notice].should eq("Movie '#{@movie.title}' deleted.")
    end
  end
end
