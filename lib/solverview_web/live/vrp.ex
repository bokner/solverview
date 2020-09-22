defmodule SolverViewWeb.VRP do
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


  @vrp_model MinizincUtils.resource_file("mzn/vrp.mzn")


  ######################
  ## LiveView API
  ######################

  def mount(_params, _session, socket) do
    {
      :ok,
      new_vrp(socket)
    }
  end

  def handle_info({:solver_event, event, data}, socket) do
    {
      :noreply,
      process_solver_event(
        event,
        data,
        socket
        |> update(
             :running_time,
             fn _ -> DateTime.diff(DateTime.utc_now(), socket.assigns.start_ts, :millisecond)
             end
           )
      )
    }
  end

  def handle_event("ignore", _, socket) do
    {:noreply, socket}
  end

  def handle_event("next_problem", _, socket) do
    {:noreply, new_vrp(socket)}
  end

  def handle_event("solve", args, socket) do
    time_limit = case MinizincUtils.parse_value(args["time_limit"]) do
      t when is_integer(t) -> 1000 * t
      ## secs -> msecs
      _not_integer -> @time_limit
    end
    {:ok, solver_pid} = solve(socket.assigns.vrp_data, args["solver"], time_limit)
    {
      :noreply,
      reset_minizinc(socket)
      |> update(:solver_args, fn _ -> %{"solver" => args["solver"], "time_limit" => time_limit} end)
      |> update(:stage, fn _ -> @solving end)
      |> update(:start_ts, fn _ -> DateTime.utc_now() end)
      |> update(:solver_pid, fn _ -> solver_pid end)
    }
  end

  def handle_event("stop", _, socket) do
    solver_pid = socket.assigns.solver_pid
    stop_solver(solver_pid)
    {
      :noreply,
      socket
      |> update(:stage, fn _ -> @stopping end)

    }
  end

  ######################
  ## Helpers (processing)
  ######################
  defp solve(vrp_data, solver_id, time_limit) do
    my_pid = self()
    {:ok, _pid} =
      MinizincSolver.solve(
        @vrp_model,
        Map.delete(vrp_data, :locations),
        time_limit: time_limit,
        solver: solver_id,
        solution_handler: fn (event, data) -> send(my_pid, {:solver_event, event, data}) end
      )
  end

  defp stop_solver(solver_pid) do
    Logger.debug "Request to stop the solver..."
    MinizincSolver.stop_solver(solver_pid)
  end




  ## Given solver event, produce list of {key, val} that is to be applied to a socket
  defp process_solver_event(:solution, solution, socket) do

    subcircuits = MinizincResults.get_solution_value(
      solution,
      "succ"
    )

    vroutes = vehicle_routes(socket.assigns.vrp_data.locations, subcircuits)

    now_ts = DateTime.utc_now()
    socket
    |> update(:vehicle_routes, fn _ -> vroutes end)
    |> update(:total_solutions, &(&1 + 1))
    |> update(:objective, fn _ -> MinizincResults.get_solution_objective(solution) end)
    |> update(:stage, fn _ -> @solving end)
    |> update(
         :first_solution_ts,
         fn
           0 -> now_ts
           ts -> ts
         end
       )
    |> update(:last_solution_ts, fn _ -> now_ts end)

  end

  defp process_solver_event(:summary, summary, socket) do
    solution_count = MinizincResults.get_solution_count(summary)
    Logger.debug "Done, found #{solution_count} solution(s)"
    stage = if solution_count > 0, do: @solved, else: @not_solved
    assign(
      socket
      |> update(:stage, fn _ -> stage end),
      [final_status: MinizincResults.get_status(summary)]
    )
  end

  defp process_solver_event(:compiled, compilation_info, socket) do
    Logger.debug "Compiled..."
    socket
    |> update(:compilation_ts, fn _ -> compilation_info.compilation_timestamp end)

  end

  defp process_solver_event(:minizinc_error, error, socket) do
    assign(
      socket,
      [
        stage: @error,
        minizinc_error: error,
        final_status: "MINIZINC ERROR"
      ]
    )
  end

  defp process_solver_event(event, data, socket) do
    Logger.error "Unknown event #{inspect event}, data: #{inspect data}"
    socket
  end


  defp new_vrp(socket) do
    vrp_instance = choose_vrp_instance()
    vrp_data = VRP.extract_data(vrp_instance)
    reset_minizinc(
      assign(
        socket,
        [
          vrp_instance: vrp_instance,
          vrp_data: vrp_data,
          solver_args: %{
            "solver" => "org.gecode.gecode",
            "time_limit" => @time_limit
          },
          route_colors: generate_route_colors(vrp_data),
          stage: @start_new,
          time_limit: @time_limit
        ]
      )
    )
  end

  defp reset_minizinc(socket) do
    assign(
      socket,
      [
        vehicle_routes: [],
        objective: nil,
        total_solutions: 0,
        start_ts: 0,
        compilation_ts: 0,
        first_solution_ts: 0,
        last_solution_ts: 0,
        running_time: 0,
        solver_pid: nil
      ]
    )
  end

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

  defp choose_vrp_instance() do
    instances = #["vrp_16_3_1"]
      File.ls!(Application.app_dir(:solverl, "priv/data/vrp"))
    Path.join(
      "data/vrp",
      Enum.random(
        #hd(
        instances
      )
      #"vrp_21_6_1"
      #"vrp_16_3_1"
      #"vrp_16_5_1"
    )
  end

  ######################
  # Routes
  ######################
  def vehicle_routes(locations, subcircuits) do
    for s <- subcircuits do
      for loc <- circuit_to_route(s) do
        Enum.at(locations, loc)
      end
    end
  end

  ## Turn subcircuit into the sequence of visits
  def circuit_to_route(circuit) do
    ## We assume that subcircuit is 1-based; bring it to 0-based for simplicity
    s0 = for c <- circuit, do: c - 1
    ## The last member of circuit is a convenient starting point
    start = List.last(s0)
    Enum.reduce_while(
      s0,
      [start],
      fn _i, [next | _rest] = acc ->
        next = Enum.at(s0, next)
        if next != start, do: {:cont, [next | acc]}, else: {:halt, acc}
      end
    )
  end

  ######################
  ## Helpers (rendering)
  ######################

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


  defp svg_viewbox(locations, padding, scale) do
    {x, y} = Enum.unzip(locations)
    min_x = Enum.min(x)
    min_y = Enum.min(y)
    width = Enum.max(x) - min_x
    height = Enum.max(y) - min_y
    "#{(min_x - padding) * scale} #{(min_y - padding) * scale} #{(width + 2 * padding) * scale} #{
      (height + 2 * padding) * scale
    } "
  end



  ## Attach color to every route
  defp color_routes(routes, colors) do
    Enum.zip(routes, colors)
  end

  defp generate_route_colors(vrp_data) do
    ColorStream.hex(hue: 0.5)
    |> Enum.take(vrp_data.m)
  end

  defp svg_polygon_points(path) do
    Enum.join(Enum.map(path, fn {x, y} -> "#{x},#{y}" end), " ")
  end

  ## Demand=0 indicates depot location
  defp location_radius(0, _, _) do
    2
  end

  defp location_radius(_, _, _) do
    0.5
  end

  ## Demand=0 indicates depot location
  defp location_color(0, _, _) do
    "red"
  end

  defp location_color(_, _, _) do
    "blue"
  end

end
