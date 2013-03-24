var bookMarklet = 
{	
	// bookMarklet namespace
	// Variables:
	//	 player
	//	 playerV
	// 	 vid
	//   start_time
	//   end_time

	// Functions:
	//	 start()
	//	 addAction()
	//	 clearInputs()
	//	 getVideoIdFromURL(url)
	// 	 generateTag()
	//	 onPlayerReady()
	// 	 setup()

	vid: "",
	start_time: "",
	end_stime: "",
	video_type: "",
	answer_class: "bookMarklet-answer",

	// Sets up event listeners for ".bl-start", ".bl-end", ".bl-reset", and
	// 	".bl-done"
	// Creates bookMarklet.player
	// Through addAction(), Adds click listeners to all #bl and 
	// 	#bl-vid elements
	// @parameters: none
	// @returns: nil
	// @modifies: ".bl-start", ".bl-end", ".bl-reset", ".bl-done", "#bl", and
	// 	"#bl-elements"
	start: function (){

		$("[rel*=leanModal]").leanModal({closeButton: ".bl-done"});

		// Adds click listeners to all #bl and #bl-vid elements
		bookMarklet.addActions();

		// TO DO: Generalize this
		// Create a YouTube player object for the modal dialog window
		bookMarklet.player = new window.YT.Player('player', {
		  events: {
		  	// set up event listeners
		  	// Note: add event listeners when the was implmented
		  }
		});


		// "Start Time" button in #bl box
		$(".bl-start").click(function(e){

			// Put the current time from the video into start input box	
			var curr_time = bookMarklet.player.getCurrentTime();
			$("input[name='bl-start']").val(curr_time);
			bookMarklet.checkErrors();
		}); 

		// "End Time" button in #bl box
		$(".bl-end").click(function(e){

			// Put the current time from the video into end input box
			var curr_time = bookMarklet.player.getCurrentTime();
			$("input[name='bl-end']").val(curr_time);
			bookMarklet.checkErrors();
		}); 

		// "Done" button in #bl box
		// Also, closes #bl
		$(".bl-done").click(function(e){

			bookMarklet.generateTag();
			// Stop "player" playback
			bookMarklet.player.stopVideo();
		});

		// "Reset" button in #bl box
		$(".bl-reset").click(function(e){

			// Reset the video player to initial state
			bookMarklet.clearInputs();
			bookMarklet.player.loadVideoById(bookMarklet.vid, 0, "large")
		});
	},

	checkErrors: function(){
		var start_time = $("input[name='bl-start']").val();
		var end_time = $("input[name='bl-end']").val();
		if((start_time < end_time || end_time === '') && (start_time !== '')){
			$("input[name='bl-start']").removeClass("bl-incorrect");
			$("input[name='bl-end']").removeClass("bl-incorrect");
		}else{
			$("input[name='bl-start']").addClass("bl-incorrect");
			$("input[name='bl-end']").addClass("bl-incorrect");
		}

	},

	create: function(textareaclass, videotype, videoid){

		$("."+textareaclass).each(function(index){
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
					.addClass(textareaclass)
					.css({
						width: w,
						height: h
					});

		});


		$("."+bookMarklet.answer_class).after("<input type='button' value='Snippet'>")
						 .next()
						 .attr({
						 	rel: "leanModal",
						 	href: "#bl",
						 	"data-bl": "generate",
						 	"data-bl-vid": videoid,
						 	"data-bl-type": videotype
						 });

	},


	// Adds click listeners to all #bl and #bl-vid leanModal links
	// "a" tag with "data-bl" attribute of "generate" correspond to snippet generate links
	// "a" tag with "data-bl" attribute of "show" correspond to snippet playback links
	// @parameters: none
	// @returns: nil
	// @modifies: all "a[rel*=leanModal]" with attr 'data-bl'
	addActions: function(){
		$(document).on("click","[rel*=leanModal]" ,function(){
			

			if($(this).attr('data-bl') === "generate"){
				// Get source URL for video from data-u
				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.video_type = $(this).attr('data-bl-type');

				if(bookMarklet.video_type = "yt"){
					var url = "http://www.youtube.com/embed/"+bookMarklet.vid;
				};

				
				// Important: loads video into iframe and starts "player" controls
				$("#bl iframe").attr('src', url);

				// Update source URL in the modal dialog box
				$(".bl-srcURL").attr('href', url);
				$(".bl-srcURL").text(url);

				// Reset the video player to initial state
				bookMarklet.clearInputs();

			}else if($(this).attr('data-bl') === "show"){

				// Get video information from snippet playback link
				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.start_time = $(this).attr('data-bl-start');
				bookMarklet.end_time = $(this).attr('data-bl-end');
				bookMarklet.video_type = $(this).attr('data-bl-type');

				// TO DO: Generalize this
				// Generate URL needed by iframes
				if(bookMarklet.video_type = "yt"){
					var url = "http://www.youtube.com/embed/"+bookMarklet.vid;
				};

				// Important: loads video into iframe and starts "playerV" controls
				$("#bl-vid iframe").attr('src', url);


			    // TO DO: Generalize this
				// Create a YouTube player object for the modal dialog window
				playerV = new YT.Player('playerV', {
			          events: {
			          	// Once "playerV" is ready this cues the snippet to play
			          	'onReady': bookMarklet.YTOnPlayerReady,
			          }
			    });

			}

		});

	},

	// Clear input fields in #bl box
	// @parameters: none
	// @returns: nil
	// @modifies: all "input[name='bl-end']", "input[name='bl-start']", and ".bl-URL"
	clearInputs: function(){
		$("input[name='bl-end']").val('');
		$("input[name='bl-start']").val('');
		$("input[name='bl-start']").removeClass("bl-incorrect");
		$("input[name='bl-end']").removeClass("bl-incorrect");
		$(".bl-URL").text("Generate URL goes here")
	},

	// Generate a URL for the snippet from the start and end input boxes
	// @parameters: text - String for "a" tag text
	// @returns: String - if start & end are valid values then the string is
	//	 a valid "a" tag with text "text"
	// @modifies: all "input[name='bl-start']", "input[name='bl-end']", ".bl-URL"
	// 			  one ".bl-answer"
	// @creates: one "a[rel*=leanModal]" with attr "data-vid"
	generateTag: function() {
		var start_time = $("input[name='bl-start']").val();
		var end_time = $("input[name='bl-end']").val();
		if ((start_time < end_time || end_time === '') && (start_time !== '')) {
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
			// var startInt = Math.round(start_time);
			// var start = Math.floor(startInt/60)+":"+(startInt%60);
			// var endInt = Math.round(end_time);
			// var end = Math.floor(endInt/60)+":"+(endInt%60);

			var text = start +"-"+ end;

			var newLink = "<a rel='leanModal' data-bl-start='"+start_time+
						  "' data-bl-end='"+end_time+"' data-bl-type='"+
						  bookMarklet.video_type+"' data-bl-vid='" + 
						  bookMarklet.vid +
						  "' href='#bl-vid' data-bl='show'>"+text+
						  "</a>";

			bookMarklet.update(newLink);

			return newLink;

		}else{
			return "";
		}
	},


	update: function(newLink){
		$(".bl-URL").text(newLink);

		var srcURL = $("#bl iframe").attr('src');
		var srcQues = "[data-bl-vid='"+bookMarklet.vid+"'][data-bl-type='"
					  +bookMarklet.video_type+"']";
					  
		// $(srcQues).prev(".bl-answer").children().remove();
		$(srcQues).prev("."+bookMarklet.answer_class).append(newLink);

		// adds overlay
		$("a[rel*=leanModal]").leanModal();
	},

	// Cues Video in "playerV" to data-start and data-end from #bl-vi iframe
	// data-start and data-en are generated from an "a" tag with "data-vid" attribute.
	// See bookMarklet.addActions() 
	// @parameters: event - onReady event from playerV
	// @returns: undefined
	// @modifies: all "#bl-vid iframe"
	YTOnPlayerReady: function(event) {
	        event.target.cueVideoById({'videoId': bookMarklet.vid,
	        						   'startSeconds': bookMarklet.start_time,
	         						   'endSeconds': bookMarklet.end_time, 
	         						   'suggestedQuality': 'large'});
	},


	// Add scripts for YouTube iFrame API
	// @parameters: none
	// @returns: undefined
	// @modifies: "document"
	setup: function(){
		// This code loads the IFrame Player API code asynchronously.
		var tag = document.createElement('script');

		// This is a protocol-relative URL as described here:
		//     http://paulirish.com/2010/the-protocol-relative-url/
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




