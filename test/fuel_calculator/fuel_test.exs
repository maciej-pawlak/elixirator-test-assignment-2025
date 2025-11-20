defmodule FuelTest do
  use ExUnit.Case
  alias FuelCalculator.Fuel
  doctest Fuel

  describe "calculate/2 -" do
    test "returns amount of fuel needed to land on Earth" do
      ship_mass = 28801
      route = [{:land, :earth}]

      assert 13447 == Fuel.calculate(ship_mass, route)
    end

    test "returns amount of fuel needed for Apollo 11 mission" do
      ship_mass = 28801

      route = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :earth}
      ]

      assert 51898 == Fuel.calculate(ship_mass, route)
    end

    test "returns amount of fuel needed for mission to Mars" do
      ship_mass = 14606

      route = [
        {:launch, :earth},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert 33388 == Fuel.calculate(ship_mass, route)
    end

    test "returns amount of fuel needed for passenger ship mission" do
      ship_mass = 75432

      route = [
        {:launch, :earth},
        {:land, :moon},
        {:launch, :moon},
        {:land, :mars},
        {:launch, :mars},
        {:land, :earth}
      ]

      assert 212_161 == Fuel.calculate(ship_mass, route)
    end

    test "returns error when flight ship mass param is not valid" do
      ship_mass = "ooops!"

      route = [{:launch, :earth}]

      assert {:error, "flight ship mass must be a number"} ==
               Fuel.calculate(ship_mass, route)
    end

    test "returns error when directives are not valid" do
      ship_mass = 1000

      assert {:error, "no directives were given"} == Fuel.calculate(ship_mass, [])

      assert {:error, "invalid directive: {land_on_the_tree, moon}"} ==
               Fuel.calculate(ship_mass, [{:land_on_the_tree, :moon}])

      assert {:error, "invalid directive: {land, moon}"} ==
               Fuel.calculate(ship_mass, [{"land", :moon}])

      assert {:error, "invalid directive: {land, oops}"} ==
               Fuel.calculate(ship_mass, [{:land, "oops"}])
    end
  end
end
