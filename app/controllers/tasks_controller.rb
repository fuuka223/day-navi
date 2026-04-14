class TasksController < ApplicationController

  before_action :set_task, only: [:show, :edit, :update, :destroy, :toggle_status]


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

  def toggle_status
    @task.update(is_completed: !@task.is_completed)
    redirect_to tasks_path
  end

  private
  def task_params
    params_hash = params.require(:task).permit(:title, :content, :deadline, :priority_level)
    params_hash[:priority_level] = params_hash[:priority_level].to_i if params_hash[:priority_level].present?
    params_hash
  end
  
  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end
