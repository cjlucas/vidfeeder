defmodule YouTube.Connection do
  @scope "https://www.googleapis.com/auth/youtube"

  def new do
    {:ok, token} = Goth.Token.for_scope(@scope)

    GoogleApi.YouTube.V3.Connection.new(token.token)
  end
end
