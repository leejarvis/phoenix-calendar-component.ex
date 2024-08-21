defmodule AppWeb.CalendarComponent do
  use AppWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative">
      <.action class="-left-1.5" target={@myself} click="previous-month">&larr;</.action>
      <.action class="-right-1.5" target={@myself} click="next-month">&rarr;</.action>
      <.action :if={@selected_date != Date.utc_today()} click="today" target={@myself} class="left-8">
        Today
      </.action>
      <section class="text-center">
        <h2 class="text-sm font-semibold text-gray-900">
          <%= Calendar.strftime(@month_in_view, "%B") %>
        </h2>
        <div class="mt-6 grid grid-cols-7 text-xs leading-6 text-gray-500">
          <div :for={d <- ~w(M T W T F S S)}><%= d %></div>
        </div>
        <div class="isolate mt-2 grid grid-cols-7 gap-px bg-gray-200 text-sm shadow ring-1 ring-gray-200">
          <button
            :for={day <- month_days(@month_in_view)}
            phx-click="set-date"
            phx-target={@myself}
            phx-value-date={day}
            class={day_class(day, @selected_date, @month_in_view)}
          >
            <div class="mx-auto flex h-10 w-10 items-center justify-center"><%= day.day %></div>
            <span
              :if={day in @highlighted_dates}
              class="absolute bottom-2 rounded-full w-1 h-1 bg-blue-500/50"
            >
            </span>
          </button>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:selected_date, Date.utc_today())
      |> assign(:month_in_view, Date.utc_today())
      |> assign(:highlighted_dates, [])

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("set-date", %{"date" => date}, socket) do
    {:noreply, set_date(socket, date)}
  end

  @impl true
  def handle_event("today", _, socket) do
    {:noreply, set_date(socket, Date.utc_today())}
  end

  @impl true
  def handle_event("previous-month", _, socket) do
    {:noreply, shift_month(socket, -1)}
  end

  @impl true
  def handle_event("next-month", _, socket) do
    {:noreply, shift_month(socket, 1)}
  end

  defp set_date(socket, date) when is_binary(date) do
    date =
      case Date.from_iso8601(date) do
        {:ok, date} -> date
        _ -> Date.utc_today()
      end

    set_date(socket, date)
  end

  defp set_date(socket, date) do
    send(self(), {:date_selected, date})

    socket
    |> assign(selected_date: date)
    |> assign(month_in_view: date)
  end

  defp shift_month(socket, direction) do
    month_in_view = socket.assigns.month_in_view

    boundary =
      if direction > 0,
        do: Date.end_of_month(month_in_view),
        else: Date.beginning_of_month(month_in_view)

    shifted_month = Date.add(boundary, direction)

    self() |> send({:month_changed, shifted_month})
    assign(socket, month_in_view: shifted_month)
  end

  defp month_days(date) do
    first_day = Date.beginning_of_month(date) |> Date.beginning_of_week(:monday)
    last_day = Date.end_of_month(date) |> Date.end_of_week(:monday)

    Date.range(first_day, last_day)
  end

  defp action(assigns) do
    ~H"""
    <button
      type="button"
      phx-click={@click}
      phx-target={@target}
      class={[
        "absolute top-0 flex items-center justify-center p-1.5 text-gray-400 hover:text-gray-500",
        @class
      ]}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp day_class(day, selected_date, month_in_view) do
    classes = ["relative py-1.5 focus:z-10"]

    cond do
      # selected date
      day == selected_date ->
        ["bg-blue-200/80 font-semibold text-gray-500 hover:bg-blue-200" | classes]

      # today
      day == Date.utc_today() ->
        ["bg-white font-bold text-black text-gray-500 hover:bg-gray-100" | classes]

      # inside current month
      day.month == month_in_view.month ->
        ["bg-white text-gray-900 hover:bg-gray-100" | classes]

      # outside current month
      true ->
        ["bg-gray-50 text-gray-400 hover:bg-gray-100" | classes]
    end
  end
end
