defmodule VidFeeder.ImportFeedStore do
  use Agent

  alias VidFeeder.{
    Feed,
    Repo
  }

  def start_link do
    Agent.start_link(fn -> :queue.new end, name: __MODULE__)
  end

  def push(feed) do
    Agent.update(__MODULE__, fn queue -> :queue.in(feed.id, queue) end)
  end

  def pop do
    feed_id = Agent.get_and_update(__MODULE__, fn queue ->
      case :queue.out(queue) do
        {{:value, feed_id}, new_queue} ->
          {feed_id, new_queue}
        {:empty, _} ->
          {nil, queue}
      end
    end)

    case feed_id do
      nil     -> nil
      feed_id -> Repo.get(Feed, feed_id)
    end
  end
end
