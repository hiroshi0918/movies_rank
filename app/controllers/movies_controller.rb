class MoviesController < ApplicationController
  def index
    @movies = Movie.all
  end

  def new
    @movie = Movie.new
  end

  def create
    Movie.create(movie_params)
    redirect_to root_path
  end

  def show
    @movie = Movie.find(params[:id])
    @comment = Comment.new
    @comments = @movie.comments.includes(:user)
    @like = Like.new
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def update
    movie = Movie.find(params[:id])
    movie.update(movie_params)
    redirect_to movie_path(movie.id)
  end

  def destroy
    movie = Movie.find(params[:id])
    movie.destroy
    redirect_to root_path
  end

  def search
    @movies = Movie.search(params[:keyword])
  end


  private
  def movie_params
    params.require(:movie).permit(:title,:director, :category, :image, :detail).merge(user_id: current_user.id)
  end
end
