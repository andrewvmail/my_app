defmodule MyApp.Server do
  use Maru.Server, otp_app: :my_app
end

defmodule Router.User do
  use MyApp.Server

  namespace :user do
    route_param :id do
      get do
        json(conn, %{user: params[:id]})
      end

      desc "description"

      params do
        requires :age, type: Integer, values: 18..65
        requires :gender, type: Atom, values: [:male, :female], default: :female

        group :name, type: Map do
          requires :first_name
          requires :last_name
        end

        optional :intro, type: String, regexp: ~r/^[a-z]+$/
        optional :avatar, type: File
        optional :avatar_url, type: String
        exactly_one_of [:avatar, :avatar_url]
      end

      # post do
      #   ...
      # end
    end
  end
end

defmodule Router.Homepage do
  use MyApp.Server

  resources do
    get do
      json(conn, %{hello: :world})
    end

    mount Router.User
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
