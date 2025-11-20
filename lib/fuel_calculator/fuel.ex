defmodule FuelCalculator.Fuel do
  @moduledoc """
  Module responsible for all calculations with rocket fuel.
  """

  @gravity %{
    earth: 9.807,
    moon: 1.62,
    mars: 3.711
  }

  @doc """
  Calculates total amount of fuel (in liters) needed by rocket to make the trip.

    ## Input params
      * ship_mass - dry flight ship mass expressed in kilograms.
      * directives - array of two elemet tuples. First element of tuple is a `:land` or `:launch` directive as an atom
        and second one is target planet name as an atom (one of :earth, :moon, :mars)

    ## Examples
      iex> ship_mass = 28801
      iex> directives = [{:land, :earth}]
      iex> Fuel.calculate(ship_mass, directives)
      13447
  """
  @spec calculate(integer(), [{atom(), number()}]) :: integer()
  def calculate(ship_mass, directives) do
    with {:ok, "params are valid"} <- ParamsValidator.validate_params(ship_mass, directives) do
      calculate_fuel(ship_mass, directives)
    else
      error -> error
    end
  end

  defp calculate_fuel(ship_mass, directives) do
    directives
    |> Enum.reverse()
    |> Enum.reduce(0, fn directive, fuel_acc ->
      fuel_for_directive =
        directive
        |> calculate_fuel_for_directive(ship_mass + fuel_acc)
        |> maybe_add_more_fuel(directive)

      fuel_acc + fuel_for_directive
    end)
  end

  defp calculate_fuel_for_directive({:land, planet}, mass) do
    gravity = @gravity[planet]
    (mass * gravity * 0.033 - 42) |> floor()
  end

  defp calculate_fuel_for_directive({:launch, planet}, mass) do
    gravity = @gravity[planet]
    (mass * gravity * 0.042 - 33) |> floor()
  end

  defp maybe_add_more_fuel(mass, directive) when mass > 0 do
    additional_fuel =
      directive
      |> calculate_fuel_for_directive(mass)
      |> maybe_add_more_fuel(directive)

    mass + additional_fuel
  end

  defp maybe_add_more_fuel(_mass, _directive), do: 0
end
