var bookMarklet = 
{	

	vid: "",
	start_time: "",
	end_stime: "",
	video_type: "",
	answer_class: "bookMarklet-answer",
	reel: false,
	modal_id: "",
	player: false,
	playerV: false,
	caretPos: 0,

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
			bookMarklet.close_modal(bookMarklet.modal_id); 
			bookMarklet.update(bookMarklet.generateTag());
			
		});

		$(".bl-reset").click(function(e){
			bookMarklet.clearInputs();
			bookMarklet.player.loadVideoById(bookMarklet.vid, 0, "large");
		});
	},

	close_modal: function(modal_id){
		$("#bookMarklet-overlay").fadeOut(200);
		$(modal_id).css({ 'display' : 'none' });
		if(modal_id === "#bl"){
			bookMarklet.player.stopVideo();
		}else if(modal_id === '#bl-vid'){
			bookMarklet.playerV.stopVideo();
		}
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
				.css("display","none")
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
					"data-bl-modal": "#bl",
					"data-bl": "generate",
					"data-bl-vid": videoid,
					"data-bl-type": videotype
				});
		}
	},

	addActions: function(){
		$(document).on("click", "."+bookMarklet.answer_class, function(){
			bookMarklet.caretPos = bookMarklet.getCaretPosition(this);
		});

		$(document).on("keyup", "."+bookMarklet.answer_class, function(){
			bookMarklet.caretPos = bookMarklet.getCaretPosition(this);
		});

		$(document).on("click","[rel*=blModal]" ,function(){

			// Modal Window
			bookMarklet.modal_id = $(this).attr("data-bl-modal");

            var modal_width = $(bookMarklet.modal_id).outerWidth();

            $("#bookMarklet-overlay").css({'display' : 'block', opacity: 0});
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


        	// Everything else
			if($(this).attr('data-bl') === "generate"){



				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.video_type = $(this).attr('data-bl-type');

				var url = "";

				if(bookMarklet.video_type === "yt"){
					url = "http://www.youtube.com/embed/"+bookMarklet.vid;
				}

				$(".bl-srcURL").attr('href', url);
				$(".bl-srcURL").text(url);

				bookMarklet.clearInputs();

				if(bookMarklet.player === false){
					bookMarklet.player = new window.YT.Player('bl-player', {
							videoId: bookMarklet.vid,
							events: {
						}
					});
				}else{
					bookMarklet.player.cueVideoById(bookMarklet.vid, 0, "large");
				}

			}else if($(this).attr('data-bl') === "show"){

				bookMarklet.vid = $(this).attr('data-bl-vid');
				bookMarklet.start_time = $(this).attr('data-bl-start');
				bookMarklet.end_time = $(this).attr('data-bl-end');
				bookMarklet.video_type = $(this).attr('data-bl-type');


				// TO DO: Generalize this
				// Create a YouTube player object for the modal dialog window
				if(bookMarklet.playerV === false){
					bookMarklet.playerV = new YT.Player('bl-playerV', {
						videoId: bookMarklet.vid,
				    	events: {
				          	// Once "playerV" is ready this cues the snippet to play
				         	'onReady': bookMarklet.YTOnPlayerReady
				        }
				    });
				}else{
					bookMarklet.playerV.cueVideoById({'videoId': bookMarklet.vid,
	        			'startSeconds': bookMarklet.start_time,
	         			'endSeconds': bookMarklet.end_time, 
	         			'suggestedQuality': 'large'});
				}

			}

		});
	},

	clearInputs: function(){
		$("input[name='bl-end']").val('');
		$("input[name='bl-start']").val('');
		$("input[name='bl-start']").removeClass("bl-incorrect");
		$("input[name='bl-end']").removeClass("bl-incorrect");
		$(".bl-URL").text("Generate URL goes here");
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

			var text = "";

			if(bookMarklet.reel){
				text = "<img alt='video snippet' src='"+
					"images/film"+bookMarklet.reel+"Small.png"+
				"'>";
			}else{
				text = start +"-"+ end;
			}

			var newLink = "<a rel='blModal' data-bl-start='"+start_time+
				"' data-bl-end='"+end_time+"' data-bl-type='"+
				bookMarklet.video_type+"' data-bl-vid='" + 
				bookMarklet.vid +
				"' href='#bl-vid' data-bl='show'"+
				" data-bl-modal='#bl-vid'>"+text+
				"</a>";

			

			return newLink;

		}else{
			return "";
		}
	},

	update: function(newLink){
		$(".bl-URL").text(newLink);

		var srcQues = "[data-bl-vid='"+bookMarklet.vid+"'][data-bl-type='"+
			bookMarklet.video_type+"']";

		var currContent = $(srcQues).prev("."+bookMarklet.answer_class).contents();
		var newContent = [];
		var beginPos = 0;
		var endPos = 0;

		currContent.each(function(i,e){
			if((this.nodeType === 3) && (endPos < bookMarklet.caretPos) ){
				var eString = e.data;
				beginPos = endPos;
				endPos = endPos + eString.length;

				// console.log(eString);
				// console.log("Element Length: "+eString.length);
				// console.log("beginPos: "+beginPos);
				// console.log("endPos: "+endPos);
				// console.log("caretPos: "+bookMarklet.caretPos);

				if(endPos >= bookMarklet.caretPos){
					front = eString.substring(0, bookMarklet.caretPos - beginPos);
					back = eString.substring(bookMarklet.caretPos - beginPos, eString.length);
					newContent = newContent.concat(front);
					newContent = newContent.concat(newLink);
					newContent = newContent.concat(back);

				}else{
					newContent = newContent.concat(e);
				}
			}else{
				newContent = newContent.concat(e);
			}
		});

		// var textPos = 0;
		

		$(srcQues).prev("."+bookMarklet.answer_class).text("");
		// $(srcQues).prev("."+bookMarklet.answer_class).append(newLink);
		$(srcQues).prev("."+bookMarklet.answer_class).append(newContent);
	},

	YTOnPlayerReady: function(event) {
	    event.target.cueVideoById({'videoId': bookMarklet.vid,
	        'startSeconds': bookMarklet.start_time,
	    	'endSeconds': bookMarklet.end_time, 
	    	'suggestedQuality': 'large'});
	},

	setup_yt: function(){
		var tag = document.createElement('script');
		tag.src = "https://www.youtube.com/iframe_api";
		var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
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

	getCaretPosition: function(editableDiv) {
	    var caretPos = 0, containerEl = null, sel, range;
	    if (window.getSelection) {
	    	// console.log(window.getSelection());
	        sel = window.getSelection();
	        // console.log("sel.rangeCount: "+sel.rangeCount);
	        if (sel.rangeCount) {
	            range = sel.getRangeAt(0);
	            // console.log(range);
	            if (range.commonAncestorContainer.parentNode == editableDiv) {
	            	// console.log(range.commonAncestorContainer.parentNode);
	            	// console.log("editableDiv: "+editableDiv);
	            	// console.log("range.endOffset: "+range.endOffset);
	            	var temp1 = range.endContainer.data;
	            	// console.log(temp1);


	            	// only works in chrome. Firefox only has parentNode.innerhtml;
	            	var temp2 = range.commonAncestorContainer.parentNode.innerText;
	            	// console.log(temp2);
	            	// console.log(temp2.split(temp1)[0].length);
	                caretPos = range.endOffset + temp2.split(temp1)[0].length;
	            }
	        }
	    } 

	    // else if (document.selection && document.selection.createRange) {
	    //     range = document.selection.createRange();
	    //     if (range.parentElement() == editableDiv) {
	    //         var tempEl = document.createElement("span");
	    //         editableDiv.insertBefore(tempEl, editableDiv.firstChild);
	    //         var tempRange = range.duplicate();
	    //         tempRange.moveToElementText(tempEl);
	    //         tempRange.setEndPoint("EndToEnd", range);
	    //         caretPos = tempRange.text.length;
	    //     }
	    // }
	    return caretPos;
	}

}


bookMarklet.setup_yt();
// Create a YouTube player object for the modal dialog window
function onYouTubeIframeAPIReady() {
	$(document).ready(function(){
		bookMarklet.start();
	});	
};






