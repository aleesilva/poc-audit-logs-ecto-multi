defmodule Users.AuditLogs do
  def handle(data) do
    Map.delete(data.users, :__meta__)

    response =
      data.users
      |> Map.delete(:__meta__)
      |> Map.delete(:__struct__)
      |> Jason.encode()

    case response do
      {:ok, value} -> create_log_file_and_insert_data(value)
      {:erro, error} -> {:error, error}
      _ -> {:error, "not found"}
    end
  end

  def create_log_file_and_insert_data(data) do
    case File.open("audit_logs.txt", [:append]) do
      {:ok, value} -> IO.binwrite(value, "\n#{data} ,")
      _ -> {:error, "failed to record logs"}
    end
  end
end
