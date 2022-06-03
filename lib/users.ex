defmodule Users do
  alias Users.User
  alias Users.Repo
  import Ecto.Query
  alias Ecto.Multi
  alias Users.AuditLogs

  def create(user = %User{}) do
    user = User.changeset(user)

    transaction =
      Multi.new()
      |> Multi.insert_or_update(:users, user)
      |> Repo.transaction(timeout: :infinity)

    case transaction do
      {:ok, %{users: user = %Users.User{}}} -> {:ok, user}
      _ -> {:error, "not created"}
    end
  end

  def update(id, attrs) do
    user = Repo.get(User, id)
    new_user = change(user, attrs)

    transaction =
      Multi.new()
      |> Multi.update(:users, new_user)
      |> Multi.run(:audit_log_in_file, fn _repo, user ->
        AuditLogs.handle(user)
        {:ok, :noop}
      end)
      |> Repo.transaction(timeout: :infinity)

    case transaction do
      {:ok, %{users: user = %Users.User{}}} -> {:ok, user}
      _ -> {:error, "not updated"}
    end
  end

  def change(user = %User{}, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
