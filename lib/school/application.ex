defmodule School.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(School.Repo, []),
      # Start the endpoint when the application starts
      supervisor(SchoolWeb.Endpoint, []),
      # Start your own worker by calling: School.Worker.start_link(arg1, arg2, arg3)
      # worker(School.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: School.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SchoolWeb.Endpoint.config_change(changed, removed)
    :ok
  end

@member_map %{
      name: "YONG CHUI MEI", 
      chinese_name: "", 
      phone: "no-phone",
      email: "no-email",
      ic_no: "880720-08-5291",  
      membership_code: "KHS013"} 
@loan_map %{
  loan_params: %{

    inventory_id: 100,
    member_organization_id: 281,
    loan_date: Date.utc_today,
    return_date: Date.utc_today
  }
}

@return_map %{
  loan_params: %{
    
    inventory_id: 100,
    member_organization_id: 281,
  }
}

  def api(request_type) do
       # uri<>"?scope=get_lib&lib_id=1",
        # uri<>"?scope=get_books&cat_id=3&lib_id=1",
         # uri<>"?scope=get_members&lib_id=1",

         # uri<>"?scope=link_member&lib_id=1",
         # uri<>"?scope=loan_book&lib_id=1",
         # uri<>"?scope=return_loan&lib_id=1",
    uri = "http://localhost:4000/api"
    json_map = @return_map |> Poison.encode!
     case request_type  do
       "get" ->
        HTTPoison.get!(
          uri<>"?scope=get_members&lib_id=1",
          [{"Content-Type", "application/json"}],
          timeout: 50_000,
          recv_timeout: 50_000
        ).body |> Poison.decode!
        "post" ->
        
        HTTPoison.post!(
          uri<>"?scope=loan_book&lib_id=1",
          json_map,
          [{"Content-Type", "application/json"}],

          timeout: 50_000,
          recv_timeout: 50_000
        )
     end
     # create an account and get api key from it...
     # need to create an api that would call for the library and keep in institute model
      # get the students member_organization
      # student need to create account in li6rary by linking 
  end

end
