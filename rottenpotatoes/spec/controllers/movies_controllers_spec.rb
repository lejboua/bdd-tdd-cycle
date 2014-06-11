# spec/controllers/movie_controller_spec.rb
require 'spec_helper'

describe MoviesController do

  describe 'the MoviesHelper.oddness method' do
    it "returns 'odd' for an odd number" do
      seed = 5
      1.upto(100) { |i| oddness(seed + i*2).should eq('odd') }
    end
    it "returns 'even' for an even number" do
      seed = 22
      1.upto(100) { |i| oddness(seed + i*2).should eq('even') }
    end
  end

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
    describe "ratings params passed via query string" do
      before :each do
        @movieA = FactoryGirl.create(:movie, title: 'AAA', release_date: 5.days.ago, rating: 'PG' )
        @movieB = FactoryGirl.create(:movie, title: 'BBB', release_date: 10.days.ago, rating: 'R' )
      end
      context "with the session empty" do
        it "fills the session :ratings and redirects to movies_path again" do
          chosen_rating = { 'PG' => 'PG' }

          get :index, { :ratings => chosen_rating }
          session[:ratings].should eq(chosen_rating)

          response.should be_redirect
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          temp_ratings = redirect_params.select { |p| /^ratings/ =~ p }
          ratings_on_querystring = Hash[temp_ratings.values.map { |r| [r,r] }]
          expect(ratings_on_querystring).to eq(chosen_rating)
        end
      end
      context "with the session already filled with the same :ratings" do
        it "shows the movies with the selected :ratings" do
          # we have to also stub the flash message,
          # since it also uses the session var
          # Obtained from: http://stackoverflow.com/a/9328305/687420
          # we are saying that flash returns a mock object that
          # replies to :sweep, :update, :[] and :keep
          session.stub(:[]).with("flash").and_return double(:sweep => true,
                                                            :update => true,
                                                            :[]= => [],
                                                            :keep => true)

          chosen_rating = { 'PG' => 'PG' }
          # we have to also stub the ratings,
          # since it's also stored in session
          session.stub(:[]).with(:ratings).and_return chosen_rating
          session.stub(:[]).with(:sort).and_return nil

          get :index, { :ratings => chosen_rating }

          # Doesn't make sense since I've stubbed it
          # in the previous lines
          # session[:ratings].should eq(chosen_rating)
          assigns(:movies).should eq([@movieA])
          response.should render_template :index
        end
      end
      context "with the session already filled with different :ratings" do
        it "fills the session :ratings with the new ratings and redirects to movies_path again" do
          # we have to also stub the flash message,
          # since it also uses the session var
          # Obtained from: http://stackoverflow.com/a/9328305/687420
          # we are saying that flash returns a mock object that
          # replies to :sweep, :update, :[] and :keep
          session.stub(:[]).with("flash").and_return double(:sweep => true,
                                                            :update => true,
                                                            :[]= => [],
                                                            :keep => true)
          chosen_rating = { 'R' => 'R' }
          ratings_in_session = { 'PG' => 'PG' }
          # we have to also stub the ratings,
          # since it's also stored in session
          session.stub(:[]).with(:ratings).and_return ratings_in_session
          session.stub(:[]).with(:sort).and_return nil

          session.should_receive(:[]=).with("flash", true)
          session.should_receive(:[]=).with(:sort, nil)
          session.should_receive(:[]=).with(:ratings, chosen_rating)

          get :index, { :ratings => chosen_rating }

          response.should be_redirect
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          temp_ratings = redirect_params.select { |p| /^ratings/ =~ p }
          ratings_on_querystring = Hash[temp_ratings.values.map { |r| [r,r] }]
          expect(ratings_on_querystring).to eq(chosen_rating)
        end
      end
    end
    describe 'sort param passed via query string' do
      context 'with the session empty' do
        it 'redirects to :index with all ratings shown in the query string (RESTful compliant)' do
          get :index, { :sort => 'title' }
          response.should be_redirect

          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          temp_ratings = redirect_params.select { |p| /^ratings/ =~ p }
          ratings_on_querystring = Hash[temp_ratings.values.map { |r| [r,r] }]
          expect(ratings_on_querystring).to eq(Movie.all_ratings_hash)
        end
      end
      context 'with the session already filled with :ratings and :sort' do
        before :each do
          @movieA = FactoryGirl.create(:movie, title: 'AAA', release_date: 5.days.ago )
          @movieB = FactoryGirl.create(:movie, title: 'BBB', release_date: 10.days.ago )

          # we have to also stub the flash message,
          # since it also uses the session var
          # Obtained from: http://stackoverflow.com/a/9328305/687420
          # we are saying that flash returns a mock object that
          # replies to :sweep, :update, :[] and :keep
          session.stub(:[]).with("flash").and_return double(:sweep => true,
                                                            :update => true,
                                                            :[]= => [],
                                                            :keep => true)
          @ratings_to_use = { 'PG' => 'PG' }
          # we have to also stub the ratings,
          # since it's also stored in session
          session.stub(:[]).with(:ratings).and_return @ratings_to_use
        end

        it "shows movies sorted by title" do
          # fill the session previously with the sort param
          # because it redirects if it wasn't previously on session
          session.stub(:[]).with(:sort).and_return 'title'
          get :index, { :sort => 'title', :ratings => @ratings_to_use }

          assigns(:movies).should eq([@movieA, @movieB])
        end

        it "shows movies sorted by release_date" do
          # fill the session previously with the sort param
          # because it redirects if it wasn't previously on session
          session.stub(:[]).with(:sort).and_return 'release_date'
          get :index, { :sort => 'release_date', :ratings => @ratings_to_use }

          assigns(:movies).should eq([@movieB, @movieA])
        end
      end
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
