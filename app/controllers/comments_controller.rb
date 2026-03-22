class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie

  def create
    @comment = @movie.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_to movie_path(@movie), notice: "コメントを投稿しました" }
        format.json
      end
    else
      @comments = @movie.comments.includes(:user).order(created_at: :desc)
      respond_to do |format|
        format.html { render "movies/show", status: :unprocessable_entity }
        format.json { render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:text)
  end

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end
end
