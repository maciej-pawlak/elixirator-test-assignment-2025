defmodule ParamsValidator do
  @moduledoc """
  Module responsible for validating params given by user.
  """

  @allowed_directives [:land, :launch]
  @allowed_planets [:earth, :moon, :mars]

  @doc """
  Validates if params are valid.
  """
  @spec validate_params(integer(), [{atom(), number()}]) ::
          {:ok, String.t()} | {:error, String.t()}
  def validate_params(ship_mass, directives) do
    with {:ok, "ship mass is valid"} <- validate_ship_mass(ship_mass),
         {:ok, "directives are valid"} <- validate_directives(directives) do
      {:ok, "params are valid"}
    else
      error -> error
    end
  end

  defp validate_ship_mass(ship_mass) when is_number(ship_mass), do: {:ok, "ship mass is valid"}
  defp validate_ship_mass(_ship_mass), do: {:error, "flight ship mass must be a number"}

  defp validate_directives(directives) do
    Enum.reduce_while(directives, {:error, "no directives were given"}, fn {directive, planet},
                                                                           _acc ->
      with true <- directive in @allowed_directives,
           true <- is_atom(planet) and planet in @allowed_planets do
        {:cont, {:ok, "directives are valid"}}
      else
        false -> {:halt, {:error, "invalid directive: {#{directive}, #{planet}}"}}
      end
    end)
  end
end
