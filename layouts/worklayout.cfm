<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="description" content="PSU HR Application.">	
		<title>Awards</title>
		<cfoutput>
			<base href="#event.getHTMLBaseURL()#" />
			<!--- Bootstrap CSS CDN --->
      <link rel="stylesheet" href="includes/css/main.min.css">
      <link rel="stylesheet" href="includes/css/awards.css">
      <link rel="stylesheet" href="includes/css/main2.css">
      <link rel="stylesheet" href="includes/css/token-input-facebook.css">
	  <link rel="stylesheet" href="includes/css/token-input.css">
	  <link rel="stylesheet" href="includes/css/themes/flick/jquery-ui.min.css">

		<!--- Font Awesome JS --->
		<script defer src="https://use.fontawesome.com/releases/v5.0.13/js/solid.js" integrity="sha384-tzzSw1/Vo+0N5UhStP3bvwWPq+uvzCMfrN1fEFe+xBmv1C/AtVX5K0uZtmcHitFZ" crossorigin="anonymous"></script>
      <script defer src="https://use.fontawesome.com/releases/v5.0.13/js/fontawesome.js" integrity="sha384-6OIrr52G08NpOFSZdxxz1xdNSndlD4vdcf/q2myIUVO0VsqaGHJsB0RaBE01VTOY" crossorigin="anonymous"></script>
      <!--- jQuery Custom Scroller CDN --->
      <script src="includes/js/jquery-3.4.1.min.js"></script>
      <script src="includes/js/popper.min.js"></script>
      <script src="includes/js/jquery.mCustomScrollbar.concat.min.js"></script>
      <script src="includes/js/bootstrap.min.js"></script>
	  <script src="includes/js/jquery.tokeninput.js"></script>

	  <script src="includes/js/jquery-ui.min.js"></script>
		<script>
			$(document).ready(function(){
				$( document ).on("focus", ".dField", function(){
					$(this).datepicker({ autoSize: true });
				});

			});
		</script>

      <!--- Vars --->
      <cfset variables.hrSite = getSetting( "hrSite" )>
	</head>
	<body>
		<!--- outer wrapper for entire page --->
		<div class="wrapper">
			<!--- main left hand nav --->
			#runEvent("layout.mainmenu")#
			<!--- primary content (right-hand pane) --->
			<div id="content">
				<!-- top subnav - side nav toggle button  -->
				#renderView(
					view="nav/maintop"
				)#
        <!-- Page Content  -->
        #getInstance( 'messagebox@cbmessagebox' ).renderIt()#
				#renderView()#
				<!--- footer --->
				<footer class="section footer-classic bg-image" style="background-color: ##e4e5e6";>
					<div class="container">
						<div class="row" style="padding-top:10px;">
							<address>	
								<strong><a href="#variables.hrSite#">Human Resources</a></strong><br />
								The 331 Building<br />
								Suite 136<br />
								University Park, PA 16802
							</address>
						</div>
					</div>
				</footer>
			</div><!---. / content --->
		</div><!---. /wrapper --->		
		
		</cfoutput>
		<script type="text/javascript">
			$(document).ready(function () {
				$("#sidebar").mCustomScrollbar({
					theme: "minimal"
				});
			
				$('#sidebarCollapse').on('click', function () {
					$('#sidebar, #content').toggleClass('active');
					$('.collapse.in').toggleClass('in');
					$('a[aria-expanded=true]').attr('aria-expanded', 'false');
				});
			});
		</script>
  	</body>
</html>