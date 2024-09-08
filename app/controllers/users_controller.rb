class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @stories = @user.stories
  end
end
