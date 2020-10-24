alias VidFeeder.{Repo, YoutubeDlSource}

source = Repo.all(YoutubeDlSource) |> List.last() |> Repo.preload(:items)

IO.inspect(source.items)
