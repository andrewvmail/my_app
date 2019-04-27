defmodule MyApp.Token do
  use Joken.Config

  def token_config, do: default_claims(default_exp: 60 * 60 * 8760) # 1 year 
end
