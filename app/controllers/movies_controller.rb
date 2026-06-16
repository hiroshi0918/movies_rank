class MoviesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :rank, :catalog]
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :authorize_movie_owner!, only: [:edit, :update, :destroy]

  def index
    @all_ranks = Movie.create_all_ranks.with_attached_image
    @hero_movie = @all_ranks.first || Movie.order(created_at: :desc).first
    @trending_movies = Movie.with_attached_image.order(created_at: :desc).limit(12)
    # カテゴリ別の行はDBに実在するカテゴリから動的生成する。
    # (以前は英語固定値 'Action'/'Animation'/'Drama' で絞り込んでおり、
    #  日本語カテゴリで保存されたデータでは常に空になっていた)
    @category_rows = category_rows
  end

  def new
    @movie = current_user.movies.new
    @categories = existing_categories
  end

  def create
    @movie = current_user.movies.new(movie_params)
    if @movie.save
      redirect_to root_path, notice: "投稿が完了しました"
    else
      @categories = existing_categories
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @comment = Comment.new
    @comments = @movie.comments.includes(:user).order(created_at: :desc)
  end

  def edit
    @categories = existing_categories
  end

  def update
    if @movie.update(movie_params)
      redirect_to movie_path(@movie.id), notice: "更新が完了しました"
    else
      @categories = existing_categories
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @movie.destroy
    redirect_to root_path, notice: "投稿を削除しました"
  end

  def search
    @movies = Movie.search(params[:keyword]).with_attached_image
    respond_to do |format|
      format.html
      format.json{render action: :search}
    end
  end

  def rank
    @all_ranks = Movie.create_all_ranks.with_attached_image
  end

  # 全映画カタログ。カテゴリ絞り込み・並び替え・ページネーション対応。
  SORT_OPTIONS = {
    "new"     => { label: "新着順",   order: { created_at: :desc } },
    "popular" => { label: "人気順",   order: { likes_count: :desc, created_at: :desc } },
    "title"   => { label: "タイトル順", order: { title: :asc } },
  }.freeze

  def catalog
    @categories = existing_categories
    @sort = SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : "new"
    @category = params[:category].presence

    scope = Movie.with_attached_image
    scope = scope.where(category: @category) if @category && @categories.include?(@category)
    @movies = scope.order(SORT_OPTIONS[@sort][:order]).page(params[:page]).per(24)
  end


  private
  def movie_params
    params.require(:movie).permit(:title, :director, :category, :image, :detail, :youtube_url)
  end

  # DBに実在するカテゴリのうち、投稿数が多い上位を行として返す。
  # 返り値は [カテゴリ名, 映画リレーション] の配列。
  def category_rows
    Movie.group(:category)
         .order(Arel.sql('COUNT(*) DESC'))
         .limit(4)
         .count
         .keys
         .map { |category| [category, Movie.where(category: category).with_attached_image.order(created_at: :desc).limit(12)] }
  end

  # 既存カテゴリ一覧(datalist候補)。投稿時の表記揺れを抑える。
  def existing_categories
    Movie.where.not(category: [nil, ""]).distinct.order(:category).pluck(:category)
  end

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def authorize_movie_owner!
    return if @movie.user == current_user

    redirect_to movie_path(@movie), alert: "自分の投稿のみ編集できます"
  end
end
