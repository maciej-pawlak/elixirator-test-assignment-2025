defmodule FuelCalculatorWeb.FuelLiveTest do
  use FuelCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "initial render" do
    test "shows title, mass field and info alert", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Interplanetary Fuel Calculator"
      assert html =~ "Spacecraft mass"
      assert html =~ "Enter valid mass and configure your flight path to see the required fuel."
      assert html =~ "alert-info"
    end
  end

  describe "mass validation" do
    test "shows error for empty mass", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", %{"mass" => ""})
        |> render_change()

      assert html =~ "Mass is required"
      assert html =~ "alert-info"
    end

    test "shows error for negative mass", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", %{"mass" => "-10"})
        |> render_change()

      assert html =~ "Mass must be a positive integer"
      assert html =~ "alert-info"
    end
  end

  describe "fuel calculation" do
    test "entering valid mass triggers fuel calculation", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      html =
        view
        |> form("form", %{"mass" => "28801"})
        |> render_change()

      assert html =~ "alert-success"
      assert html =~ "Total required fuel"
      assert html =~ "19772"
    end
  end

  describe "full mission example" do
    test "calculates correct fuel for example mission", %{conn: conn} do
      # Load the LiveView for the fuel calculator.
      {:ok, view, _html} = live(conn, ~p"/")

      # This mission requires 6 steps in total.
      # The LiveView starts with exactly 1 step, so we add 5 more.
      view =
        Enum.reduce(1..5, view, fn _, v ->
          render_click(element(v, "button[phx-click=\"add_step\"]"))
          v
        end)

      # Render the updated view after all steps have been added.
      html_after_add = render(view)

      # Extract all step IDs from the DOM.
      # IDs are generated dynamically as Base64 strings, so the test must read them from HTML.
      step_ids =
        html_after_add
        |> Floki.parse_document!()
        |> Floki.find("input[type=\"hidden\"][name$=\"[id]\"]")
        |> Enum.map(fn {"input", attrs, _} ->
          Enum.into(attrs, %{})["value"]
        end)

      # Verify that exactly 6 steps are now present (1 initial + 5 added).
      assert length(step_ids) == 6

      # Define the required flight path in the correct sequence.
      # Each tuple corresponds to {directive, planet}.
      path = [
        {"launch", "earth"},
        {"land", "moon"},
        {"launch", "moon"},
        {"land", "mars"},
        {"launch", "mars"},
        {"land", "earth"}
      ]

      # Construct the "steps" parameter payload expected by the LiveView form.
      # Each step must include id, directive, and planet.
      steps_params =
        Enum.zip(step_ids, path)
        |> Enum.map(fn {id, {directive, planet}} ->
          {id,
           %{
             "id" => id,
             "directive" => directive,
             "planet" => planet
           }}
        end)
        |> Enum.into(%{})

      # Submit the form with:
      # mass = 75432
      # steps = complete six step path defined above
      html_final =
        view
        |> form("form", %{
          "mass" => "75432",
          "steps" => steps_params
        })
        |> render_change()

      # Verify that the LiveView computed the mission fuel correctly.
      assert html_final =~ "alert-success"
      assert html_final =~ "212161"
    end
  end

  describe "steps management" do
    test "add_step adds a new step", %{conn: conn} do
      # Load the LiveView and capture the initial HTML before clicking "Add step".
      {:ok, view, html_before_add} = live(conn, ~p"/")

      # Count how many remove_step buttons exist before adding a new step.
      # There should be exactly 1 on initial render.
      remove_before =
        html_before_add
        |> Floki.parse_document!()
        |> Floki.find("button[phx-click=\"remove_step\"]")
        |> Enum.count()

      # Click the "Add step" button to append a new step to the flight path.
      html_after_add =
        view
        |> element("button[phx-click=\"add_step\"]")
        |> render_click()

      # Count the number of remove_step buttons again after adding the new step.
      # This number should increase by 1.
      remove_after =
        html_after_add
        |> Floki.parse_document!()
        |> Floki.find("button[phx-click=\"remove_step\"]")
        |> Enum.count()

      # Verify that the "Add step" action successfully added a new step
      # by ensuring the count of remove buttons increased exactly by one.
      assert remove_after == remove_before + 1

      # Additionally verify the presence of directive options in the newly rendered form.
      assert html_after_add =~ "Launch"
      assert html_after_add =~ "Land"
    end

    test "remove_step removes the given step", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Add a step, so we have at least 2
      html_after_add =
        view
        |> element("button[phx-click=\"add_step\"]")
        |> render_click()

      # Count how many remove buttons BEFORE removal
      remove_before =
        html_after_add
        |> Floki.parse_document!()
        |> Floki.find("button[phx-click=\"remove_step\"]")
        |> Enum.count()

      assert remove_before == 2

      # Extract all step IDs
      step_ids =
        html_after_add
        |> Floki.parse_document!()
        |> Floki.find("input[type=\"hidden\"][name$=\"[id]\"]")
        |> Enum.map(fn {"input", attrs, _} ->
          Enum.into(attrs, %{})["value"]
        end)

      # Choose the first step to remove (can be any)
      [step_to_remove | _] = step_ids

      # Now actually click the remove button for this step
      html_after_remove =
        view
        |> element("button[phx-click=\"remove_step\"][phx-value-id=\"#{step_to_remove}\"]")
        |> render_click()

      # Count remove buttons AFTER removal
      remove_after =
        html_after_remove
        |> Floki.parse_document!()
        |> Floki.find("button[phx-click=\"remove_step\"]")
        |> Enum.count()

      # Ensure removal decreased step count
      # Ensure that clicking "Remove step" decreases the number of remove buttons by one,
      # confirming that the selected step was successfully removed.
      assert remove_after == remove_before - 1
    end
  end
end
