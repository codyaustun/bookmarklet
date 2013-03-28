var bookMarklet = 
{	

	vid: "",
	start_time: "",
	end_stime: "",
	video_type: "",
	answer_class: "bookMarklet-answer",
	reel: false,
	modal_id: "",

	start: function (){

		if($("#bl").length === 0){
			bookMarklet.generateSnippetBox();
		}

		if($("#bl-vid").length === 0){
			bookMarklet.generateVideoBox();
		}
		if($("#bookMarklet-overlay").length === 0){
			$("<div id='bookMarklet-overlay'></div>").appendTo("body");
		}

		$("#bookMarklet-overlay").click(function() { 
            bookMarklet.close_modal(bookMarklet.modal_id);                    
        });

        $(".bl-done").click(function() { 
            bookMarklet.close_modal(bookMarklet.modal_id);                    
        });

		bookMarklet.addActions();

		$(".bl-start").click(function(e){
			var curr_time = bookMarklet.player.getCurrentTime();
			$("input[name='bl-start']").val(curr_time);
			bookMarklet.checkErrors();
		}); 


		$(".bl-end").click(function(e){
			var curr_time = bookMarklet.player.getCurrentTime();
			$("input[name='bl-end']").val(curr_time);
			bookMarklet.checkErrors();
		}); 


		$(".bl-done").click(function(e){
			bookMarklet.update(bookMarklet.generateTag());
			bookMarklet.player.stopVideo();
		});

		$(".bl-reset").click(function(e){
			bookMarklet.clearInputs();
			bookMarklet.player.loadVideoById(bookMarklet.vid, 0, "large")
		});
	},

	close_modal: function(modal_id){
		$("#bookMarklet-overlay").fadeOut(200);
		$(modal_id).css({ 'display' : 'none' });
	},

	checkErrors: function(){
		var start_time = parseFloat($("input[name='bl-start']").val());
		var end_time = parseFloat($("input[name='bl-end']").val());
		if((start_time < end_time || isNaN(end_time)) && (!isNaN(start_time))){
			$("input[name='bl-start']").removeClass("bl-incorrect");
			$("input[name='bl-end']").removeClass("bl-incorrect");
			return true;
		}else{
			$("input[name='bl-start']").addClass("bl-incorrect");
			$("input[name='bl-end']").addClass("bl-incorrect");
			return false;
		}

	},

	create: function(textareaid, videotype, videoid, button, reel){

		// reel = 1 -> film
		// reel = 2 -> director thing
		// reel = 3 -> film reel
		// reel = false || undefined -> "Start Time"-"End Time"
		bookMarklet.reel = reel;

		$("#"+textareaid).each(function(index){
			var w = $(this).width();
			var h = $(this).height();
			var content = $(this).val();

			$(this).after("<div></div>")
				   .css("display", "none")
				   .next()
				   .attr({
						contenteditable: "true"
					})
					.addClass(bookMarklet.answer_class)
					.css({
						width: w,
						height: h
					});

		});

		if(button){
			$("."+bookMarklet.answer_class).after("<input type='button' value='Snippet'>")
							 .next()
							 .attr({
							 	rel: "blModal",
							 	href: "#bl",
							 	"data-bl": "generate",
							 	"data-bl-vid": videoid,
							 	"data-bl-type": videotype
							 });
		};


	},

	addActions: function(){
		$(document).on("click","[rel*=blModal]" ,function(){
			bookMarklet.modal_id = $(this).attr("href");

            var modal_width = $(bookMarklet.modal_id).outerWidth();

            $("#bookMarklet-overlay").css({'opacity' : 'block', opacity: 0});
            $("#bookMarklet-overlay").fadeTo(200,0.5);

            $(bookMarklet.modal_id).css({ 
        			'display' : 'block',
        			'position' : 'fixed',
        			'opacity' : 0,
        			'z-index': 11000,
        			'left' : 50 + '%',
        			'margin-left' : -(modal_width/2) + "px",
        			'top' : "100px"
        		
        	});

        	$(bookMarklet.modal_id).fadeTo(200,1);

			if($(this).attr('data-bl') === "generate"){

				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.video_type = $(this).attr('data-bl-type');

				if(bookMarklet.video_type = "yt"){
					var url = "http://www.youtube.com/embed/"+bookMarklet.vid;
				};

				$(".bl-srcURL").attr('href', url);
				$(".bl-srcURL").text(url);

				bookMarklet.clearInputs();

				bookMarklet.player = new window.YT.Player('bl-player', {
				  videoId: bookMarklet.vid,
				  events: {
				  }
				});

			}else if($(this).attr('data-bl') === "show"){

				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.start_time = $(this).attr('data-bl-start');
				bookMarklet.end_time = $(this).attr('data-bl-end');
				bookMarklet.video_type = $(this).attr('data-bl-type');


			    // TO DO: Generalize this
				// Create a YouTube player object for the modal dialog window
				bookMarklet.playerV = new YT.Player('bl-playerV', {
				  	  videoId: bookMarklet.vid,
			          events: {
			          	// Once "playerV" is ready this cues the snippet to play
			          	'onReady': bookMarklet.YTOnPlayerReady,
			          }
			    });

			}

		});

	},

	clearInputs: function(){
		$("input[name='bl-end']").val('');
		$("input[name='bl-start']").val('');
		$("input[name='bl-start']").removeClass("bl-incorrect");
		$("input[name='bl-end']").removeClass("bl-incorrect");
		$(".bl-URL").text("Generate URL goes here")
	},

	generateTag: function() {
		var start_time = $("input[name='bl-start']").val();
		var end_time = $("input[name='bl-end']").val();
		if (bookMarklet.checkErrors()) {
			$("input[name='bl-start']").removeClass("bl-incorrect");
			$("input[name='bl-end']").removeClass("bl-incorrect");


			if(end_time === ""){
				end_time = bookMarklet.player.getDuration();
			}

			var start = new Date(null);
			var end = new Date(null);
			start.setSeconds(start_time);
			end.setSeconds(end_time);
			start = start.toTimeString().substr(3,5);
			end = end.toTimeString().substr(3,5);

			if(bookMarklet.reel){
				var text = "<img alt='video snippet' src='"+
					"images/film"+bookMarklet.reel+"Small.png"
				+"'>"
			}else{
				var text = start +"-"+ end;
			}

			var newLink = "<a rel='blModal' data-bl-start='"+start_time+
						  "' data-bl-end='"+end_time+"' data-bl-type='"+
						  bookMarklet.video_type+"' data-bl-vid='" + 
						  bookMarklet.vid +
						  "' href='#bl-vid' data-bl='show'>"+text+
						  "</a>";

			

			return newLink;

		}else{
			return "";
		}
	},

	generateVideoBox: function(){
		$("<div id='bl-vid'><div class='bl-video-wrap'>"+
			"<div id='bl-playerV'></div>"				 
		 +"</div></div>").appendTo("body");
	},

	generateSnippetBox: function(){
		$("<div id='bl'>"+
		      "<div class='bl-top'>"+
		        "<div class='bl-vid'>"+
		        "<div id='bl-player'></div>"
		        +"</div>"+
		        "<div class='bl-controls'>"+
		          "<div class='bl-title'>"+
		            "<h1>Create a URL</h1>"+
		          "</div>"+
		          "<div class='bl-instructions'>"+
		            "Click \"Start Time\" and \"End Time\" buttons,"+
		            "or by type in the time in the text boxes."+
		          "</div>"+
		          "<table class='bl-input'>"+
		            "<tr>"+
		                "<td>"+
		                  "<input class='bl-button bl-start' type='button' value='Start Time'>"+
		                "</td>"+
		                "<td>"+
		                "</td>"+
		                "<td>"+
		                  "<input class='bl-button bl-end' type='button' value='End Time'>"+
		                "</td>"+
		            "</tr>"+
		            "<tr>"+
		                "<td>"+
		                  "<input class='bl-data' type='text' name='bl-start'>"+
		                "</td>"+
		                "<td>"+
		                  "-"+
		                "</td>"+
		                "<td><input class='bl-data' type='text' name='bl-end'></td>"+
		            "</tr>"+
		            "<tr>"+
		                "<td><input class='bl-button bl-done' type='button' value='Done'></td>"+
		                "<td></td>"+
		                "<td><input class='bl-button bl-reset' type='button' value='Reset'></td>"+
		            "</tr>"+
		          "</table>"+

		          "<textarea class='bl-URL'>"+
		            "Generate URL goes here"+
		          "</textarea>"+
		        "</div>"+
		      "</div>"+
		      "<div class='bl-bottom'>"+
		        "Source URL:"+ 
		        "<a class='bl-srcURL'></a>"+
		      "</div>"+
		    "</div>").appendTo("body");
	},


	update: function(newLink){
		$(".bl-URL").text(newLink);

		var srcQues = "[data-bl-vid='"+bookMarklet.vid+"'][data-bl-type='"
					  +bookMarklet.video_type+"']";
					  
		$(srcQues).prev("."+bookMarklet.answer_class).append(newLink);

		// PROBLEM: adds overlay
		$("a[rel*=leanModal]").leanModal();
	},

	YTOnPlayerReady: function(event) {
	        event.target.cueVideoById({'videoId': bookMarklet.vid,
	        						   'startSeconds': bookMarklet.start_time,
	         						   'endSeconds': bookMarklet.end_time, 
	         						   'suggestedQuality': 'large'});
	},


	setup: function(){
		var tag = document.createElement('script');
		tag.src = "https://www.youtube.com/iframe_api";
		var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
	}

}


bookMarklet.setup();
// Create a YouTube player object for the modal dialog window
function onYouTubeIframeAPIReady() {
	$(document).ready(function(){
		bookMarklet.start();
	});	
};




