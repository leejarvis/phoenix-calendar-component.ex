Phoenix Calendar Component
==========================

This repo features a very basic drop-in Calendar component for Phoenix LiveView.

You can use it like this:

```elixir
<.live_component id="calendar" module={AppWeb.CalendarComponent} />
```

You can optionally send the following attributes:

- `selected_date` the date that's selected, defaults to today
- `month_in_view` the date for the month in view, defaults to today's month
- `highlighted_dates` a list of dates that will be highlighted in the calendar

The component will fire the following events to the parent LiveView:

- `{:date_selected, %Date{}}` - when a date is selected
- `{:month_changed, %Date{}}` - when a month is changed

You can handle these in `handle_info`:

```elixir
def handle_info({:month_changed, date}, socket) do
  {:noreply, assign(socket, events: fetch_events_for_month(date))}
end
```
