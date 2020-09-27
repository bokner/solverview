defmodule SolverViewWeb.IDE do
  @moduledoc false

  require Logger
  use Phoenix.LiveView


  ## Stages
  @start_new 1
  @stopping  2
  @solving   3
  @solved    4
  @not_solved 5
  @error      6


  @time_limit 60 * 5 * 1000

  ######################
  ## LiveView API
  ######################


  def mount(_params, _session, socket) do
    {
      :ok,
      new_session(socket)
    }
  end



  defp new_session(socket) do
    assign(
      socket,
      [
        stage: @start_new,
        objective: nil,
        total_solutions: 0,
        start_ts: 0,
        compilation_ts: 0,
        first_solution_ts: 0,
        last_solution_ts: 0,
        running_time: 0,
        solver_pid: nil,
        solver_args: %{
          "solver" => "org.gecode.gecode",
          "time_limit" => @time_limit
        }
      ]
    )
  end

  ################### TODO: Shared funcs, move to utils
  defp solver_list() do
    disallowed_solverids = disallowed_solvers()
    Enum.flat_map(
      MinizincSolver.get_solvers(),
      fn solver ->
        if solver["id"] in disallowed_solverids do
          []
        else
          [
            {solver["id"], solver["name"]}
          ]
        end

      end
    )
  end

  defp disallowed_solvers() do
    [
      "org.minizinc.findmus",
      "org.gecode.gist",
      "org.minizinc.globalizer",
      "org.minizinc.mip.scip",
      "org.minizinc.mip.xpress"
    ]
  end

  defp button_name(@solving) do
    "Stop"
  end

  defp button_name(@stopping) do
    "Stopping..."
  end

  defp button_name(_stage) do
    "Solve"
  end

  defp action(@solving) do
    "stop"
  end

  defp action(@stopping) do
    "ignore"
  end

  defp action(_) do
    "solve"
  end

end
