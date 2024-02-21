defmodule Philosopher do


  defmodule Chopstick do
    def start do
      spawn_link(fn -> available() end)
    end

    defp available do
      receive do
        {:request, from} ->
          send(from, :granted)
          gone()
        :quit ->
          :ok
      end
    end

    defp gone do
      receive do
        :return ->
          available()
        :quit ->
          :ok
      end
    end

    def request(stick, timeout) do
      send(stick, {:request, self()})
      receive do
        :granted -> :ok
      after
        timeout -> :no
      end
    end

    def return_stick(stick) do
      send(stick, :return)
      :ok
    end

    def terminate(stick) do
      send(stick, :quit)
      :ok
    end
  end

  def start(hunger, strength, right, left, name, ctrl) do
    spawn_link(fn -> life_cycle(hunger, strength, right, left, name, ctrl) end)
  end

  defp life_cycle(0, _strength, _right, _left, name, ctrl) do
    IO.puts("#{name} has finished their meal.")
    send(ctrl, {:done, name})
  end

  defp life_cycle(_hunger, 0, _right, _left, name, ctrl) do
    IO.puts("#{name} has died of starvation.")
    send(ctrl, {:done, name})
  end

  defp life_cycle(hunger, strength, right, left, name, ctrl) do
    dreaming()
    if acquire_chopsticks(strength, right, left, name) do
      eating(hunger, strength, right, left, name, ctrl)
    else
      IO.puts("#{name} could not acquire chopsticks and is trying again.")
      life_cycle(hunger, strength - 1, right, left, name, ctrl)
    end
  end

  defp dreaming do
    sleep(:rand.uniform(1000))
  end

  defp acquire_chopsticks(strength, right, left, name) do
    case Chopstick.request(right, 1000) do
      :ok ->
        IO.puts("#{name} received right chopstick.")
        case Chopstick.request(left, 1000) do
          :ok ->
            IO.puts("#{name} received left chopstick.")
            true
          :no ->
            Chopstick.return_stick(right)
            IO.puts("#{name} failed to acquire left chopstick.")
            false
        end
      :no ->
        IO.puts("#{name} failed to acquire right chopstick.")
        false
    end
  end

  defp eating(hunger, strength, right, left, name, ctrl) do
    IO.puts("#{name} is eating.")
    sleep(:rand.uniform(10000))
    Chopstick.return_stick(right)
    Chopstick.return_stick(left)
    IO.puts("#{name} finished eating.")
    life_cycle(hunger - 1, strength, right, left, name, ctrl)  # Corrected number of arguments
  end

  defp sleep(0), do: :ok
  defp sleep(t), do: :timer.sleep(:rand.uniform(t))
end


defmodule Dinner do
  def start(), do: spawn(fn -> init() end)

  def init() do
    start_time = :os.system_time(:millisecond)
    c1 = Philosopher.Chopstick.start()
    c2 = Philosopher.Chopstick.start()
    c3 = Philosopher.Chopstick.start()
    c4 = Philosopher.Chopstick.start()
    c5 = Philosopher.Chopstick.start()

    ctrl = self()

    initial_strength = 15  # Define an initial strength for each philosopher

    Philosopher.start(5, initial_strength, c1, c2, :arendt, ctrl)
    Philosopher.start(5, initial_strength, c2, c3, :hypatia, ctrl)
    Philosopher.start(5, initial_strength, c3, c4, :simone, ctrl)
    Philosopher.start(5, initial_strength, c4, c5, :elisabeth, ctrl)
    Philosopher.start(5, initial_strength, c5, c1, :ayn, ctrl)

    # Pass the caller's PID (ctrl) to the wait function
    wait(5, [c1, c2, c3, c4, c5], start_time, ctrl)
  end


  def wait(0, chopsticks, start_time, caller) do
    end_time = :os.system_time(:millisecond)
    duration = end_time - start_time

    IO.puts("All philosophers done. Duration: #{duration} ms.")

    # Terminate chopstick processes
    Enum.each(chopsticks, &Philosopher.Chopstick.terminate/1)

    # Send the duration back to the calling process
    send(caller, {:dinner_duration, duration})
  end

  def wait(n, chopsticks, start_time, caller) do
    receive do
      {:done, _philosopher_name} ->
        wait(n - 1, chopsticks, start_time, caller)
      :abort ->
        Process.exit(self(), :kill)
    end
  end
end
