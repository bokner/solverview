defmodule SolverViewWeb.VRP do
  require Logger
  use Phoenix.LiveView

  ## Stages
  @start_new 1
  @solving   2
  @solved    3
  @not_solved 4

  @time_limit 60 * 5 * 1000

  @solver "gecode"
  # "cplex"
  #"coin-bc"
  #"chuffed"

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
    {:noreply, process_solver_event(event, data, socket)}
  end

  def handle_event("ignore", _, socket) do
    {:noreply, socket}
  end

  def handle_event("next_problem", _, socket) do
    {:noreply, new_vrp(socket)}
  end

  def handle_event("solve", _, socket) do
    :ok = solve(socket.assigns.vrp_data, @time_limit)
    {
      :noreply,
      socket
      |> update(:stage, fn _ -> @solving end)
      |> update(:start_ts, fn _ -> DateTime.utc_now() end)
    }
  end

  ######################
  ## Helpers (processing)
  ######################
  defp solve(vrp_data, time_limit) do
    Logger.debug "VRP data: #{inspect vrp_data}"
    my_pid = self()
    {:ok, _pid} =
      MinizincSolver.solve(
        @vrp_model,
        Map.delete(vrp_data, :locations),
        time_limit: time_limit,
        solver: @solver,
        solution_handler: fn (event, data) -> send(my_pid, {:solver_event, event, data}) end
      )
    :ok
  end




  ## Given solver event, produce list of {key, val} that is to be applied to a socket
  defp process_solver_event(:solution, solution, socket) do
    vehicle_assignment = MinizincResults.get_solution_value(
      solution,
      "vehicle_assignment"
    )

    socket
    |> update(:vehicle_assignment, fn _ -> vehicle_assignment end)
    |> update(:total_solutions, &(&1 + 1))
    |> update(:objective, fn _ -> MinizincResults.get_solution_objective(solution) end)
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
      [final_status: MinizincResults.get_status(summary)]
    )
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
    "next_problem"
  end

  defp action(@not_solved) do
    "next_problem"
  end

  defp new_vrp(socket) do
    vrp_instance = choose_vrp_instance()
    vrp_data = VRP.extract_data(vrp_instance)
    assign(
      socket,
      [
        vrp_instance: vrp_instance,
        vrp_data: vrp_data,
        route_colors: generate_route_colors(vrp_data),
        vehicle_assignment: [],
        objective: nil,
        total_solutions: 0,
        start_ts: 0,
        compilation_ts: 0,
        first_solution_ts: 0,
        stage: @start_new,
        time_limit: @time_limit
      ]
    )
  end

  defp choose_vrp_instance() do
    Path.join(
      "data/vrp",
      Enum.random(
      #hd(
        File.ls!(Application.app_dir(:solverl, "priv/data/vrp"))
      )
      #"vrp_16_3_1"
      #"vrp_16_5_1"
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

  defp vehicle_routes(locations, vehicle_assignment) do
    for a <- vehicle_assignment do
      {vehicle_path, _loc_idx} = Enum.reduce(
        a,
        {[], 0},
        fn
          (0, {path, idx}) -> ## customer not in the path
            {path, idx + 1}
          (1, {path, idx}) -> ## customer location visited, add it to the vehicle's route
            {[Enum.at(locations, idx) | path], idx + 1}
        end
      )
      vehicle_path
    end
  end

  ## Attach color to every route
  defp color_routes(routes, colors) do
    Enum.zip(routes, colors)
  end

  defp generate_route_colors(vrp_data) do
    ColorStream.hex(hue: 0.5) |> Enum.take(vrp_data.m)
  end

  defp svg_polygon_points(path) do
    Enum.join(Enum.map(path, fn {x, y} -> "#{x},#{y}" end), " ")
  end

  ## Demand=0 indicates depot location
  defp location_radius(0, _, _) do
    2
  end

  defp location_radius(_, _, _) do
    1
  end

  ## Demand=0 indicates depot location
  defp location_color(0, _, _) do
    "red"
  end

  defp location_color(_, _, _) do
    "blue"
  end

end
