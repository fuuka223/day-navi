class TasksController < ApplicationController

  before_action :set_task, only: [:edit, :update, :destroy]


  def index
    @tasks = current_user.tasks
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.new(task_params)
    @task.is_completed = false
    if @task.save
      redirect_to tasks_path
    else
      p @task.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path
    else
      p @task.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, status: :see_other
  end

  private
  def task_params
    params.require(:task).permit(:title, :content, :priority_level, :is_completed)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end
