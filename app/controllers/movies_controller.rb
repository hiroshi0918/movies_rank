class MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :rank]
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authorize_movie_owner!, only: [:edit, :update, :destroy]

  def index
    @movies = Movie.order(created_at: :desc).page(params[:page])
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
    scope = Movie.search(params[:keyword]).order(created_at: :desc)

    respond_to do |format|
      format.html do
        @movies = scope.page(params[:page])
      end
      format.json do
        @movies = scope
        render action: :search
      end
    end
  end

  def rank
    @all_ranks = Movie.create_all_ranks
  end


  private
  def movie_params
    params.require(:movie).permit(:title, :original_title, :director, :category, :image, :detail, :youtube_url)
  end

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def authorize_movie_owner!
    return if @movie.user == current_user

    redirect_to movie_path(@movie), alert: "自分の投稿のみ編集できます"
  end
end
