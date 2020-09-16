# SolverView

[solverl](https://github.com/bokner/solverl) + [LiveView](https://github.com/phoenixframework/phoenix_live_view) examples.

## Setup

### Building from source

 - Install MiniZinc 2.4.3. Please refer to https://www.minizinc.org/software.html for details. 
 - Install Phoenix Framework. Please refer to https://hexdocs.pm/phoenix/installation.html for details.
 - Run `mix setup` 
 - Start the Phoenix server by running one of:

```mix phx.server``` or  ```iex -S mix phx.server```

### Building local Docker image

 - Install Docker
 - Run 'make build_docker run_docker'
 
### Using image from Docker hub

 - Install Docker
 - Run 'docker run -p 4000:4000 bokner/solverview'  

## Running examples

Now you can visit localhost:4000/`<example>` in your web browser.
 
## The list of available examples:

- Sudoku: http://localhost:4000/sudoku 
- VRP (Vehicle Routing Problem): http://localhost:4000/vrp

