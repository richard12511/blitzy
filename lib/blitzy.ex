defmodule Blitzy do
  def run(n_workers, url) when n_workers > 0 do
    worker_func = fn  -> Blitzy.Worker.start(url) end

    1..n_workers
    |> Enum.map(fn _ -> Task.async(worker_func) end)
    |> Enum.map(fn task -> Task.await(task) end)
    |> parse_results()
  end

  defp parse_results(results) do
    {successes, _failures} =
      results
      |> Enum.split_with(fn x ->
        case x do
          {:ok, _} -> true
          _ -> false
        end
      end)

    total_workers = Enum.count(results)
    total_success = Enum.count(successes)
    total_failure = total_workers - total_success
    times = successes |> Enum.map(fn {:ok, time} -> time end)
    average_time = average(times)
    longest_time = Enum.max(times)
    shortest_time = Enum.min(times)

    IO.puts """
    Total workers     : #{total_workers}
    Successful reqs   : #{total_success}
    Failed reqs       : #{total_failure}
    Average (msecs)   : #{average_time}
    Longest (msecs)   : #{longest_time}
    Shortest (msecs)  : #{shortest_time}
"""
  end

  defp average(times) do
    sum = Enum.sum(times)
    if sum > 0 do
      sum / Enum.count(times)
    else
      0
    end
  end
end
