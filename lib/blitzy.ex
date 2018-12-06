defmodule Blitzy do
  use Application
  def start(_type, args), do: Blitzy.Supervisor.start_link(:ok)
end
