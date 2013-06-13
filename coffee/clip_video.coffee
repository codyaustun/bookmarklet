class window.VideoClipper

  start_time: ""
  end_time: ""
  modal_id: ""
  player: false
  playerV: false
  caretPos: 0

  reel: 'http://web.mit.edu/colemanc/www/bookmarklet/images/film3Small.png'
  answer_class: "bookMarklet-answer"
  button: true
  vid: "" # video id
  video_type: "" # YouTube, TechTV etc.

  constructor: (obj)->
    obj = obj or {}
    @reel = obj.reel or @reel
    @answer_class = obj.answerClass or @answer_class
    @textareaid = obj.textareaid
    @button = obj.button or @button
    @vid = obj.videoID or @vid
    @video_type = obj.videoType or @video_type


    @setup()


  # Set up event listeners and elements for video clipping
  setup: =>
    @generateOutputBox()
    that = this
    @generateSnippetBox()  if $("#bl").length is 0
    @generateVideoBox()  if $("#bl-vid").length is 0
    $("<div id='bookMarklet-overlay'></div>").appendTo "body"  if $("#bookMarklet-overlay").length is 0
    $("#bookMarklet-overlay").click =>
      @close_modal @modal_id

    $(document).on "click", "." + @answer_class, ->
      that.caretPos = that.getCaretPosition(this)
      return

    $(document).on "keyup", "." + @answer_class, ->
      that.caretPos = that.getCaretPosition(this)
      div_text = $(this).html()
      $(this).prev().val div_text
      return

    $(document).on "click", "[rel*=blModal]", ->
      that.open_modal this
      return

    $(".bl-start").click (e) =>
      curr_time = @player.getCurrentTime()
      $("input[name='bl-start']").val curr_time
      that.checkErrors()
      return

    $(".bl-end").click (e) =>
      curr_time = @player.getCurrentTime()
      $("input[name='bl-end']").val curr_time
      that.checkErrors()
      return

    $(".bl-done").click (e) =>
      that.close_modal @modal_id
      that.update that.generateTag()
      return

    $(".bl-reset").click (e) =>
      that.clearInputs()
      @player.loadVideoById @vid, 0, "large"
      return

  close_modal: (modal_id) =>
    $("#bookMarklet-overlay").fadeOut 200
    $(modal_id).css display: "none"
    if modal_id is "#bl"
      @player.stopVideo()
    else @playerV.stopVideo()  if @modal_id is "#bl-vid"

  open_modal: (el) =>
    that = this
    blData = that.getBLData(el)
    if blData.type is "generate"
      @vid = blData.video.id
      @video_type = blData.video.type
      url = ""
      url = "http://www.youtube.com/embed/" + @vid  if @video_type is "yt"
      $(".bl-srcURL").attr "href", url
      $(".bl-srcURL").text url
      that.clearInputs()
      if @player is false
        @player = new window.YT.Player("bl-player",
          videoId: @vid
          events: {}
        )
      else
        @player.cueVideoById @vid, 0, "large"
    else
      @vid = blData.video.id
      @start_time = blData.start
      @end_time = blData.end
      @video_type = blData.video.type
      if @playerV is false
        @playerV = new YT.Player("bl-playerV",
          videoId: @vid
          events:
            onReady: that.YTOnPlayerReady
        )
      else
        @playerV.cueVideoById
          videoId: @vid
          startSeconds: @start_time
          endSeconds: @end_time
          suggestedQuality: "large"

    @modal_id = blData.modal
    modal_width = $(@modal_id).outerWidth()
    $("#bookMarklet-overlay").css
      display: "block"
      opacity: 0

    $("#bookMarklet-overlay").fadeTo 200, 0.5
    $(@modal_id).css
      display: "block"
      position: "fixed"
      opacity: 0
      "z-index": 11000
      left: 50 + "%"
      "margin-left": -(modal_width / 2) + "px"
      top: "100px"

    $(@modal_id).fadeTo 200, 1

  checkErrors: =>
    @start_time = parseFloat($("input[name='bl-start']").val())
    @end_time = parseFloat($("input[name='bl-end']").val())
    if (@start_time < @end_time or isNaN(@end_time)) and (not isNaN(@start_time))
      $("input[name='bl-start']").removeClass "bl-incorrect"
      $("input[name='bl-end']").removeClass "bl-incorrect"
      true
    else
      $("input[name='bl-start']").addClass "bl-incorrect"
      $("input[name='bl-end']").addClass "bl-incorrect"
      false

  getBLData: (el) =>
    blData = undefined
    if typeof ($(el).attr("data-bl")) isnt "undefined"
      blData = $.parseJSON(decodeURI($(el).attr("data-bl")))
    else blData = $.parseJSON(decodeURI($(el).text()))  if typeof ($(el).text()) isnt "undefined"
    blData


  clearInputs: =>
    $("input[name='bl-end']").val ""
    $("input[name='bl-start']").val ""
    $("input[name='bl-start']").removeClass "bl-incorrect"
    $("input[name='bl-end']").removeClass "bl-incorrect"
    $(".bl-URL").text "Generated URL goes here"

  update: (newLink) =>
    $(".bl-URL").text newLink
    blData = encodeURI(@generateBLDataString(type: "generate"))
    srcQues = "[data-bl='" + blData + "']"
    currContent = $("." + @answer_class).contents()
    newContent = []
    beginPos = 0
    endPos = 0
    if currContent.length is 0
      newContent = newLink
    else
      currContent.each (i, e) =>
        if ((e.nodeType is 3) or (e.nodeType is 1)) and (endPos < @caretPos)
          eString = ""
          if e.nodeType is 3
            eString = e.data
          else
            eString = e.text
          beginPos = endPos
          endPos = endPos + eString.length

          if endPos >= @caretPos
            front = eString.substring(0, @caretPos - beginPos)
            back = eString.substring(@caretPos - beginPos, eString.length)
            newContent = newContent.concat(front)
            newContent = newContent.concat(newLink)
            newContent = newContent.concat(back)
            return
          else
            newContent = newContent.concat(e)
            return
        else
          newContent = newContent.concat(e)
          return

    $("." + @answer_class).text ""
    $(newContent).each (i, e) =>
      $("." + @answer_class).append e

    newVal = $("." + @answer_class).html()
    $("." + @answer_class).prev().val newVal

  YTOnPlayerReady: (event) =>
    event.target.cueVideoById
      videoId: @vid
      startSeconds: @start_time
      endSeconds: @end_time
      suggestedQuality: "large"

  @setup_yt: ->
    tag = document.createElement("script")
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName("script")[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

  generateOutputBox: () =>
    element = $("#"+@textareaid)
    w = element.width()
    h = element.height()
    content = element.val()
    @outputBox = element.after("<div></div>").css("display", "none").next()

    @outputBox.attr(contenteditable: "true").addClass(@answer_class).css
      width: w
      height: h

    dataString = @generateBLDataString(
      type: "generate"
      vid: @videoid
      vtype: @video_type
    )
    blDataEncoded = encodeURI(dataString)
    if @button
      @outputBox.after("<input type='button' value='Snippet'>").next().attr
        "data-bl": blDataEncoded
        rel: "blModal"

  generateTag: =>

    # Get in and out points
    @start_time = $("input[name='bl-start']").val()
    @end_time = $("input[name='bl-end']").val()

    # Check for errors and proceed
    if @checkErrors()

      # Default for end_time is an empty string
      @end_time = @player.getDuration()  if @end_time is ""

      # Generate an anchor tag with encoded JSON as text
      newTag = ""
      dataString = @generateBLDataString(type: "show")
      blDataEncoded = encodeURI(dataString)
      newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>"+ blDataEncoded+ "</a>").css
        'background-image': @reel
      return newTag
    else
      # If there are errors with the start and end times return an empty string
      return ""

  generateBLDataString: (obj) =>
    obj = obj or {}
    dataString = ""
    dataVid = obj.vid or @vid
    dataVType = obj.vtype or @video_type
    if obj.type is "generate"
      dataString = "{\"type\": \"generate\", \"modal\": \"#bl\"," + "\"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    else if obj.type is "show"
      dataStart = obj.start or @start_time
      dataEnd = obj.end or @end_time
      dataString = "{\"start\": \"" + dataStart + "\", \"end\": \"" + dataEnd + "\", \"type\": \"show" + "\", \"modal\": \"#bl-vid" + "\", \"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    dataString

  generateVideoBox: =>
    $("""
      <div id='bl-vid'>
        <div class='bl-video-wrap'>
          <div id='bl-playerV'></div>
        </div>
      </div>
      """).appendTo "body"

  generateSnippetBox: =>
    $("""
      <div id='bl'>
        <div class='bl-top'>
          <div class='bl-vid'>
            <div id='bl-player'></div>
          </div>
          <div class='bl-controls'>
            <div class='bl-title'>
              <h1>Create a URL</h1>
            </div>
            <div class='bl-instructions'>
              Click \"Start Time\" and \"End Time\" buttons,or by type in the time in the text boxes.
            </div>
            <table class='bl-input'>
              <tr>
                <td>
                  <input class='bl-button bl-start' type='button' value='Start Time'>
                </td>
                <td>
                </td>
                <td>
                  <input class='bl-button bl-end' type='button' value='End Time'>
                </td>
              </tr>
              <tr>
                <td>
                  <input class='bl-data' type='text' name='bl-start'>
                </td>
                <td>
                  -
                </td>
                <td>
                  <input class='bl-data' type='text' name='bl-end'>
                </td>
              </tr>
              <tr>
                <td>
                  <input class='bl-button bl-done' type='button' value='Done'>
                </td>
                <td>
                </td>
                <td>
                  <input class='bl-button bl-reset' type='button' value='Reset'>
                </td>
              </tr>
            </table>
            <textarea class='bl-URL'>
              Generated URL goes here
            </textarea>
          </div>
        </div>
        <div class='bl-bottom'>
          Source URL:<a class='bl-srcURL'></a>
        </div>
      </div>
      """).appendTo "body"

  getCaretPosition: (editableDiv) =>
    @caretPos = 0
    containerEl = null
    sel = undefined
    range = undefined
    if window.getSelection
      sel = window.getSelection()
      if sel.rangeCount
        range = sel.getRangeAt(0)
        if range.commonAncestorContainer.parentNode is editableDiv
          temp1 = range.endContainer.data
          temp2 = range.commonAncestorContainer.parentNode.innerHTML.replace(/&nbsp;/g, String.fromCharCode(160))
          temp2 = @stripHTML(temp2)
          @caretPos = range.endOffset + temp2.split(temp1)[0].length
    @caretPos

  stripHTML: (html) ->
    tmp = document.createElement("DIV")
    tmp.innerHTML = html
    tmp.textContent or tmp.innerText


