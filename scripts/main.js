
$(document).ready(function(){
	$("a[rel*=leanModal]").leanModal();
	
	addAction();



	// Put the current time from the video into start input box	
	$(".bl-start").click(function(e){
		var curr_time = player.getCurrentTime();
		$("input[name='bl-start']").val(curr_time);

		// Generate new "a" Tag with snippet in bl-URL
		generateTag();
	}); 

	// Put the current time from the video into end input box
	$(".bl-end").click(function(e){
		var curr_time = player.getCurrentTime();
		$("input[name='bl-end']").val(curr_time);

		// Generate new "a" Tag with snippet in bl-URL
		generateTag();
	}); 

	// Play the snippet from the start and end input boxes
	$(".bl-play").click(function(e){
		var start = $("input[name='bl-start']").val();
		var end = $("input[name='bl-end']").val();
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);

		player.loadVideoById({'videoId': vid, 'startSeconds': start, 'endSeconds': end, 'suggestedQuality': 'large'});
	});

	// Reset the video player
	$(".bl-reset").click(function(e){
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);
		clearInputs();

		player.loadVideoById(vid, 0, "large")
	});

});

function addAction(){
		$("a[rel*=leanModal]").click(function(e){
		

		if($(this).attr('data-u') !== undefined){
			// Get source URL for video
			var url = $(this).attr('data-u');

			// Update source URL in the modal dialog box
			$("#bl iframe").attr('src', url);
			$(".bl-srcURL").attr('href', url);
			$(".bl-srcURL").text(url);

			clearInputs();
		}else if($(this).attr('data-vid') !== undefined){
			var vid = $(this).attr('data-vid');
			var start = $(this).attr('data-start');
			var end = $(this).attr('data-end');
			var type = $(this).attr('data-type');
			var url = "http://www.youtube.com/embed/"+vid;

			$("#bl-vid iframe").attr('src', url);
			playerV.loadVideoById({'videoId': vid, 'startSeconds': start, 'endSeconds': end, 'suggestedQuality': 'large'});


		}

	});

}



// clear input fields
function clearInputs(){
	$("input[name='bl-end']").val('');
	$("input[name='bl-start']").val('');
	$("input[name='bl-start']").removeClass("bl-incorrect");
	$("input[name='bl-end']").removeClass("bl-incorrect");
	$(".bl-URL").text("Generate URL goes here")
}

// Generate a URL for the snippet from the start and end input boxes
function generateTag() {
	var start_time = $("input[name='bl-start']").val();
	var end_time = $("input[name='bl-end']").val();
	if ((start_time < end_time || end_time === '') && (start_time !== '')) {
		$("input[name='bl-start']").removeClass("bl-incorrect");
		$("input[name='bl-end']").removeClass("bl-incorrect");
		var url = player.getVideoUrl();
		var vid = getVideoIdFromURL(url);
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
		addAction();

	}else{
		$("input[name='bl-start']").addClass("bl-incorrect");
		$("input[name='bl-end']").addClass("bl-incorrect");
	}
}


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

	playerV = new YT.Player('playerV', {
          events: {

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

