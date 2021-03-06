module Api::V1
class UsersController < ApplicationController

  def create
    err_message = nil

    @user = authorized_app.find_or_create_subscribed_user(params[:user])
    err_message = "Could not create that user." if @user.nil?
    err_message = "Couldn't subscribe user because:#{@user.errors.full_messages[0]}" if @user.errors.count != 0

    if !err_message
      render json: @user, status: :created
    else
      render status: :bad_request, json: {message: err_message}
    end
  end

  def update
    @user = authorized_app.developer.users.find_by_id(params[:id].to_i)
    if @user.nil?
      render status: 410, json: {message: "User with that id does not belong to you"}
    else
      params[:user].delete :id
      params[:user].delete :developer_id
      if @user.update_attributes(params[:user])
        render status: :ok, json: @user
      else
        render status: :unprocessable_entity, json: {message: @user.errors.full_messages.join(', ')}
      end
    end
  end
end
end
