class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
  
    # --- Ratings ---
    if params[:ratings].present?
      # Some boxes checked
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = params[:ratings]
    elsif params[:commit] == "Refresh"
      # User hit Refresh but unchecked everything -> treat as all selected
      @ratings_to_show = @all_ratings
      session.delete(:ratings)
    elsif session[:ratings].present?
      # No new params, reuse session
      @ratings_to_show = session[:ratings].keys
    else
      # First visit
      @ratings_to_show = @all_ratings
    end
  
    # --- Sort ---
    if params[:sort].present?
      sort = params[:sort]
      session[:sort] = sort
    elsif session[:sort].present?
      sort = session[:sort]
    else
      sort = nil
    end
  
    # --- Movies + Highlighting ---
    case sort
    when 'title'
      @movies = Movie.with_ratings(@ratings_to_show).order(:title)
      @title_header = 'hilite bg-warning'
    when 'release_date'
      @movies = Movie.with_ratings(@ratings_to_show).order(:release_date)
      @release_date_header = 'hilite bg-warning'
    else
      @movies = Movie.with_ratings(@ratings_to_show)
    end
  end   

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
