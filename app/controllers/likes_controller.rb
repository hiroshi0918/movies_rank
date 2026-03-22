class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie

  def create
    @like = current_user.likes.find_or_initialize_by(movie: @movie)

    if @like.persisted? || @like.save
      redirect_back fallback_location: movie_path(@movie), notice: "いいねしました"
    else
      redirect_back fallback_location: movie_path(@movie), alert: "いいねに失敗しました"
    end
  end

  def destroy
    @like = current_user.likes.find_by(movie: @movie)

    if @like&.destroy
      redirect_back fallback_location: movie_path(@movie), notice: "いいねを解除しました"
    else
      redirect_back fallback_location: movie_path(@movie), alert: "いいねの解除に失敗しました"
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end
