defmodule Derivata do

  @type literal() :: {:num, number()} | {:var, atom()}

  @type expr() :: {:add, expr(), expr()} | {:sub, expr(), expr()} | {:mul, expr(), expr()} | {:div, expr(), expr()} | literal()

  def deriv({:num, _}, _), do: {:num, 0}
  def deriv({:var, x}, x), do: {:num, 1}
  def deriv({:var, _}, _), do: {:num, 0}
  def deriv({:add, u, v}, x), do: {:add, deriv(u, x), deriv(v, x)}
  def deriv({:sub, u, v}, x), do: {:sub, deriv(u, x), deriv(v, x)}
  def deriv({:mul, u, v}, x), do: {:add, {:mul, u, deriv(v, x)}, {:mul, v, deriv(u, x)}}
  def deriv({:div, u, v}, x), do: {:div, {:sub, {:mul, v, deriv(u, x)}, {:mul, u, deriv(v, x)}}, {:pow, v, {:num, 2}}}
  def deriv({:pow, u, v}, x), do: {:mul, {:pow, u, {:sub, v, {:num, 1}}}, {:add, {:mul, v, deriv(u, x)}, {:mul, {:mul, u, {:pow, v, {:sub, v, {:num, 1}}}}, deriv(v, x)}}}
  def deriv({:exp, u}, x), do: {:mul, {:exp, u}, deriv(u, x)}
  def deriv({:log, u}, x), do: {:div, deriv(u, x), u}
  def deriv({:ln, u}, x), do: {:div, deriv(u, x), u}
  def deriv({:sin, u}, x), do: {:mul, {:cos, u}, deriv(u, x)}
  def deriv({:cos, u}, x), do: {:mul, {:num, -1}, {:mul, {:sin, u}, deriv(u, x)}}
  def deriv({:tan, u}, x), do: {:div, deriv(u, x), {:pow, {:cos, u}, {:num, 2}}}
  def deriv({:csc, u}, x), do: {:mul, {:num, -1}, {:mul, {:cot, u}, {:csc, u}}}
  def deriv({:pow, {:var, x}, n}, x), do: {:mul, {:pow, {:var, x}, n}, {:add, {:mul, {:ln, {:var, x}}, deriv(n, x)}, {:mul, {:div, n, {:var, x}}, deriv({:var, x}, x)}}}
  def deriv({:sqrt, u}, x), do: {:div, deriv(u, x), {:mul, {:num, 2}, {:sqrt, u}}}


  def simplify({:num, x}), do: Integer.to_string(x)
  def simplify({:var, x}), do: Atom.to_string(x)
  def simplify({:mul, u, {:num, 0}}), do: "0"
  def simplify({:mul, {:num, 0}, v}), do: "0"
  def simplify({:mul, u, {:num, 1}}), do: simplify(u)
  def simplify({:mul, {:num, 1}, v}), do: simplify(v)
  def simplify({:add, u, {:num, 0}}), do: simplify(u)
  def simplify({:add, {:num, 0}, v}), do: simplify(v)
  def simplify({:sub, u, {:num, 0}}), do: simplify(u)
  def simplify({:sub, {:num, 0}, v}), do: "-(" <> simplify(v) <> ")"
  def simplify({:mul, {:num, x}, v}), do: Integer.to_string(x) <> " * " <> simplify(v)
  def simplify({:mul, u, {:num, x}}), do: simplify(u) <> " * " <> Integer.to_string(x)
  def simplify({:add, u, v}), do: simplify(u) <> " + " <> simplify(v)
  def simplify({:sub, u, v}), do: simplify(u) <> " - " <> simplify(v)
  def simplify({:mul, u, v}), do: "(" <> simplify(u) <> " * " <> simplify(v) <> ")"
  def simplify({:div, u, v}), do: "(" <> simplify(u) <> " / " <> simplify(v) <> ")"
  def simplify({:pow, u, v}), do: "(" <> simplify(u) <> " ^ " <> simplify(v) <> ")"
  def simplify({:exp, u}), do: "e ^ " <> simplify(u)
  def simplify({:log, u}), do: "ln(" <> simplify(u) <> ")"
  def simplify({:sin, u}), do: "sin(" <> simplify(u) <> ")"
  def simplify({:cos, u}), do: "cos(" <> simplify(u) <> ")"
  def simplify({:tan, u}), do: "tan(" <> simplify(u) <> ")"
  def simplify({:add, {:mul, u, {:num, 0}}, v}), do: simplify(v)
  def simplify({:add, u, {:mul, v, {:num, 0}}}), do: simplify(u)



end
