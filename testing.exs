defmodule EnvList do
  def new do
    nil
  end
  def add(nil, key, value) do
    {:node, key, value, nil, nil}
  end
  def add({:node, node_key, node_value, left, right}, key, value) when key < node_key do
    {:node, node_key, node_value, add(left, key, value), right}
  end
  def add({:node, node_key, node_value, left, right}, key, value) when key >= node_key do
    {:node, node_key, node_value, left, add(right, key, value)}
  end
  def lookup(nil, _key), do: nil
  def lookup({:node, node_key, node_value, _, _}, key) when key == node_key do
    node_value
  end
  def lookup({:node, node_key, _, left, _}, key) when key < node_key do
    lookup(left, key)
  end
  def lookup({:node, node_key, _, _, right}, key) when key > node_key do
    lookup(right, key)
  end
    def remove(nil, _), do: nil
    def remove({:node, key, _, nil, right}, key), do: right
    def remove({:node, key, _, left, nil}, key), do: left
    def remove({:node, key, _, left, right}, key) do
      {new_key, new_value} = leftmost(right)
      {:node, new_key, new_value, left, remove(right, new_key)}
    end
    def remove({:node, k, v, left, right}, key) when key < k do
      {:node, k, v, remove(left, key), right}
    end
    def remove({:node, k, v, left, right}, key) do
      {:node, k, v, left, remove(right, key)}
    end
    def leftmost({:node, key, value, nil, _}), do: {key, value}
    def leftmost({:node, _, _, left, _}), do: leftmost(left)




    defmodule List do
      def new(), do: []

      def add(map, key, value) do
        map
        |> Enum.reject(fn {k, _v} -> k == key end)
        |> Enum.concat([{key, value}])
      end

      def lookup(map, key) do
        case Enum.find(map, fn {k, _v} -> k == key end) do
          nil -> nil
          {k, v} -> {k, v}
        end
      end

      def remove(map, key) do
        Enum.reject(map, fn {k, _v} -> k == key end)
      end

    

      def bench(i, n) do
        seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)
        list = Enum.reduce(seq,  List.new(), fn(e, list) -> List.add(list, e, :foo) end)
        seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)
        {add, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> List.add(list, e, :foo) end) end)
        {lookup, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> List.lookup(list, e) end) end)
        {remove, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> List.remove(list, e)end) end)
        {i, add, lookup, remove, add + lookup + remove}
      end

      def bench(n) do
        ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]
        :io.format("# benchmark with ~w operations, time per operation in us\n", [n])
        :io.format("~6.s~12.s~12.s~12.s~12.s\n", ["n", "add", "lookup", "remove", "total"])
        Enum.each(ls, fn (i) ->
          {i, tla, tll, tlr, ttl} = bench(i, n)
          :io.format("~6.w~12.2f~12.2f~12.2f~12.2f\n", [i, tla/n, tll/n, tlr/n, ttl/n]) end)
      end
    end





    def bench(i, n) do
      seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)
      list = Enum.reduce(seq,  EnvList.new(), fn(e, list) -> EnvList.add(list, e, :foo) end)
      seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)
      {add, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> EnvList.add(list, e, :foo) end) end)
      {lookup, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> EnvList.lookup(list, e) end) end)
      {remove, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> EnvList.remove(list, e)end) end)
      {i, add, lookup, remove, add + lookup + remove}
    end

    def bench(n) do
      ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]
      :io.format("# benchmark with ~w operations, time per operation in us\n", [n])
      :io.format("~6.s~12.s~12.s~12.s~12.s\n", ["n", "add", "lookup", "remove", "total"])
      Enum.each(ls, fn (i) ->
        {i, tla, tll, tlr, ttl} = bench(i, n)
        :io.format("~6.w~12.2f~12.2f~12.2f~12.2f\n", [i, tla/n, tll/n, tlr/n, ttl/n]) end)
    end


    defmodule EnvMap do
      def new(), do: %{}

      def add(map, key, value), do: Map.put(map, key, value)

      def lookup(map, key) do
        case Map.get(map, key) do
          nil -> nil
          value -> {key, value}
        end
      end

      def remove(map, key), do: Map.delete(map, key)

      def bench(i, n) do
        seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)
        map = Enum.reduce(seq, new(), fn(e, map) -> add(map, e, :foo) end)
        seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)
        {add, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> add(map, e, :foo) end) end)
        {lookup, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> lookup(map, e) end) end)
        {remove, _} = :timer.tc(fn() -> Enum.each(seq, fn(e) -> remove(map, e) end) end)
        {i, add, lookup, remove, add + lookup + remove}
      end

      def bench(n) do
        ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]
        :io.format("# benchmark with ~w operations, time per operation in us\n", [n])
        :io.format("~6.s~12.s~12.s~12.s~12.s\n", ["n", "add", "lookup", "remove", "total"])
        Enum.each(ls, fn (i) ->
          {i, tla, tll, tlr, ttl} = bench(i, n)
          :io.format("~6.w~12.2f~12.2f~12.2f~12.2f\n", [i, tla/n, tll/n, tlr/n, ttl/n]) end)
      end
    end

  end
