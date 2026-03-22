class MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :rank]
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authorize_movie_owner!, only: [:edit, :update, :destroy]

  def index
    @all_ranks = Movie.create_all_ranks.includes(:likes)
    @hero_movie = @all_ranks.first || Movie.includes(:likes).order(created_at: :desc).first
    @trending_movies = Movie.includes(:likes).order(created_at: :desc).limit(12)
    @animation_movies = Movie.where(category: 'Animation').includes(:likes).limit(12)
    @action_movies = Movie.where(category: 'Action').includes(:likes).limit(12)
    @drama_movies = Movie.where(category: 'Drama').includes(:likes).limit(12)
  end

  def new
    @movie = current_user.movies.new
  end

  def create
    @movie = current_user.movies.new(movie_params)
    if @movie.save
      redirect_to root_path, notice: "投稿が完了しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.new
    @comments = @movie.comments.includes(:user).order(created_at: :desc)
  end

  def edit
  end

  def update
    if @movie.update(movie_params)
      redirect_to movie_path(@movie.id), notice: "更新が完了しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy
    redirect_to root_path, notice: "投稿を削除しました"
  end

  def search
    @movies = Movie.search(params[:keyword]).includes(:likes)
    respond_to do |format|
      format.html
      format.json{render action: :search}
    end
  end

  def rank
    @all_ranks = Movie.create_all_ranks.includes(:likes)
  end


  private
  def movie_params
    params.require(:movie).permit(:title, :director, :category, :image, :detail, :youtube_url)
  end

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def authorize_movie_owner!
    return if @movie.user == current_user

    redirect_to movie_path(@movie), alert: "自分の投稿のみ編集できます"
  end
end
