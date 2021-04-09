module ui
	
	template bootstrap {
		 // https://getbootstrap.com/docs/5.0/getting-started/introduction/#starter-template
		 head {
			 <!-- Required meta tags -->
			 <meta charset="utf-8">
			 <meta name="viewport" content="width=device-width, initial-scale=1">
			 <!-- Bootstrap CSS -->
			 <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" 
			 	integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
			 <!-- font-awesome icons -->
			 <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
			 <title>"Social Walk"</title>
		 }
	}
	
	template bootstrapJavaScript {
		<!-- Option 1: Bootstrap Bundle with Popper -->
		<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js" 
			integrity="sha384-LtrjvnR4Twt/qOuYxE721u19sVFLVSA4hf/rRt6PrZTmiPltdZcI7q7PXQBYTKyf" crossorigin="anonymous"></script>
	}
	
	template myLabel( label: String ) {
		gridRow {
			label( label )[ class= "col-sm col-form-label" ]{
				gridCol {
					elements
				}
			}
		}
	}
	
	override template errorTemplateInput( messages: [String] ){
		elements
		for( ve in messages ){
			div[ class="row justify-content-md-center" ]{
				div[ class= "col-sm" ]{
					span[ style := "color: #FF0000" ]{
						text(ve)
					}
				}
			}
		}
	}
	
	template gridRow {
  		div[class="row", all attributes]{ elements }
  	}
  	
  	template gridCol {
  		div[class="col-sm", all attributes]{ elements }
  	}
  	
  	template card {
  		div[class="card", all attributes]{ elements }
  	}
  	
  	template card(headerText: String) {
  		card[class="text-center"] {
  			cardHeader {
  				h2 {~headerText}
  			}
  			cardBody[class="p-0 my-auto"] {
  				elements
  			}
  		}
  	}
  	
  	template cardBody {
  		div[class="card-body", all attributes]{ elements }
  	}
  	
  	template cardHeader {
  		div[class="card-header", all attributes]{ elements }
  	}
  	
  	override attributes submit{ class="btn btn-primary" }
	override attributes submitlink{ submit attributes }
	override attributes inputInt{ class="form-control" }
	override attributes inputString{ class="form-control" }
	override attributes inputEmail{ class="form-control" }
	override attributes inputSecret{ class="form-control" }
	
	template main {
		bootstrap
		<nav class="navbar navbar-light bg-light">
			<a class="navbar-brand" href="/SocialWalk">"SocialWalk"</a>
			if (loggedIn()) {
				div [class="navbar-nav mr-auto"] {
					<a class="nav-link" href="/SocialWalk/groupSearch">"Group Search"</a>
				} div [class="navbar-nav"] {
					<a class="nav-link" href="/SocialWalk/user/"+securityContext.principal.id>~securityContext.principal.name</a>	
				}
			}	
  		</nav>
  		<div class="container py-3">
			elements
		</div>
		bootstrapJavaScript
	}
