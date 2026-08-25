class SessionsController < ApplicationController
  def new
    redirect_to payment_advice_path if session[:accounts_user].present?
  end

  def create
    if params[:email].to_s.include?("@") && params[:password].to_s.length >= 4
      session[:accounts_user] = params[:email]
      redirect_to payment_advice_path
    else
      flash.now[:alert] = "Enter a valid email and at least 4 characters password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
