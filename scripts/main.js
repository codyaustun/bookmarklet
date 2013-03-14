
$(document).ready(function(){

	$("a[rel*=leanModal]").leanModal();

	$("a[rel*=leanModal]").click(function(e){
		
		// Get source URL for video
		var url = $(this).attr('data-u');

		// Update source URL in the modal dialog box
		$("#bl iframe").attr('src', url);
		$(".bl-srcURL").attr('href', url);
		$(".bl-srcURL").text(url);

		// clear input fields
		$("input[name='bl-start']").val("");
		$("input[name='bl-end']").val("");

	});

	// Generate a URL for the snippet from the start and end input boxes
	$(".bl-create").click(function(e){
		var start_time = $("input[name='bl-start']").val();
		var end_time = $("input[name='bl-end']").val();
		// var url = $("#bl iframe").attr('src');
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);
		var type = 'yt'

		// var newURL = url + "?start="+start_time+"&end="+end_time;
		var newLink = "<a rel='leanModal' data-start='"+start_time+
					  "' data-end='"+end_time+"' data-type='"+
					  type+"' data-vid='" + vid +
					  "' href='#bl-vid'>Click Here</a>";

		$(".bl-URL").text(newLink);
	});


	// Put the current time from the video into start input box	
	$(".bl-start").click(function(e){
		var curr_time = player.getCurrentTime();
		$("input[name='bl-start']").val(curr_time);
	}); 

	// Put the current time from the video into end input box
	$(".bl-end").click(function(e){
		var curr_time = player.getCurrentTime();
		$("input[name='bl-end']").val(curr_time);
	}); 

	// Play the snippet from the start and end input boxes
	$(".bl-play").click(function(e){
		var start = $("input[name='bl-start']").val();
		var end = $("input[name='bl-end']").val();
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);

		$(".bl-URL").text(vid);

		player.loadVideoById({'videoId': vid, 'startSeconds': start, 'endSeconds': end, 'suggestedQuality': 'large'})
		player.seekTo(start, true);
	});

	// Reset the video player
	$(".bl-reset").click(function(e){
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);

		player.loadVideoById(vid, 0, "large")
	});

});

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
	  events: {
	  	// set up event listeners
	  }
	});
};

function getVideoIdFromURL(url){
	var vid = url.split('v=')[1];
	var ampersandPosition = vid.indexOf('&');
	if(ampersandPosition != -1) {
			 vid = vid.substring(0, ampersandPosition);
	};

	return vid
};

