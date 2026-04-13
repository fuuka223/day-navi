class TopsController < ApplicationController
  def index
    if user_signed_in?
      @tasks = current_user.tasks.order(created_at: :desc).limit(5)
    end
  end
end
