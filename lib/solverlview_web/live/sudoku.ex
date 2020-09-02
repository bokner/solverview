defmodule SolverlviewWeb.Sudoku do
  require Logger
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        [
          total_solutions: 0,
          sudoku: empty_sudoku(),
          solving: false
        ]
      )
    }
  end

  def handle_event(:new_solution, _, socket) do
    {:noreply, update(socket, :total_solutions, &(&1 + 1))}
  end

  def handle_event("solve", data, socket) do
    Logger.debug "Data: #{inspect data}, Socket: #{inspect socket}"
    solve(data, socket)
    {:noreply, solve(data, socket)}
  end


  def render(assigns) do
    ~L"""
    <form phx-submit="solve" method="post" width="50%">
      <div class="sudoku">
      <%= for i <- 0..8 do %>
        <div>
          <%= for j <- 0..8 do %>
            <input maxlength="1" size="1" name="input[<%= i %>][<%= j %>]" value="<%= Enum.at(Enum.at(@sudoku, i), j) %>"
              <%= if @solving, do: "disabled" %>/>
          <% end %>
        </div>
      <% end %>
      </div>
      <button>Start</button>

    </form>
    """
  end


  defp solve(data, socket) do
    puzzle = input_to_puzzle(data)
    res = File.cd!(
      Application.app_dir(:solverl, "priv"),
      fn -> Sudoku.solve_sync(puzzle) end
    )
    solved_puzzle = MinizincResults.get_solution_value(
      MinizincResults.get_last_solution(res),
      "puzzle"
    )
    update(socket, :sudoku, fn _ -> solved_puzzle end)
  end

  defp input_to_puzzle(data) do
    input = data["input"]
    Enum.map(
      Map.to_list(input),
      fn ({_idx, m}) ->
        Enum.map(
          Map.to_list(m),
          fn ({_numstr, val}) -> if val == "", do: 0, else: String.to_integer(val)
          end
        )
      end
    )
  end

  defp empty_sudoku() do
    Enum.map(
      0..8,
      fn (r) -> Enum.map(0..8, fn _c -> "" end)
      end
    )
  end

end
