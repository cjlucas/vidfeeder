defmodule YouTube.Paginator do
  def paginate(fun), do: paginate(fun, nil, [])

  def paginate(fun, next_page_token, acc) do
    {:ok, resp} = fun.(next_page_token)

    acc = [resp | acc]

    case resp.nextPageToken do
      nil ->
        acc |> List.flatten() |> Enum.reverse()

      token ->
        paginate(fun, token, acc)
    end
  end
end
