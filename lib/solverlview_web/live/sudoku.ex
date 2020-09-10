defmodule SolverlviewWeb.Sudoku do
  require Logger
  use Phoenix.LiveView

  ## Stages
  @start_new 1
  @solving   2
  @solved    3
  @not_solved 4

  @time_limit 1000
  ######################
  ## LiveView API
  ######################

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
    puzzle = solve(data, @time_limit)
    {
      :noreply,
      socket
      |> update(:solved_puzzle, fn _ -> puzzle end)
      |> update(:puzzle, fn _ -> puzzle end)
      |> update(:start_ts, fn _ -> DateTime.utc_now() end)
    }
  end

  ######################
  ## Helpers (processing)
  ######################
  defp solve(input, time_limit) do
    puzzle = input_to_puzzle(input)
    my_pid = self()
    {:ok, _pid} =
        Sudoku.solve(
          puzzle,
          time_limit: time_limit,
          solution_handler: fn (event, data) -> send(my_pid, {:solver_event, event, data}) end
    )
    puzzle
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
    |> update(:solved_puzzle, fn _ -> solved_puzzle end)
    |> update(:total_solutions, &(&1 + 1))
    |> update(:stage, fn _ -> @solving end)
    |> update(
         :first_solution_ts,
         fn
           0 -> DateTime.utc_now()
           ts -> ts
         end
       )
  end

  defp process_solver_event(:summary, summary, socket) do
    solution_count = MinizincResults.get_solution_count(summary)
    Logger.debug "Done, found #{solution_count} solution(s)"
    stage = if solution_count > 0, do: @solved, else: @not_solved
    assign(
    socket
    |> update(:stage, fn _ -> stage end),
    [final_status: MinizincResults.get_status(summary)])
  end

  defp process_solver_event(:compiled, %{compilation_timestamp: ts} = compilation_info, socket) do
    Logger.debug "Compiled...#{inspect compilation_info}"
    assign(
      socket,
      [compilation_ts: ts]
    )
  end

  defp process_solver_event(_event, _data, socket) do
    socket
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
    empty = empty_sudoku()
    assign(
      socket,
      [
        total_solutions: 0,
        start_ts: 0,
        compilation_ts: 0,
        first_solution_ts: 0,
        puzzle: empty,
        solved_puzzle: empty,
        stage: @start_new,
        time_limit: @time_limit
      ]
    )
  end

  ######################
  ## Helpers (rendering)
  ######################
  defp button_name(@start_new) do
    "Solve"
  end

  defp button_name(@solving) do
    "Solving..."
  end

  defp button_name(@solved) do
    "Solved! Try another one..."
  end

  defp button_name(@not_solved) do
    "No solutions. Try another one..."
  end


  defp disable_input?(@start_new) do
    false
  end

  defp disable_input?(_other) do
    true
  end

  defp cell_value(sudoku, row, col) do
    case Enum.at(Enum.at(sudoku, row), col) do
      0 -> ""
      v -> v
    end
  end

  @grey_cell_color "#E8E8E8"
  @white_cell_color "white"

  defp cell_background(i, j) when i in [3, 4, 5] and j in [3, 4, 5] do
    @white_cell_color
  end

  defp cell_background(i, j) when i in [3, 4, 5] or j in [3, 4, 5]  do
    @grey_cell_color
  end

  defp cell_background(_i, _j) do
    @white_cell_color
  end


end
