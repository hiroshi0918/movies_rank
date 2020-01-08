class MoviesController < ApplicationController
  def index
    @movies = Movie.all.page(params[:page]).per(10)
  end

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    url = params[:movie][:youtube_url]
    url = url.last(11)
    @movie.youtube_url = url
    @movie.save
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
    respond_to do |format|
      format.html
      format.json{render action: :search}
    end
  end

  def rank
    @all_ranks = Movie.create_all_ranks
  end


  private
  def movie_params
    params.require(:movie).permit(:title, :director, :category, :image, :detail, :youtube_url).merge(user_id: current_user.id)
  end
end
