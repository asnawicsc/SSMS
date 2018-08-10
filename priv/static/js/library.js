$(document).ready(function(){

	$("button.api").click(function(){
		var scope = $(this).attr("call")
			$("table[aria-label='result']").html("")

				switch (scope) {

				    case "get_loans":
				

						    $.ajax({
						      url: "/operations",
						      dataType: "json",
						      data: { scope: scope }
						    }).done(function(j) {
									
						    	var loans = j.loan
						    	$(loans).each(function(i, c){
						    
							
						    	})
						    })
				   		  break;
				    case "get_lib":

						    $.ajax({
						      url: "/operations",
						      dataType: "json",
						      data: { scope: scope }
						    }).done(function(j) {
					
						    	var categories = j.categories
						    	$(categories).each(function(i, c){

						
						    	})
							    $("div.show_book").click(function(){
							    	var cat_id = $(this).attr("cat_id")

								    $.ajax({
								      url: "/operations",
								      dataType: "json",
								      data: { scope: "get_books", cat_id: cat_id }
								    }).done(function(j) {

								    })
							    })
						    })

				        break;

				    case "get_book":
								 var q = $("input[name='query']").val()
						    $.ajax({
						      url: "/operations",
						      dataType: "json",
						      data: { scope: scope, query: q }
						    }).done(function(j) {
					
					        $("table#book_result").DataTable({
					             destroy: true,
					            data: j,
					            dom: 'Bfrtip',
					            buttons: [
					                'copy', 'csv', 'print'
					            ],
					            columns: [
					            {data: 'name'},
					            {data: 'series'},
					            {data: 'volume'},
					            {data: 'author'},
					            {data: 'coauthor'},
					            {data: 'barcode'},
					            {data: 'isbn'},

					            {data: 'publisher'},
					            {data: 'illustrator'},
					            {data: 'translator'}
					            
					  
					            ]
					        });


						    })

				        break; 

				        


				    case "get_user":
								 var q = $("input[name='user']").val()
						    $.ajax({
						      url: "/operations",
						      dataType: "json",
						      data: { scope: scope, query: q }
						    }).done(function(j) {

				        $("table#user_result").DataTable({
				             destroy: true,
				            data: j,
				            dom: 'Bfrtip',
				            buttons: [
				                'copy', 'csv', 'print'
				            ],
				            columns: [
				            {data: 'name'},
				            {data: 'member_id'}

				            ]
				        });


						    })

				        break; 


				    case "get_loan_response":
				    var q = $("input[name='query']").val()
								 var u = $("input[name='user']").val()
						    $.ajax({
						      url: "/operations",
						      dataType: "json",
						      data: { scope: scope, book: q, user: u }
						    }).done(function(j) {

						    			console.log(j)

						    			if (j.has_returned == false) {
						    				$.notify({message: "This book is still on loan, and it will return by "+j.return_date}, {type: "danger"});
						    			} else {
						    				$.notify({message: "This book loan successfully!"}, {type: "success"});
						    			}

						    })

				        break; 


				    case "none":
				       
				}
		
	})

});