# FuelCalculator

A web application for calculating fuel requirements for space missions, built with Phoenix Framework using LiveView.

## Requirements

Before you begin, make sure you have installed:

- **Erlang** 28.1.1
- **Elixir** 1.19.3 (with OTP 28)
- **Node.js** (required for asset build tools)

### Installing Erlang and Elixir

We recommend using a version manager tool such as:

- **asdf** (https://asdf-vm.com/)
- **kiex** (https://github.com/taylor/kiex)

If you're using `asdf`, you can install the required versions:

```bash
asdf install erlang 28.1.1
asdf install elixir 1.19.3-otp-28
```

## Project Setup

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/maciej-pawlak/elixirator-test-assignment-2025
   cd fuel_calculator
   ```

2. **Install dependencies and set up the project**:
   ```bash
   mix setup
   ```

   This command will automatically:
   - Fetch all Elixir dependencies (`mix deps.get`)
   - Install asset build tools (Tailwind CSS and esbuild)
   - Compile the project and build assets

## Running the Application

### Development Mode

To start the Phoenix server in development mode:

```bash
mix phx.server
```

Or with an interactive IEx (Elixir Interactive Shell) console:

```bash
iex -S mix phx.server
```

The server will start on port **4000** (default).

### Access via Web Browser

After starting the server, open your browser and navigate to:

**http://localhost:4000**

The application is available at the root path `/`.

## Using the Application

The application allows you to:

- Enter spacecraft mass
- Add space mission steps (launch from planet, land on planet)
- Automatically calculate required fuel for the entire mission
- Validate input data

## Additional Information

### Tests

To run tests:

```bash
mix test
```