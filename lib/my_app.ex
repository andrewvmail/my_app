defmodule MyApp.Server do
  use Maru.Server, otp_app: :my_app
end

defmodule Router.Homepage do
  use MyApp.Server

  #plug Jwt.Plugs.VerifySignature

  get "/token" do
    {:ok, token, claims} = MyApp.Token.generate_and_sign()
    message = %{
        token: token,
        claims: claims,
    }
    conn
      |> put_resp_header("content-type", "application/json; charset=utf-8")
      |> send_resp(200, Poison.encode!(message, pretty: true))
  end
end

defmodule MyApp.API do
  use MyApp.Server

  before do
    plug Plug.Logger
    plug Plug.Static, at: "/static", from: "/my/static/path/"
  end

  plug Plug.Parsers,
       pass: ["*/*"],
       json_decoder: Jason,
       parsers: [:urlencoded, :json, :multipart]

  mount Router.Homepage

  rescue_from Unauthorized, as: e do
    IO.inspect(e)

    conn
    |> put_status(401)
    |> text("Unauthorized")
  end

  rescue_from [MatchError, RuntimeError], with: :custom_error

  rescue_from :all, as: e do
    conn
    |> put_status(Plug.Exception.status(e))
    |> text("Server Error")
  end

  defp custom_error(conn, exception) do
    conn
    |> put_status(500)
    |> text(exception.message)
  end
end

defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      MyApp.Server
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
