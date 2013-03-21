
$(document).ready(function(){
	$("a[rel*=leanModal]").leanModal();
	bookMarklet.start();
});

var bookMarklet = 
{	
	start: function (){
		bookMarklet.addAction();

		// Put the current time from the video into start input box	
		$(".bl-start").click(function(e){
			var curr_time = player.getCurrentTime();
			$("input[name='bl-start']").val(curr_time);

			// Generate new "a" Tag with snippet in bl-URL
			bookMarklet.generateTag();
		}); 

		// Put the current time from the video into end input box
		$(".bl-end").click(function(e){
			var curr_time = player.getCurrentTime();
			$("input[name='bl-end']").val(curr_time);

			// Generate new "a" Tag with snippet in bl-URL
			bookMarklet.generateTag();
		}); 

		// Play the snippet from the start and end input boxes
		$(".bl-play").click(function(e){
			var start = $("input[name='bl-start']").val();
			var end = $("input[name='bl-end']").val();
			var url = player.getVideoUrl();
			var vid = bookMarklet.getVideoIdFromURL(url);

			player.loadVideoById({'videoId': vid, 'startSeconds': start, 'endSeconds': end, 'suggestedQuality': 'large'});
		});

		// Reset the video player
		$(".bl-reset").click(function(e){
			var url = player.getVideoUrl();
			var vid = bookMarklet.getVideoIdFromURL(url);
			bookMarklet.clearInputs();

			player.loadVideoById(vid, 0, "large")
		});
	},


	addAction: function(){
			$("a[rel*=leanModal]").click(function(e){
			

			if($(this).attr('data-u') !== undefined){
				// Get source URL for video
				var url = $(this).attr('data-u');

				// Update source URL in the modal dialog box
				$("#bl iframe").attr('src', url);
				$(".bl-srcURL").attr('href', url);
				$(".bl-srcURL").text(url);

				bookMarklet.clearInputs();
			}else if($(this).attr('data-vid') !== undefined){
				var vid = $(this).attr('data-vid');
				var start_time = $(this).attr('data-start');
				var end_time = $(this).attr('data-end');
				var type = $(this).attr('data-type');
				var url = "http://www.youtube.com/embed/"+vid;
				var playerV;
				
				// Start and end parameters didn't work
				playerV = new YT.Player('playerV', {
					  videoId: vid,
					  
			          events: {
			          	'onReady': bookMarklet.onPlayerReady,
			          }
			    });

			    $("#bl-vid iframe").attr('data-start', start_time);
			    $("#bl-vid iframe").attr('data-end', end_time);


			}

		});

	},

	// clear input fields
	clearInputs: function(){
		$("input[name='bl-end']").val('');
		$("input[name='bl-start']").val('');
		$("input[name='bl-start']").removeClass("bl-incorrect");
		$("input[name='bl-end']").removeClass("bl-incorrect");
		$(".bl-URL").text("Generate URL goes here")
	},

	// Generate a URL for the snippet from the start and end input boxes
	generateTag: function() {
		var start_time = $("input[name='bl-start']").val();
		var end_time = $("input[name='bl-end']").val();
		if ((start_time < end_time || end_time === '') && (start_time !== '')) {
			$("input[name='bl-start']").removeClass("bl-incorrect");
			$("input[name='bl-end']").removeClass("bl-incorrect");
			var url = player.getVideoUrl();
			var vid = bookMarklet.getVideoIdFromURL(url);
			var type = 'yt'

			// var newURL = url + "?start="+start_time+"&end="+end_time;
			var newLink = "<a rel='leanModal' data-start='"+start_time+
						  "' data-end='"+end_time+"' data-type='"+
						  type+"' data-vid='" + vid +
						  "' href='#bl-vid'>Click Here</a>";

			$(".bl-URL").text(newLink);


			// For testing only
			$(".bl-test a").remove();
			$(".bl-test").append(newLink);

			$("a[rel*=leanModal]").leanModal();
			bookMarklet.addAction();

		}else{
			$("input[name='bl-start']").addClass("bl-incorrect");
			$("input[name='bl-end']").addClass("bl-incorrect");
		}
	},

	getVideoIdFromURL: function(url){
		if(url.indexOf("v=") !== -1){
			var vid = url.split('v=')[1];
			var ampersandPosition = vid.indexOf('&');
			if(ampersandPosition != -1) {
					 vid = vid.substring(0, ampersandPosition);
			};

			return vid
		}else{
			var vid = url.split('embed/')[1];
			var questionPosition = vid.indexOf('?');
			if(questionPosition != -1) {
					 vid = vid.substring(0, questionPosition);
			};

			return vid
		}
	},

	onPlayerReady: function(event) {
			var start_time = $("#bl-vid iframe").attr('data-start');
			var end_time = $("#bl-vid iframe").attr('data-end');
			var url = event.target.getVideoUrl();
			var vid = bookMarklet.getVideoIdFromURL(url);
	        event.target.cueVideoById({'videoId': vid, 'startSeconds': start_time, 'endSeconds': end_time, 'suggestedQuality': 'large'});
	},

	setup: function(){
		// This code loads the IFrame Player API code asynchronously.
		var tag = document.createElement('script');

		// This is a protocol-relative URL as described here:
		//     http://paulirish.com/2010/the-protocol-relative-url/
		tag.src = "https://www.youtube.com/iframe_api";
		var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

		// Create a YouTube player object for the modal dialog window
		var player;
		function onYouTubeIframeAPIReady() {
			player = new YT.Player('player', {
			  iv_load_policy: 3,
			  events: {
			  	// set up event listeners
			  }
			});

		};
		alert("hi");
	}

}


bookMarklet.setup();



// Create a YouTube player object for the modal dialog window
var player;
function onYouTubeIframeAPIReady() {
	player = new YT.Player('player', {
	  iv_load_policy: 3,
	  events: {
	  	// set up event listeners
	  }
	});

};




