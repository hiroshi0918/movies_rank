class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    # 投稿・いいね映画とも画像のN+1を避けるため with_attached_image を付け、
    # いいね映画もコントローラ側で用意する(ビューが関連を直接叩かないようにする)。
    @movies = @user.movies.with_attached_image
    @liked_movies = @user.liked_movies.with_attached_image
  end
end
