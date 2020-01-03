class CommentsController < ApplicationController
  def create
    @comment = Comment.create(text: comment_params[:text], movie_id: comment_params[:movie_id], user_id: current_user.id)
    respond_to do |format|
      format.html { redirect_to movie_path(params[:movie_id])  }
      format.json
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:text).merge(user_id: current_user.id, movie_id: params[:movie_id])
  end

end
