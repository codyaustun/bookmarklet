var bookMarklet = (function() {
	"use strict";

	var vid = "";
	var start_time = "";
	var end_time = "";
	var video_type = "";
	var answer_class = "bookMarklet-answer";
	var reel = false;
	var modal_id = "";
	var player = false;
	var playerV = false;
	var caretPos = 0;

	return {
		start: function (){

			var that = this;

			if($("#bl").length === 0){
				this.generateSnippetBox();
			}

			if($("#bl-vid").length === 0){
				this.generateVideoBox();
			}
			if($("#bookMarklet-overlay").length === 0){
				$("<div id='bookMarklet-overlay'></div>").appendTo("body");
			}

			$("#bookMarklet-overlay").click(function() {
				that.close_modal(modal_id);
			});

			this.addActions();

			$(".bl-start").click(function(e){
				var curr_time = player.getCurrentTime();
				$("input[name='bl-start']").val(curr_time);
				that.checkErrors();
			});


			$(".bl-end").click(function(e){
				var curr_time = player.getCurrentTime();
				$("input[name='bl-end']").val(curr_time);
				that.checkErrors();
			});


			$(".bl-done").click(function(e){
				that.close_modal(modal_id);
				that.update(that.generateTag());
			});

			$(".bl-reset").click(function(e){
				that.clearInputs();
				player.loadVideoById(vid, 0, "large");
			});
		},

		close_modal: function(modal_id){
			$("#bookMarklet-overlay").fadeOut(200);
			$(modal_id).css({ 'display' : 'none' });
			if(modal_id === "#bl"){
				player.stopVideo();
			}else if(modal_id === '#bl-vid'){
				playerV.stopVideo();
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

		create: function(textareaid, videotype, videoid, button, reelPic){

			// reel = 1 -> film
			// reel = 2 -> director thing
			// reel = 3 -> film reel
			// reel = false || undefined -> "Start Time"-"End Time"
			reel = reelPic;

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
					.addClass(answer_class)
					.css({
						width: w,
						height: h
					});

			});

			var dataString = this.generateBLDataString({type: 'generate',
				vid: videoid,
				vtype: videotype});

			var blDataEncoded = encodeURI(dataString);

			if(button){
				$("."+answer_class).after("<input type='button' value='Snippet'>")
					.next()
					.attr({
						"data-bl": blDataEncoded,
						rel: "blModal"
					});
			}
		},

		getBLData: function(el){
			var blData;

			if(typeof($(el).attr('data-bl')) !== 'undefined'){
				blData = $.parseJSON(decodeURI($(el).attr("data-bl")));

			}else{
				blData = $.parseJSON(decodeURI($("img", el).attr("info")));
			}

			return blData;
		},

		modalOpen: function(el){

			var that = this;

			var blData = that.getBLData(el);

			// Everything else
			if(blData.type === "generate"){

				vid = blData.video.id;
				video_type = blData.video.type;

				var url = "";

				if(video_type === "yt"){
					url = "http://www.youtube.com/embed/"+vid;
				}

				$(".bl-srcURL").attr('href', url);
				$(".bl-srcURL").text(url);

				that.clearInputs();

				if(player === false){
					player = new window.YT.Player('bl-player', {
							videoId: vid,
							events: {
						}
					});
				}else{
					player.cueVideoById(vid, 0, "large");
				}

			}else{

				vid = blData.video.id;
				start_time = blData.start;
				end_time = blData.end;
				video_type = blData.video.type;

				console.log(vid);
				console.log(video_type);
				console.log(end_time);
				console.log(start_time);


				// TO DO: Generalize this
				// Create a YouTube player object for the modal dialog window
				if(playerV === false){
					playerV = new YT.Player('bl-playerV', {
						videoId: vid,
							events: {
								// Once "playerV" is ready this cues the snippet to play
								'onReady': that.YTOnPlayerReady
							}
					});
				}else{
					playerV.cueVideoById({
						'videoId': vid,
						'startSeconds': start_time,
						'endSeconds': end_time,
						'suggestedQuality': 'large'});
				}
			}


			// Modal Window
			modal_id = blData.modal;
			var modal_width = $(modal_id).outerWidth();

			$("#bookMarklet-overlay").css({'display' : 'block', opacity: 0});
			$("#bookMarklet-overlay").fadeTo(200,0.5);

			$(modal_id).css({
				'display' : 'block',
				'position' : 'fixed',
				'opacity' : 0,
				'z-index': 11000,
				'left' : 50 + '%',
				'margin-left' : -(modal_width/2) + "px",
				'top' : "100px"
			});

			$(modal_id).fadeTo(200,1);
		},

		addActions: function(){
			var that = this;

			// Caret Position
			$(document).on("click", "."+answer_class, function(){
				caretPos = that.getCaretPosition(this);
			});

			$(document).on("keyup", "."+answer_class, function(){
				caretPos = that.getCaretPosition(this);
				var div_text = $(this).html();
				$(this).prev().val(div_text);
			});

			$(document).on("click","[rel*=blModal]" ,function(){
				that.modalOpen(this);
			});
		},

		clearInputs: function(){
			$("input[name='bl-end']").val('');
			$("input[name='bl-start']").val('');
			$("input[name='bl-start']").removeClass("bl-incorrect");
			$("input[name='bl-end']").removeClass("bl-incorrect");
			$(".bl-URL").text("Generate URL goes here");
		},

		update: function(newLink){
			$(".bl-URL").text(newLink);

			var blData = encodeURI(this.generateBLDataString({type: "generate"}));
			var srcQues = "[data-bl='"+blData+"']";

			var currContent = $(srcQues).prev("."+answer_class).contents();
			var newContent = [];
			var beginPos = 0;
			var endPos = 0;

			currContent.each(function(i,e){
				if((this.nodeType === 3) && (endPos < caretPos) ){
					var eString = e.data;
					beginPos = endPos;
					endPos = endPos + eString.length;

					// console.log(eString);
					// console.log("Element Length: "+eString.length);
					// console.log("beginPos: "+beginPos);
					// console.log("endPos: "+endPos);
					// console.log("caretPos: "+caretPos);

					if(endPos >= caretPos){
						var front = eString.substring(0, caretPos - beginPos);
						var back = eString.substring(caretPos - beginPos, eString.length);
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

			$(srcQues).prev("."+answer_class).text("");
			$(srcQues).prev("."+answer_class).append(newContent);


			var oldVal = $(srcQues).prev("."+answer_class).prev().val();
			$(srcQues).prev("."+answer_class).prev().val(oldVal + newLink);

		},

		// YT specific
		YTOnPlayerReady: function(event) {
			event.target.cueVideoById({'videoId': vid,
				'startSeconds': start_time,
				'endSeconds': end_time,
				'suggestedQuality': 'large'});
		},

		setup_yt: function(){
			var tag = document.createElement('script');
			tag.src = "https://www.youtube.com/iframe_api";
			var firstScriptTag = document.getElementsByTagName('script')[0];
			firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
		},

		generateURL: function(){
			var baseURL = "TO DO";
		},

		generateTag: function() {
			start_time = $("input[name='bl-start']").val();
			end_time = $("input[name='bl-end']").val();

			if (this.checkErrors()) {
				$("input[name='bl-start']").removeClass("bl-incorrect");
				$("input[name='bl-end']").removeClass("bl-incorrect");


				if(end_time === ""){
					end_time = player.getDuration();
				}

				var start = new Date(null);
				var end = new Date(null);
				start.setSeconds(start_time);
				end.setSeconds(end_time);
				start = start.toTimeString().substr(3,5);
				end = end.toTimeString().substr(3,5);


				var display = "";
				var dataString = this.generateBLDataString({type:"show"});
				var blDataEncoded = encodeURI(dataString);

				if(reel){
					display = "<img alt='video snippet' src='"+
						"images/film"+reel+"Small.png"+
						"' info='"+
						blDataEncoded+"'>";
				}else{
					display = start +"-"+ end;
				}

				var newLink = "<a rel='blModal' href='#bl-vid'>"+display+"</a>";

				return newLink;

			}else{
				return "";
			}
		},

		generateBLDataString: function(obj){
			var dataString = "";
			var dataVid = obj.vid || vid;
			var dataVType = obj.vtype || video_type;

			if(obj.type === 'generate'){

				dataString = '{"type": "generate", "modal": "#bl",'+
					'"video": {'+
					'"id": "'+dataVid+
					'", "type": "'+dataVType+
					'"}}';

			}else if(obj.type === 'show'){
				var dataStart = obj.start || start_time;
				var dataEnd = obj.end || end_time;

				dataString = '{"start": "'+dataStart+
					'", "end": "'+dataEnd+
					'", "type": "show'+
					'", "modal": "#bl-vid'+
					'", "video": {'+
					'"id": "'+dataVid+
					'", "type": "'+dataVType+
					'"}}';


			}

			return dataString;
		},

		generateVideoBox: function(){
			$("<div id='bl-vid'><div class='bl-video-wrap'>"+
				"<div id='bl-playerV'></div>"+
				"</div></div>").appendTo("body");
		},

		generateSnippetBox: function(){
			$("<div id='bl'>"+
				"<div class='bl-top'>"+
				"<div class='bl-vid'>"+
				"<div id='bl-player'></div>"+
				"</div>"+
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
						var temp2 = range.commonAncestorContainer.
						parentNode.innerHTML.
						replace(/&nbsp;/g, String.fromCharCode(160));
						// var temp2 = range.commonAncestorContainer.parentNode.innerText
						temp2 = this.stripHTML(temp2);

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
		},

		stripHTML: function(html){
			var tmp = document.createElement("DIV");
			tmp.innerHTML = html;
			return tmp.textContent || tmp.innerText;
		}

	};

}());

bookMarklet.setup_yt();
// Create a YouTube player object for the modal dialog window
function onYouTubeIframeAPIReady() {
	$(document).ready(function(){
		bookMarklet.start();
	});
}






