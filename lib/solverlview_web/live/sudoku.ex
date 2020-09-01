defmodule SolverlviewWeb.Sudoku do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :total_solutions, 0)}
  end

  def handle_event(:new_solution, _, socket) do
    {:noreply, update(socket, :total_solutions, &(&1 + 1))}
  end


  def render(assigns) do
    ~L"""
    <div>
        <h1># of solutions: <%= @total_solutions %></h1>
      <div style="  display: table; margin: 0 auto; width: 50%">
        <table id="puzzle_grid" border="1">
            <tbody>
            <tr>
                <td width="2" class="g0" id="c00">
                    <input class="d0" size="1"  name="cv30f11" maxlength="1" id="f00"></td>
                <td width="2" class="f0" id="c10"><input class="d0" size="1"  name="cv30f21" maxlength="1"
                                               id="f10"></td>
                <td width="2" class="f0" id="c20"><input class="d0" size="1"  name="cv30f31" maxlength="1"
                                               id="f20"></td>
                <td width="2" class="g0" id="c30"><input class="s0" size="1"  name="scv30f41"
                                               value="5" id="f30"></td>
                <td width="2" class="f0" id="c40"><input class="s0" size="1"  name="scv30f51"
                                               value="9" id="f40"></td>
                <td width="2" class="f0" id="c50"><input class="d0" size="1"  name="cv30f61" maxlength="1"
                                               id="f50"></td>
                <td width="2" class="g0" id="c60"><input class="s0" size="1"  name="scv30f71"
                                               value="7" id="f60"></td>
                <td width="2" class="f0" id="c70"><input class="d0" size="1"  name="cv30f81" maxlength="1"
                                               id="f70"></td>
                <td width="2" class="f0" id="c80"><input class="d0" size="1"  name="cv30f91" maxlength="1"
                                               id="f80"></td>
            </tr>
            <tr>
                <td width="2" class="e0" id="c01"><input class="s0" size="1"  name="scv30f12"
                                               value="6" id="f01"></td>
                <td width="2" class="c0" id="c11"><input class="s0" size="1"  name="scv30f22"
                                               value="1" id="f11"></td>
                <td width="2" class="c0" id="c21"><input class="s0" size="1"  name="scv30f32"
                                               value="8" id="f21"></td>
                <td width="2" class="e0" id="c31"><input class="d0" size="1"  name="cv30f42" maxlength="1"
                                               id="f31"></td>
                <td width="2" class="c0" id="c41"><input class="s0" size="1"  name="scv30f52"
                                               value="7" id="f41"></td>
                <td width="2" class="c0" id="c51"><input class="s0" size="1"  name="scv30f62"
                                               value="3" id="f51"></td>
                <td width="2" class="e0" id="c61"><input class="d0" size="1"  name="cv30f72" maxlength="1"
                                               id="f61"></td>
                <td width="2" class="c0" id="c71"><input class="s0" size="1"  name="scv30f82"
                                               value="9" id="f71"></td>
                <td width="2" class="c0" id="c81"><input class="d0" size="1"  name="cv30f92" maxlength="1"
                                               id="f81"></td>
            </tr>
            <tr>
                <td width="2" class="e0" id="c02"><input class="d0" size="1"  name="cv30f13" maxlength="1"
                                               id="f02"></td>
                <td width="2" class="c0" id="c12"><input class="d0" size="1"  name="cv30f23" maxlength="1"
                                               id="f12"></td>
                <td width="2" class="c0" id="c22"><input class="d0" size="1"  name="cv30f33" maxlength="1"
                                               id="f22"></td>
                <td width="2" class="e0" id="c32"><input class="s0" size="1"  name="scv30f43"
                                               value="6" id="f32"></td>
                <td width="2" class="c0" id="c42"><input class="d0" size="1"  name="cv30f53" maxlength="1"
                                               id="f42"></td>
                <td width="2" class="c0" id="c52"><input class="s0" size="1"  name="scv30f63"
                                               value="2" id="f52"></td>
                <td width="2" class="e0" id="c62"><input class="d0" size="1"  name="cv30f73" maxlength="1"
                                               id="f62"></td>
                <td width="2" class="c0" id="c72"><input class="s0" size="1"  name="scv30f83"
                                               value="4" id="f72"></td>
                <td width="2" class="c0" id="c82"><input class="d0" size="1"  name="cv30f93" maxlength="1"
                                               id="f82"></td>
            </tr>
            <tr>
                <td width="2" class="g0" id="c03"><input class="d0" size="1"  name="cv30f14" maxlength="1"
                                               id="f03"></td>
                <td width="2" class="f0" id="c13"><input class="d0" size="1"  name="cv30f24" maxlength="1"
                                               id="f13"></td>
                <td width="2" class="f0" id="c23"><input class="d0" size="1"  name="cv30f34" maxlength="1"
                                               id="f23"></td>
                <td width="2" class="g0" id="c33"><input class="s0" size="1"  name="scv30f44"
                                               value="7" id="f33"></td>
                <td width="2" class="f0" id="c43"><input class="s0" size="1"  name="scv30f54"
                                               value="5" id="f43"></td>
                <td width="2" class="f0" id="c53"><input class="d0" size="1"  name="cv30f64" maxlength="1"
                                               id="f53"></td>
                <td width="2" class="g0" id="c63"><input class="s0" size="1"  name="scv30f74"
                                               value="6" id="f63"></td>
                <td width="2" class="f0" id="c73"><input class="s0" size="1"  name="scv30f84"
                                               value="2" id="f73"></td>
                <td width="2" class="f0" id="c83"><input class="d0" size="1"  name="cv30f94" maxlength="1"
                                               id="f83"></td>
            </tr>
            <tr>
                <td width="2" class="e0" id="c04"><input class="s0" size="1"  name="scv30f15"
                                               value="8" id="f04"></td>
                <td width="2" class="c0" id="c14"><input class="d0" size="1"  name="cv30f25" maxlength="1"
                                               id="f14"></td>
                <td width="2" class="c0" id="c24"><input class="d0" size="1"  name="cv30f35" maxlength="1"
                                               id="f24"></td>
                <td width="2" class="e0" id="c34"><input class="d0" size="1"  name="cv30f45" maxlength="1"
                                               id="f34"></td>
                <td width="2" class="c0" id="c44"><input class="s0" size="1"  name="scv30f55"
                                               value="4" id="f44"></td>
                <td width="2" class="c0" id="c54"><input class="d0" size="1"  name="cv30f65" maxlength="1"
                                               id="f54"></td>
                <td width="2" class="e0" id="c64"><input class="d0" size="1"  name="cv30f75" maxlength="1"
                                               id="f64"></td>
                <td width="2" class="c0" id="c74"><input class="d0" size="1"  name="cv30f85" maxlength="1"
                                               id="f74"></td>
                <td width="2" class="c0" id="c84"><input class="s0" size="1"  name="scv30f95"
                                               value="7" id="f84"></td>
            </tr>
            <tr>
                <td width="2" class="e0" id="c05"><input class="d0" size="1"  name="cv30f16" maxlength="1"
                                               id="f05"></td>
                <td width="2" class="c0" id="c15"><input class="s0" size="1"  name="scv30f26"
                                               value="6" id="f15"></td>
                <td width="2" class="c0" id="c25"><input class="s0" size="1"  name="scv30f36"
                                               value="1" id="f25"></td>
                <td width="2" class="e0" id="c35"><input class="d0" size="1"  name="cv30f46" maxlength="1"
                                               id="f35"></td>
                <td width="2" class="c0" id="c45"><input class="s0" size="1"  name="scv30f56"
                                               value="2" id="f45"></td>
                <td width="2" class="c0" id="c55"><input class="s0" size="1"  name="scv30f66"
                                               value="9" id="f55"></td>
                <td width="2" class="e0" id="c65"><input class="d0" size="1"  name="cv30f76" maxlength="1"
                                               id="f65"></td>
                <td width="2" class="c0" id="c75"><input class="d0" size="1"  name="cv30f86" maxlength="1"
                                               id="f75"></td>
                <td width="2" class="c0" id="c85"><input class="d0" size="1"  name="cv30f96" maxlength="1"
                                               id="f85"></td>
            </tr>
            <tr>
                <td width="2" class="g0" id="c06"><input class="d0" size="1"  name="cv30f17" maxlength="1"
                                               id="f06"></td>
                <td width="2" class="f0" id="c16"><input class="s0" size="1"  name="scv30f27"
                                               value="4" id="f16"></td>
                <td width="2" class="f0" id="c26"><input class="d0" size="1"  name="cv30f37" maxlength="1"
                                               id="f26"></td>
                <td width="2" class="g0" id="c36"><input class="s0" size="1"  name="scv30f47"
                                               value="9" id="f36"></td>
                <td width="2" class="f0" id="c46"><input class="d0" size="1"  name="cv30f57" maxlength="1"
                                               id="f46"></td>
                <td width="2" class="f0" id="c56"><input class="s0" size="1"  name="scv30f67"
                                               value="5" id="f56"></td>
                <td width="2" class="g0" id="c66"><input class="d0" size="1"  name="cv30f77" maxlength="1"
                                               id="f66"></td>
                <td width="2" class="f0" id="c76"><input class="d0" size="1"  name="cv30f87" maxlength="1"
                                               id="f76"></td>
                <td width="2" class="f0" id="c86"><input class="d0" size="1"  name="cv30f97" maxlength="1"
                                               id="f86"></td>
            </tr>
            <tr>
                <td width="2" class="e0" id="c07"><input class="d0" size="1"  name="cv30f18" maxlength="1"
                                               id="f07"></td>
                <td width="2" class="c0" id="c17"><input class="s0" size="1"  name="scv30f28"
                                               value="5" id="f17"></td>
                <td width="2" class="c0" id="c27"><input class="d0" size="1"  name="cv30f38" maxlength="1"
                                               id="f27"></td>
                <td width="2" class="e0" id="c37"><input class="s0" size="1"  name="scv30f48"
                                               value="1" id="f37"></td>
                <td width="2" class="c0" id="c47"><input class="s0" size="1"  name="scv30f58"
                                               value="8" id="f47"></td>
                <td width="2" class="c0" id="c57"><input class="d0" size="1"  name="cv30f68" maxlength="1"
                                               id="f57"></td>
                <td width="2" class="e0" id="c67"><input class="s0" size="1"  name="scv30f78"
                                               value="3" id="f67"></td>
                <td width="2" class="c0" id="c77"><input class="s0" size="1"  name="scv30f88"
                                               value="7" id="f77"></td>
                <td width="2" class="c0" id="c87"><input class="s0" size="1"  name="scv30f98"
                                               value="2" id="f87"></td>
            </tr>
            <tr>
                <td width="2" class="i0" id="c08"><input class="d0" size="1"  name="cv30f19" maxlength="1"
                                               id="f08"></td>
                <td width="2" class="h0" id="c18"><input class="d0" size="1"  name="cv30f29" maxlength="1"
                                               id="f18"></td>
                <td width="2" class="h0" id="c28"><input class="s0" size="1"  name="scv30f39"
                                               value="3" id="f28"></td>
                <td width="2" class="i0" id="c38"><input class="d0" size="1"  name="cv30f49" maxlength="1"
                                               id="f38"></td>
                <td width="2" class="h0" id="c48"><input class="s0" size="1"  name="scv30f59"
                                               value="6" id="f48"></td>
                <td width="2" class="h0" id="c58"><input class="s0" size="1"  name="scv30f69"
                                               value="7" id="f58"></td>
                <td width="2" class="i0" id="c68"><input class="d0" size="1"  name="cv30f79" maxlength="1"
                                               id="f68"></td>
                <td width="2" class="h0" id="c78"><input class="d0" size="1"  name="cv30f89" maxlength="1"
                                               id="f78"></td>
                <td width="2" class="h0" id="c88"><input class="d0" size="1"  name="cv30f99" maxlength="1"
                                               id="f88"></td>
            </tr>
            </tbody>
        </table>
      </div>

      <div style="  display: table; margin: 0 auto;">
        <button phx-click="solve">Solve!</button>
      </div>
    </div>
    """
  end
end
