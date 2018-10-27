defmodule VidFeeder.Policy do
  @behaviour Bodyguard.Policy

  def authorize(_action, current_user, user) do
    current_user != nil && current_user.id == user.id
  end
end
