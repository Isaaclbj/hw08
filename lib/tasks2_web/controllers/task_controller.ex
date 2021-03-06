defmodule Tasks2Web.TaskController do
  use Tasks2Web, :controller

  alias Tasks2.Tasks
  alias Tasks2.Tasks.Task
  alias Tasks2.Users

  # plug Tasks2Web.Plugs.RequireAdmin when action in [:new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    tasks = Tasks.list_tasks()
    user = Users.get_user(get_session(conn, :user_id) || -1)
    user_id =
    if is_nil(user) do
      -1
    else
      user.id
    end
    render(conn, "index.html", tasks: tasks, user_id: user_id)
  end

  def new(conn, _params) do
    changeset = Tasks.change_task(%Task{})
    user = Users.get_user(get_session(conn, :user_id) || -1)
    underlings = Users.get_underlings(user.id)
    render(conn, "new.html", changeset: changeset, underlings: underlings, users: Users.list_users)
  end

  def create(conn, %{"task" => task_params}) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        user = Users.get_user(get_session(conn, :user_id))
        underlings = Users.get_underlings(user.id)
        render(conn, "new.html", changeset: changeset, underlings: underlings, users: Users.list_users)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    render(conn, "show.html", task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    changeset = Tasks.change_task(task)
    user = Users.get_user(get_session(conn, :user_id))
    underlings = Users.get_underlings(user.id)
    render(conn, "edit.html", task: task, changeset: changeset, underlings: underlings, users: Users.list_users)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    case Tasks.update_task(task, task_params) do
      {:ok, task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: Routes.task_path(conn, :show, task))

      {:error, %Ecto.Changeset{} = changeset} ->
        user = Users.get_user(get_session(conn, :user_id))
        underlings = Users.get_underlings(user.id)
        render(conn, "edit.html", task: task, changeset: changeset, underlings: underlings, users: Users.list_users)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    {:ok, _task} = Tasks.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: Routes.task_path(conn, :index))
  end
end
