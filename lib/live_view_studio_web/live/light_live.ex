defmodule LiveViewStudioWeb.LightLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :board, ["", "", "", "", "", "", "", "", ""])
    socket = assign(socket, :player, "X")
    socket = assign(socket, :winner, "")
    socket = assign(socket, :turn, "X")
    socket = assign(socket, :message, "")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""

      <div class="flex flex-col items-center justify-center">
          <div class="grid grid-cols-3 gap-[0.5px] bg-black" >
              <%= for i <- 0..8 do %>
                <button
                  class="bg-white p-5 aspect-square min-w-[100px]"
                  phx-click="click"
                  phx-value-index={i}
                  disabled={@winner != "" || @board |> Enum.at(i) != ""}
                >
                  <%= @board |> Enum.at(i) |> String.upcase %>
                </button>
              <% end %>
          </div>
          <div class="mt-5">
            <%= if @winner != "" do %>
              <div class="text-2xl font-bold text-center">
                <%= @winner %> wins!
              </div>
              <div class="text-center">
                <button
                  class="bg-white p-5"
                  phx-click="start_over"
                >
                  Start Over
                </button>
              </div>
            <% end %>
          </div>
      </div>
  """
  end

  def handle_event("start_over", _params, socket) do
    socket = assign(socket, :board, ["", "", "", "", "", "", "", "", ""])
    socket = assign(socket, :player, "X")
    socket = assign(socket, :winner, "")
    socket = assign(socket, :turn, "X")
    socket = assign(socket, :message, "")
    {:noreply, socket}
  end

  def handle_event("click", %{"index" => index}, socket) do
    turn = socket.assigns.turn
    nextTurn = if turn == "X" do "O" else "X" end
    IO.puts("turn: #{turn}")

    {intIndex,_} = Integer.parse(index)
    IO.puts("clicked on cube #{intIndex}")
    socket = update(socket, :board,&(&1 |> Enum.with_index() |> Enum.map(fn {v,i} -> if i == intIndex do turn else v end end)))

    IO.puts("switching turn to #{nextTurn}")
    socket = assign(socket, :turn, nextTurn)

    winning_combinations = [
      [0,1,2],
      [3,4,5],
      [6,7,8],
      [0,3,6],
      [1,4,7],
      [2,5,8],
      [0,4,8],
      [2,4,6]
    ]

    found_combinations = Enum.find(winning_combinations, fn [a,b,c] -> socket.assigns.board |> Enum.at(a) != "" && socket.assigns.board |> Enum.at(a) == socket.assigns.board |> Enum.at(b) && socket.assigns.board |> Enum.at(b) == socket.assigns.board |> Enum.at(c) end)
    winner = if found_combinations != nil do socket.assigns.board |> Enum.at(Enum.at(found_combinations, 0)) else "" end
    IO.puts("winner: #{winner}")
    socket = assign(socket, :winner, winner)
    {:noreply, socket}
  end
end
