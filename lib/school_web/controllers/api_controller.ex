defmodule SchoolWeb.ApiController do
  use SchoolWeb, :controller
  use Task
  import Ecto.Query
  alias School.Settings
  alias School.Settings.{Institution, User, Parameter}
  require IEx

  def webhook_get(conn, params) do
    cond do
      params["fields"] == nil ->
        send_resp(conn, 200, "please include request  in field.")

      params["fields"] == "get_guardian_ic" ->
        get_guardian_ic(conn, params)

   end
  end

  def get_guardian_ic(conn, params) do
    messenger_user_id = params["messenger user id"]
    ic = params["IC"]

    parent=Repo.all(from s in School.Affairs.Parent, where s.icno ==^ic)

    IO.inspect(params)
    uri = Application.get_env(:school, :api)[:url]


  

   
      {map} =if parent != [] do

      	 students=Repo.all(from s in School.Affairs.Student, where s.gicno==^ic)

      	
      	 	 

	   %{
	        "messages" => [
	          %{
	            "attachment" => %{
	              "type" => "template",
	              "payload" => %{
	                "template_type" => "button",
	                 "text": "Please click on your children name.",
	                "buttons" => [
	         		
	         			for stud <- students do

			         	 		path = "?scope=get__stud=#{stud.id}"
		      	 	 			 name=stud.name

			      	 	 	%{
			                    "url" => uri <> path,
			                    "type" => "json_plugin_url",
			                    "title" => name
		                  	}

		
	                  	 end
	                 
	                ]
	              }
	            }
	          }
	        ]
	    }|> Poison.encode!()



      

      	 {map}

    else

    	map=%{"messages" => 
    	   [
    		%{"text"=> "Sorry, we dont have your data!"},
    		%{"text"=>"Please contact admin, for more info. 🤖"}
    		]

    	} |> Poison.encode!()

    	{map}

    	
    end
  

    send_resp(conn, 200, map)
  end

end
