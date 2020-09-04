defmodule SolverlviewWeb.Sudoku do
  require Logger
  use Phoenix.LiveView

  ## Stages
  @start_new 1
  @solving   2
  @solved    3
  @not_solved 4

  def mount(_params, _session, socket) do
    {
      :ok,
      new_puzzle(socket)
    }
  end

  def handle_info({:solver_event, event, data}, socket) do
    {:noreply, process_solver_event(event, data, socket)}
  end

  def handle_event("ignore", _, socket) do
    {:noreply, socket}
  end

  def handle_event("next_puzzle", _, socket) do
    {:noreply, new_puzzle(socket)}
  end

  def handle_event("solve", data, socket) do
    Logger.debug "Data: #{inspect data}, Socket: #{inspect socket}"
    solve(data)
    {:noreply, socket}
  end


  def render(assigns) do
    ~L"""
    <div>
    <h1 style="text-align:center">Sudoku</h1>
    <h2 style="text-align:center"># of solutions: <%= @total_solutions %></h2>
    <form phx-submit="<%= action(@stage) %>" method="post">
      <div class="sudoku" style="text-align:center">
      <%= for i <- 0..8 do %>
        <div>
          <tr>
          <%= for j <- 0..8 do %>
            <input style="border-style: solid" maxlength="1" size="1" name="input[<%= i %>][<%= j %>]" value="<%= Enum.at(Enum.at(@sudoku, i), j) %>"
              />
          <% end %>
          </tr>
        </div>
      <% end %>
      <button <%= if @stage == 2, do: "disabled" %>><%= button_name(@stage) %></button>
      </div>

    </form>
    </div>
    """
  end


  defp solve(input) do
    puzzle = input_to_puzzle(input)
    my_pid = self()
    {:ok, _pid} = File.cd!(
      Application.app_dir(:solverl, "priv"),
      fn ->
        Sudoku.solve(
          puzzle,
          solution_handler: fn (event, data) -> send(my_pid, {:solver_event, event, data}) end
        )
      end
    )

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
      fn (_r) -> Enum.map(0..8, fn _c -> "" end)
      end
    )
  end

  ## Given solver event, produce list of {key, val} that is to be applied to a socket
  defp process_solver_event(:solution, solution, socket) do
    solved_puzzle = MinizincResults.get_solution_value(
      solution,
      "puzzle"
    )
    socket
    |> update(:sudoku, fn _ -> solved_puzzle end)
    |> update(:total_solutions, &(&1 + 1))
    |> update(:stage, fn _ -> @solving end)
  end

  defp process_solver_event(:summary, summary, socket) do
    stage = if MinizincResults.get_solution_count(summary) > 0, do: @solved, else: @not_solved
    socket
    |> update(:stage, fn _ -> stage end)
  end

  defp process_solver_event(_event, _data, socket) do
    socket
  end

  defp button_name(@start_new) do
    "Start"
  end

  defp button_name(@solving) do
    "Solving..."
  end

  defp button_name(@solved) do
    "Solved! Try next one..."
  end

  defp button_name(@not_solved) do
    "No solutions. Try next one..."
  end

  defp action(@start_new) do
    "solve"
  end

  defp action(@solving) do
    "ignore"
  end

  defp action(@solved) do
    "next_puzzle"
  end

  defp action(@not_solved) do
    "next_puzzle"
  end

  defp new_puzzle(socket) do
    assign(
      socket,
      [
        total_solutions: 0,
        sudoku: empty_sudoku(),
        stage: @start_new
      ]
    )
  end

end
