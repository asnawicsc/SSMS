defmodule School do
  @moduledoc """
  School keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require IEx

  def assign_rank(list) do
    # list = ["a", "b", "c", "c", "d", "e", "f", "g"]

    Stream.unfold({nil, 1, 0, hd(list), 0}, fn
      nil -> nil
      n -> {n, give_index(n, list)}
    end)
    |> Enum.to_list()
  end

  def give_index(n, list) do
    if List.last(list) == elem(n, 3) do
      nil
    else
      if elem(n, 0) != nil do
        IO.inspect(elem(n, 0))
        IO.puts("total mark prev")
        IO.inspect(elem(n, 0).total_mark)
      end

      IO.puts("total mark next")
      IO.inspect(elem(n, 3).total_mark)

      prev =
        if elem(n, 0) == nil do
          %{total_mark: nil}
        else
          elem(n, 0)
        end

      if prev.total_mark == elem(n, 3).total_mark do
        # if elem(n, 0) == elem(n, 3) do
        next_val = Enum.fetch!(list, elem(n, 2) + 1)
        {elem(n, 3), elem(n, 1), elem(n, 2) + 1, next_val, 1}
      else
        next_val = Enum.fetch!(list, elem(n, 2) + 1)
        {elem(n, 3), elem(n, 1) + 1 + elem(n, 4), elem(n, 2) + 1, next_val, 0}
      end
    end

    # {cur, index, prev} =
    #   if cur == prev do
    #     index = index
    #     {cur, index, prev}
    #   else
    #     index = index + 1
    #     {cur, index, prev}
    #   end
  end
end
