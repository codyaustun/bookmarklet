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
  @generateHtml: true
  @modalID: "" # bl or bl-vid
  @clipper: ""
  @clippers: []
  @prepared:
    snippet: false

  constructor: (obj)->
    obj = obj or {}
    @reel = obj.reel or VideoClipper.reel
    @answerClass = obj.answerClass or VideoClipper.answerClass
    @textareaID = obj.textareaID
    @videoId = obj.videoId or @videoId
    @videoType = obj.videoType or @videoType
    @buttonID = obj.buttonID or "bl-"+@videoType + @videoId

    # The variables below can be false, so or can't be used
    @generate = if obj.generate != undefined then obj.generate else VideoClipper.generateHtml


    # Condition mainly used for testing
    @setup() if @generate

    VideoClipper.clippers = VideoClipper.clippers.concat(this)

  generateQuestionBox: () =>
    element = $("#"+@textareaID)
    w = element.width()
    h = element.height()
    content = element.val()

    # Newly created div for answer input
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

    that = this

    # TODO: Add tests
    @questionBox.find('[rel*=blModal]').click ->
      VideoClipper.openModal this, that

    # TODO: Add tests
    @questionBox.find('[rel*=blModal]').each (index, element) ->
      data = VideoClipper.getBLData $(element)

      startTime = VideoClipper.secondsToTime(data.start)
      endTime = VideoClipper.secondsToTime(data.end)

      $(element).qtip
        style:
          classes: 'qtip-rounded qtip-dark'
        content:
          text: "Start: #{startTime} - End: #{endTime}"
          
  @checkErrors: =>
    startTime = parseFloat(@getStartTime())
    endTime = parseFloat(@getEndTime())
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
    @prepared.snippet = false
    clipper.questionBox.remove() for clipper in @clippers when clipper.questionBox?
    return this

  @clearInputs: =>
    @setStartTime ""
    @setEndTime ""
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
    else 
      @playerV.stopVideo()  if modalID is "#bl-vid"
    return this

  @generate: (clipper)->
    @generateSnippetBox(clipper) if clipper?
    @generateVideoBox()
    @generateOverlay()

    that = this

    if !clipper?
      $('[rel*=blModal]').click ->
        that.openModal this

      # TODO: Add tests
      $('[rel*=blModal]').each (index, element) ->
        data = VideoClipper.getBLData $(element)

        startTime = VideoClipper.secondsToTime(data.start)
        endTime = VideoClipper.secondsToTime(data.end)

        $(element).qtip
          style:
            classes: 'qtip-rounded qtip-dark'
          content:
            text: "Start: #{startTime} - End: #{endTime}"

    return that

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
              <h1>Create a Clip</h1>
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
        that.setStartTime currTime
        that.checkErrors()
        return

      $(".bl-end").click (e) =>
        currTime = @player.getCurrentTime()
        that.setEndTime currTime
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

      @prepared.snippet = true

    return this

  @generateTag: (clipper) =>

    # Get in and out points
    clipper.startTime = @getStartTime()
    clipper.endTime = @getEndTime()

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

      clipper.clips = clipper.clips.concat(newTag)

      return newTag
    else
      return ""

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

    @closeModal()

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
        @player = new OmniPlayer
          elementId: "bl-player"
          videoId: clipper.videoId
          type: clipper.videoType
          events: {}
      else
        @player.cueVideoById clipper.videoId, 0, "large"
    else
      videoId = blData.video.id
      startTime = blData.start
      endTime = blData.end
      videoType = blData.video.type

      if @playerV is false
        @playerV = new OmniPlayer
          elementId: "bl-playerV"
          videoId: videoId
          type: videoType
          startSeconds: startTime
          endSeconds: endTime
      else

        # OPTIMIZE: This works, 
        #   but it would be nice if it didn't need to delete the video
        if @playerV.videoId != videoId
          @playerV.cueVideoById
            videoId: videoId
            startSeconds: startTime
            endSeconds: endTime
            suggestedQuality: "large"
        else
          @playerV.remove()
          @playerV = new OmniPlayer(
            elementId: "bl-playerV"
            videoId: videoId
            type: videoType
            startSeconds: startTime
            endSeconds: endTime
          )

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

  # TODO: Add tests
  @secondsToTime: (seconds) ->
    if seconds == ""
      return seconds
    else
      seconds = parseFloat(seconds).toFixed(2)

      hours = parseInt(seconds / 3600)
      minutes = parseInt(seconds / 60) % 60
      seconds = seconds % 60

      result = ""

      if hours > 0
        minutes = "0#{minutes}" if (minutes / 10) < 1
        seconds = "0#{seconds}" if (seconds / 10) < 1
        result = "#{hours}:#{minutes}:#{seconds}"
      else if minutes > 0
        seconds = "0#{seconds}" if (seconds / 10) < 1
        result = "#{minutes}:#{seconds}"
      else
        result = "#{seconds}"

      return result

  # TODO: Add tests
  @timeToSeconds: (time) ->
    amounts = time.split(':')
    seconds = 0

    len = amounts.length
    for amount, index in amounts
      seconds += parseFloat(amount)*Math.pow(60, len-(index+1))

    return seconds.toFixed(2)

  # TODO: Add tests
  @getEndTime: ->
    val = $("input[name='bl-end']").val() 
    return @timeToSeconds(val)

  # TODO: Add tests
  @getStartTime: ->
    val = $("input[name='bl-start']").val()
    return @timeToSeconds(val)

  # TODO: Add tests
  @setEndTime: (val) ->
    console.log val
    val = @secondsToTime val
    $("input[name='bl-end']").val val
    return val

  # TODO: Add tests
  @setStartTime: (val) ->
    val = @secondsToTime val
    $("input[name='bl-start']").val val
    return val




