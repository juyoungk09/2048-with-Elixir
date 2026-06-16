defmodule Game2048 do
  @board_size 4

  def start_board do
    empty = List.duplicate(0, @board_size) |> List.duplicate(@board_size)

    empty
    |> add_random_tile()
    |> add_random_tile()
  end

  def print_board(board) do
    IO.puts("\n=== 2048 Game ===")
    Enum.each(board, fn row ->
      row_str =
        Enum.map(row, fn
        0 -> IO.ANSI.light_black_background() <> "    " <> IO.ANSI.reset()

          n -> color_tile_background(n)

        end)
        |> Enum.join("")
      IO.puts(row_str)
    end)
  end

  defp color_tile_background(n) do
  bg_color =
    cond do
      n == 2 -> IO.ANSI.green_background()
      n == 4 -> IO.ANSI.yellow_background()
      n == 8 -> IO.ANSI.red_background()
      n == 16 -> IO.ANSI.magenta_background()
      n == 32 -> IO.ANSI.cyan_background()
      n == 64 -> IO.ANSI.blue_background()
      n == 128 -> IO.ANSI.light_green_background()
      n == 256 -> IO.ANSI.light_yellow_background()
      n == 512 -> IO.ANSI.light_red_background()
      n == 1024 -> IO.ANSI.light_magenta_background()
      n == 2048 -> IO.ANSI.light_cyan_background()
      true -> IO.ANSI.default_background()
    end

  str = Integer.to_string(n) |> String.pad_leading(2) |> String.pad_trailing(4)


  "#{bg_color}#{str}#{IO.ANSI.reset()}"
end

  def move_left(row) do
    row
    |> Enum.filter(&(&1 != 0))
    |> combine_tiles()
    |> pad_right(length(row))
  end

  defp combine_tiles([a, a | rest]), do: [a * 2 | combine_tiles(rest)]

  defp combine_tiles([a | rest]), do: [a | combine_tiles(rest)]

  defp combine_tiles([]), do: []

  defp pad_right(list, size), do: list ++ List.duplicate(0, size - length(list))


  def move_right(row) do
    row
    |> Enum.reverse()
    |> move_left()
    |> Enum.reverse()
  end

  def move_up(board) do
    board
    |> transpose()
    |> Enum.map(&move_left/1)
    |> transpose()
  end

  def move_down(board) do
    board
    |> transpose()
    |> Enum.map(&move_right/1)
    |> transpose()
  end

  def transpose(board) do
    board
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def add_random_tile(board) do
    empties =
      board
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, r} ->
        row
        |> Enum.with_index()
        |> Enum.filter(fn {v, _c} -> v == 0 end)

        |> Enum.map(fn {_v, c} -> {r, c} end)

      end)

    if empties == [] do
      board
    else
      {r, c} = Enum.random(empties)
      new_val = if :rand.uniform() < 0.9, do: 2, else: 4

      List.update_at(board, r, fn row -> List.replace_at(row, c, new_val) end)

    end
  end

  def game_over?(board) do
    not Enum.any?([:left, :right, :up, :down], fn dir ->
      moved = move(board, dir)
      moved != board
    end)
  end

  def move(board, :left), do: Enum.map(board, &move_left/1)

  def move(board, :right), do: Enum.map(board, &move_right/1)

  def move(board, :up), do: move_up(board)

  def move(board, :down), do: move_down(board)

  def play do
    board = start_board()
    game_loop(board)
  end

  defp game_loop(board) do
    print_board(board)

    if game_over?(board) do
        IO.puts(IO.ANSI.red() <> "Game Over!" <> IO.ANSI.reset())

    else
        IO.write("Move (w/a/s/d, q to quit): ")
        input = String.trim(IO.gets("") || "")

        new_board =
        case input do
            "w" -> move(board, :up)
            "a" -> move(board, :left)
            "s" -> move(board, :down)
            "d" -> move(board, :right)
            "q" ->
            IO.puts("Quit Game.")
            System.halt(0)
            _ ->
            IO.puts("Invalid input!")
            board
        end

        if new_board != board do
        new_board = add_random_tile(new_board)

        game_loop(new_board)
        else
        IO.puts("No tiles moved!")
        game_loop(board)
        end
    end
  end
end

# Erlang과 Elixir는 Java와 Kotlin 같은 관계
Game2048.play()
