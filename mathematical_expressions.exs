defmodule Environment do
  def new_env(bindings) do
    Map.new(bindings)
  end

  def lookup(env, var) do
    Map.get(env, var)
  end
end

defmodule Evaluator do
  require Environment

  @type literal() :: {:num, integer()} | {:var, atom()} | {:q, integer(), integer()}
  @type expr() ::
          {:add, expr(), expr()}
          | {:sub, expr(), expr()}
          | {:mul, expr(), expr()}
          | {:divide, expr(), expr()}
          | literal()

  def eval({:num, n}, _env), do: {:num, n}
  def eval({:var, v}, env), do: Environment.lookup(env, v)
  def eval({:q, n, m}, _env), do: reduce_rational({:q, n, m})

  def eval({:add, e1, e2}, env) do
    add(eval(e1, env), eval(e2, env))
  end

  def eval({:sub, e1, e2}, env) do
    sub(eval(e1, env), eval(e2, env))
  end

  def eval({:mul, e1, e2}, env) do
    mul(eval(e1, env), eval(e2, env))
  end

  def eval({:divide, e1, e2}, env) do
    divide(eval(e1, env), eval(e2, env))
  end

  defp add({:num, n1}, {:num, n2}), do: {:num, n1 + n2}
  defp add({:q, n1, m1}, {:q, n2, m2}), do: reduce_rational({:q, n1 * m2 + n2 * m1, m1 * m2})
  defp add({:num, n}, {:q, n2, m}), do: add({:q, n * m, m}, {:q, n2, m})
  defp add({:q, n1, m1}, {:num, n}), do: add({:q, n1, m1}, {:q, n * m1, m1})

  defp sub({:num, n1}, {:num, n2}), do: {:num, n1 - n2}
  defp sub({:q, n1, m1}, {:q, n2, m2}), do: reduce_rational({:q, n1 * m2 - n2 * m1, m1 * m2})
  defp sub({:num, n}, {:q, n2, m}), do: sub({:q, n * m, m}, {:q, n2, m})
  defp sub({:q, n1, m1}, {:num, n}), do: sub({:q, n1, m1}, {:q, n * m1, m1})

  defp mul({:num, n1}, {:num, n2}), do: {:num, n1 * n2}
  defp mul({:q, n1, m1}, {:q, n2, m2}), do: reduce_rational({:q, n1 * n2, m1 * m2})
  defp mul({:num, n}, {:q, n2, m}), do: reduce_rational({:q, n * n2, m})
  defp mul({:q, n1, m1}, {:num, n}), do: reduce_rational({:q, n1 * n, m1})

  defp divide({:num, n1}, {:num, n2}), do: reduce_rational({:q, n1, n2})
  defp divide({:q, n1, m1}, {:q, n2, m2}), do: reduce_rational({:q, n1 * m2, m1 * n2})
  defp divide({:num, n}, {:q, n2, m}), do: reduce_rational({:q, n * m, n2})
  defp divide({:q, n1, m1}, {:num, n}), do: reduce_rational({:q, n1, m1 * n})

  defp reduce_rational({:q, n, m}) do
    gcd = gcd(n, m)
    if gcd == 0 do
      {:q, n, m}
    else
      {:q, div(n, gcd), div(m, gcd)}
    end
  end

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))
end
