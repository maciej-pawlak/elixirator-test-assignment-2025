defmodule FuelCalculatorWeb.FuelLive do
  use FuelCalculatorWeb, :live_view

  alias FuelCalculator.Fuel

  @impl true
  def mount(_params, _session, socket) do
    steps = [
      %{id: generate_id(), directive: :launch, planet: :earth}
    ]

    socket =
      socket
      |> assign(:steps, steps)
      |> assign(:mass, "")
      |> assign(:errors, %{})
      |> assign(:fuel_needed, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("add_step", _params, socket) do
    new_step = next_step(socket.assigns.steps)

    {:noreply,
     socket
     |> update(:steps, fn steps -> steps ++ [new_step] end)
     |> compute()}
  end

  @impl true
  def handle_event("remove_step", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> update(:steps, fn steps -> Enum.reject(steps, &(&1.id == id)) end)
     |> compute()}
  end

  @impl true
  def handle_event("update", %{"mass" => mass, "steps" => steps_params}, socket) do
    steps =
      Enum.map(socket.assigns.steps, fn step ->
        params = Map.fetch!(steps_params, step.id)

        %{
          step
          | directive: params["directive"],
            planet: params["planet"]
        }
      end)

    {:noreply,
     socket
     |> assign(:mass, mass)
     |> assign(:steps, steps)
     |> compute()}
  end

  defp compute(socket) do
    {errors, result} =
      case parse_mass(socket.assigns.mass) do
        {:ok, mass} ->
          steps =
            socket.assigns.steps
            |> Enum.map(fn step ->
              {String.to_atom(step.directive), String.to_atom(step.planet)}
            end)

          total_fuel = Fuel.calculate(mass, steps)
          {%{}, total_fuel}

        {:error, message} ->
          {%{mass: message}, nil}
      end

    socket
    |> assign(:errors, errors)
    |> assign(:fuel_needed, result)
  end

  defp next_step(steps) do
    case List.last(steps) do
      %{directive: "land", planet: planet} ->
        %{id: generate_id(), directive: "launch", planet: planet}

      %{directive: "launch", planet: _planet} ->
        %{id: generate_id(), directive: "land", planet: "earth"}

      _ ->
        %{id: generate_id(), directive: "launch", planet: "earth"}
    end
  end

  defp parse_mass(""), do: {:error, "Mass is required"}

  defp parse_mass(mass_string) do
    case Integer.parse(mass_string) do
      {value, ""} when value > 0 ->
        {:ok, value}

      {value, ""} when value <= 0 ->
        {:error, "Mass must be a positive integer"}

      _ ->
        {:error, "Mass must be a valid integer"}
    end
  end

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
