class @VideoClipper

  # Instance Variables
  startTime: ""
  endTime: ""
  caretPos: 0
  answerClass: ""
  videoId: "" # video id
  videoType: "" # YT, TEST
  generate: true
  buttonID: ""
  textareaID: ""
  clips: []
  questionBox = null # the question box as a jQuery object
  snippetButton = null # the button to open snippet box as a jQuery object

  # Class Variables 
  @reel: 'http://web.mit.edu/colemanc/www/bookmarklet/images/film3Small.png'
  @player: false
  @playerV: false
  @answerClass: "bookMarklet-answer"
  @generate: true
  @modalID: "" # bl or bl-vid
  @clipper: ""
  @clippers: []
  @prepared:
    snippet: false

  constructor: (obj)->
    obj = obj or {}
    @reel = obj.reel or VideoClipper.reel # instance
    @answerClass = obj.answerClass or VideoClipper.answerClass # instance
    @textareaID = obj.textareaID # instance
    @videoId = obj.videoId or @videoId # instance
    @videoType = obj.videoType or @videoType # instance

    @generate = if obj.generate != undefined then obj.generate else VideoClipper.generate #instance 
    @buttonID = if obj.buttonID != undefined then obj.buttonID else "bl-"+@videoType + @videoId # instance

    @setup() if @generate

    VideoClipper.clippers = VideoClipper.clippers.concat(this)

  generateQuestionBox: () =>
    element = $("#"+@textareaID)
    w = element.width()
    h = element.height()
    content = element.val()
    @questionBox = element.after("<div></div>").css("display", "none").next()

    @questionBox.attr(contenteditable: "true").addClass(@answerClass).css
      width: w
      height: h

    dataString = VideoClipper.generateBLDataString "generate", this

    blDataEncoded = encodeURI(dataString)

    if $('#'+@buttonID).length > 0
      $('#'+@buttonID).attr
        "data-bl": blDataEncoded
        rel: "blModal"
    else
      @questionBox.after("<input type='button' value='Snippet'>").next().attr
        "data-bl": blDataEncoded
        rel: "blModal"
        id: @buttonID

    that = this

    @snippetButton = $('#'+@buttonID)

    @snippetButton.click ->
      VideoClipper.openModal this, that
      return

  # TODO: Add tests
  getCaretPosition: (editableDiv) =>
    @caretPos = 0
    containerEl = null
    sel = undefined
    range = undefined
    if window.getSelection?
      sel = window.getSelection()
      if sel.rangeCount
        range = sel.getRangeAt(0)
        if range.commonAncestorContainer.parentNode is editableDiv
          temp1 = range.endContainer.data
          temp2 = range.commonAncestorContainer.parentNode.innerHTML.replace(/&nbsp;/g, String.fromCharCode(160))
          temp2 = VideoClipper.stripHTML(temp2)
          @caretPos = range.endOffset + temp2.split(temp1)[0].length
    @caretPos

  setup: =>
    @generateQuestionBox()
    VideoClipper.generate(this)

  # TODO: Add tests
  update: (newTag) =>
    $(".bl-URL").text newTag
    currContent = @questionBox.contents()
    newContent = []
    beginPos = 0
    endPos = 0
    if currContent.length is 0
      newContent = newTag
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
            newContent = newContent.concat(newTag)
            newContent = newContent.concat(back)
            return
          else
            newContent = newContent.concat(e)
            return
        else
          newContent = newContent.concat(e)
          return

    @questionBox.text ""
    $(newContent).each (i, e) =>
      @questionBox.append e

    newVal = @questionBox.html()
    @questionBox.prev().val newVal

  # TODO: Add Tests
  @generate: (clipper)->
    @generateSnippetBox(clipper) if clipper?
    @generateVideoBox()
    @generateOverlay()

    that = this

    if clipper?
      clipper.questionBox.on 'click', '[rel*=blModal]', ->
        that.openModal this, clipper
        return
    else
      $(document).on 'click', '[rel*=blModal]', ->
        that.openModal this
        return
    return that

  @checkErrors: =>
    startTime = parseFloat($("input[name='bl-start']").val())
    endTime = parseFloat($("input[name='bl-end']").val())
    if (startTime < endTime or isNaN(endTime)) and (not isNaN(startTime))
      $("input[name='bl-start']").removeClass "bl-incorrect"
      $("input[name='bl-end']").removeClass "bl-incorrect"
      true
    else
      $("input[name='bl-start']").addClass "bl-incorrect"
      $("input[name='bl-end']").addClass "bl-incorrect"
      false

  @cleanUp: =>
    $('#bl').remove()
    $('#bl-vid').remove()
    $("#bookMarklet-overlay").remove()

    # TODO: Add test
    @prepared.snippet = false
    # TODO: Add removequestionBox Function

    return this

  @clearInputs: =>
    $("input[name='bl-end']").val ""
    $("input[name='bl-start']").val ""
    $("input[name='bl-start']").removeClass "bl-incorrect"
    $("input[name='bl-end']").removeClass "bl-incorrect"
    $(".bl-URL").text "Generated URL goes here"

    return this

  @closeModal: (modalID) =>
    modalID = modalID or @modalID
    $("#bookMarklet-overlay").fadeOut 200
    $(modalID).css display: "none"
    if modalID is "#bl"
      @player.stopVideo()
    else @playerV.stopVideo()  if modalID is "#bl-vid"

    return this

  @generateTag: (clipper) =>

    # Get in and out points
    clipper.startTime = $("input[name='bl-start']").val()
    clipper.endTime = $("input[name='bl-end']").val()

    # Check for errors and proceed
    if VideoClipper.checkErrors()

      # Default for endTime is an empty string
      clipper.endTime = @player.getDuration() if isNaN parseFloat clipper.endTime 

      # Generate an anchor tag with encoded JSON as text
      newTag = ""
      dataString = @generateBLDataString "show", clipper
      # Logging for edX
      # Logger.log('video_clip', $.parseJSON(dataString));
      blDataEncoded = encodeURI(dataString)
      newTag = $("<a rel='blModal' href='#bl-vid' class='bl'>"+ blDataEncoded+ "</a>").css
        'background-image': clipper.reel

      that = this

      newTag.click ->
        that.openModal this
        return

      clipper.clips = clipper.clips.concat(newTag)

      return newTag
    else
      # If there are errors with the start and end times return an empty string
      return ""

  @generateBLDataString: (type, clipper) =>
    dataString = ""
    dataVid = clipper.videoId
    dataVType = clipper.videoType
    if type is "generate"
      dataString = "{\"type\": \"generate\", \"modal\": \"#bl\"," + "\"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    else if type is "show"
      dataStart = clipper.startTime
      dataEnd = clipper.endTime
      dataString = "{\"start\": \"" + dataStart + "\", \"end\": \"" + dataEnd + "\", \"type\": \"show" + "\", \"modal\": \"#bl-vid" + "\", \"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    
    return dataString

  @generateOverlay: =>
    $("<div id='bookMarklet-overlay'></div>").appendTo "body"  if $("#bookMarklet-overlay").length is 0
    $("#bookMarklet-overlay").click =>
      @closeModal()

    return this

  @generateSnippetBox: (clipper) =>
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
      """).appendTo("body") if $("#bl").length is 0

    that = this
    
    clipper.questionBox.click (e) ->
      clipper.caretPos = clipper.getCaretPosition(this)
      return

    clipper.questionBox.keyup (e) ->
      clipper.caretPos = clipper.getCaretPosition(this)
      divText = $(this).html()
      $(this).prev().val divText
      return

    if !@prepared.snippet
      $(".bl-start").click (e) =>
        currTime = @player.getCurrentTime()
        $("input[name='bl-start']").val currTime
        that.checkErrors()
        return

      $(".bl-end").click (e) =>
        currTime = @player.getCurrentTime()
        $("input[name='bl-end']").val currTime
        that.checkErrors()
        return

      $(".bl-done").click (e) =>
        that.closeModal()
        that.clipper.update that.generateTag(that.clipper)
        return

      $(".bl-reset").click (e) =>
        VideoClipper.clearInputs()
        @player.loadVideoById that.clipper.videoId, 0, "large"
        return

      # TODO: Add test
      @prepared.snippet = true

    return this

  @generateVideoBox: =>
    $("""
      <div id='bl-vid'>
        <div class='bl-video-wrap'>
          <div id='bl-playerV'></div>
        </div>
      </div>
      """).appendTo("body") if $("#bl-vid").length is 0

    return this

  @getBLData: (el) =>
    blData = undefined
    if typeof ($(el).attr("data-bl")) isnt "undefined"
      blData = $.parseJSON(decodeURI($(el).attr("data-bl")))
    else blData = $.parseJSON(decodeURI($(el).text()))  if typeof ($(el).text()) isnt "undefined"
    blData

  @openModal: (element, clipper) =>
    that = this
    blData = that.getBLData(element)

    @clipper = clipper

    if blData.type is "generate"
      clipper.videoId = blData.video.id
      clipper.videoType = blData.video.type

      url = ""
      url = "http://www.youtube.com/embed/" + clipper.videoId  if clipper.videoType is "YT"
      $(".bl-srcURL").attr "href", url
      $(".bl-srcURL").text url
      @clearInputs()
      if @player is false
        @player = new OmniPlayer(
          elementId: "bl-player"
          videoId: clipper.videoId
          type: clipper.videoType
          events: {}
        )
      else
        @player.cueVideoById clipper.videoId, 0, "large"
    else
      videoId = blData.video.id
      startTime = blData.start
      endTime = blData.end
      videoType = blData.video.type

      if @playerV is false
        @playerV = new OmniPlayer(
          elementId: "bl-playerV"
          videoId: videoId
          type: videoType
          startSeconds: startTime
          endSeconds: endTime
        )
      else

        # This is working. It isn't loading video start and end points
        @playerV.cueVideoById
          videoId: videoId
          startSeconds: startTime
          endSeconds: endTime
          suggestedQuality: "large"

    @modalID = blData.modal
    modalWidth = $(@modalID).outerWidth()
    $("#bookMarklet-overlay").css
      display: "block"
      opacity: 0

    $("#bookMarklet-overlay").fadeTo 200, 0.5
    $(@modalID).css
      display: "block"
      position: "fixed"
      opacity: 0
      "z-index": 11000
      left: 50 + "%"
      "margin-left": -(modalWidth / 2) + "px"
      top: "100px"

    $(@modalID).fadeTo 200, 1

    return this

  @stripHTML: (html) ->
    tmp = document.createElement("DIV")
    tmp.innerHTML = html
    tmp.textContent or tmp.innerText


