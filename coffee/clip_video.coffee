class @VideoClipper

  startTime: ""
  endTime: ""
  modalID: ""
  player: false
  playerV: false
  caretPos: 0

  reel: 'http://web.mit.edu/colemanc/www/bookmarklet/images/film3Small.png'
  answerClass: "bookMarklet-answer"
  button: ""
  vid: "" # video id
  videoType: "" # YouTube, TechTV etc.
  generate: true

  constructor: (obj)->
    obj = obj or {}
    @reel = obj.reel or @reel
    @answerClass = obj.answerClass or @answerClass
    @textareaID = obj.textareaID
    @vid = obj.videoID or @vid
    @videoType = obj.videoType or @videoType


    @generate = if obj.generate != undefined then obj.generate else @generate
    @buttonID = if obj.buttonID != undefined then obj.buttonID else "bl-"+@videoType + @vid

    @setup() if @generate


  # Set up event listeners and elements for video clipping
  setup: =>
    that = this

    @generateOutputBox()
    @generateSnippetBox()
    @generateVideoBox()
    @generateOverlay()

    $("." + @answerClass).click (e) ->
      that.caretPos = that.getCaretPosition(this)
      return

    $("." + @answerClass).keyup (e) ->
      that.caretPos = that.getCaretPosition(this)
      divText = $(this).html()
      $(this).prev().val divText
      return

    $(document).on "click", "[rel*=blModal]", ->
      that.openModal this
      return

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
      that.closeModal @modalID
      that.update that.generateTag()
      return

    $(".bl-reset").click (e) =>
      that.clearInputs()
      @player.loadVideoById @vid, 0, "large"
      return

  @cleanUp: =>
    $('#bl').remove()
    $('#bl-vid').remove()
    $("#bookMarklet-overlay").remove()
    return
    # add removeOutputBox Function

  closeModal: (modalID) =>
    $("#bookMarklet-overlay").fadeOut 200
    $(modalID).css display: "none"
    if modalID is "#bl"
      @player.stopVideo()
    else @playerV.stopVideo()  if @modalID is "#bl-vid"

  openModal: (el) =>
    that = this
    blData = that.getBLData(el)

    if blData.type is "generate"
      @vid = blData.video.id
      @videoType = blData.video.type
      url = ""
      url = "http://www.youtube.com/embed/" + @vid  if @videoType is "yt"
      $(".bl-srcURL").attr "href", url
      $(".bl-srcURL").text url
      that.clearInputs()
      if @player is false
        @player = new OmniPlayer(
          elementId: "bl-player"
          videoId: @vid
          type: 'YT'
          events: {}
        )
      else
        @player.cueVideoById @vid, 0, "large"
    else
      @vid = blData.video.id
      @startTime = blData.start
      @endTime = blData.end
      @videoType = blData.video.type

      if @playerV is false
        @playerV = new OmniPlayer(
          elementId: "bl-playerV"
          videoId: @vid
          type: 'YT'
          startSeconds: @startTime
          endSeconds: @endTime
        )
      else

        # This is working. It isn't loading video start and end points
        @playerV.cueVideoById
          videoId: @vid
          startSeconds: @startTime
          endSeconds: @endTime
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

  checkErrors: =>
    @startTime = parseFloat($("input[name='bl-start']").val())
    @endTime = parseFloat($("input[name='bl-end']").val())
    if (@startTime < @endTime or isNaN(@endTime)) and (not isNaN(@startTime))
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
    currContent = $("." + @answerClass).contents()
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

    $("." + @answerClass).text ""
    $(newContent).each (i, e) =>
      $("." + @answerClass).append e

    newVal = $("." + @answerClass).html()
    $("." + @answerClass).prev().val newVal

  YTOnPlayerReady: (event) =>
    event.target.cueVideoById
      videoId: @vid
      startSeconds: @startTime
      endSeconds: @endTime
      suggestedQuality: "large"

  @setupYT: ->
    tag = document.createElement("script")
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName("script")[0]
    firstScriptTag.parentNode.insertBefore tag, firstScriptTag

  generateTag: =>

    # Get in and out points
    @startTime = $("input[name='bl-start']").val()
    @endTime = $("input[name='bl-end']").val()

    # Check for errors and proceed
    if @checkErrors()

      # Default for endTime is an empty string
      @endTime = @player.getDuration()  if @endTime is ""

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
    dataVType = obj.vtype or @videoType
    if obj.type is "generate"
      dataString = "{\"type\": \"generate\", \"modal\": \"#bl\"," + "\"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    else if obj.type is "show"
      dataStart = obj.start or @startTime
      dataEnd = obj.end or @endTime
      dataString = "{\"start\": \"" + dataStart + "\", \"end\": \"" + dataEnd + "\", \"type\": \"show" + "\", \"modal\": \"#bl-vid" + "\", \"video\": {" + "\"id\": \"" + dataVid + "\", \"type\": \"" + dataVType + "\"}}"
    dataString

  generateVideoBox: =>
    $("""
      <div id='bl-vid'>
        <div class='bl-video-wrap'>
          <div id='bl-playerV'></div>
        </div>
      </div>
      """).appendTo("body") if $("#bl-vid").length is 0

  generateOverlay: =>
    $("<div id='bookMarklet-overlay'></div>").appendTo "body"  if $("#bookMarklet-overlay").length is 0
    $("#bookMarklet-overlay").click =>
      @closeModal @modalID

  generateOutputBox: () =>
    element = $("#"+@textareaID)
    w = element.width()
    h = element.height()
    content = element.val()
    @outputBox = element.after("<div></div>").css("display", "none").next()

    @outputBox.attr(contenteditable: "true").addClass(@answerClass).css
      width: w
      height: h

    dataString = @generateBLDataString(
      type: "generate"
      vid: @vid
      vtype: @videoType
    )
    blDataEncoded = encodeURI(dataString)

    if $('#'+@buttonID).length > 0
      $('#'+@buttonID).attr
        "data-bl": blDataEncoded
        rel: "blModal"
    else
      @outputBox.after("<input type='button' value='Snippet'>").next().attr
        "data-bl": blDataEncoded
        rel: "blModal"
        id: @buttonID

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
      """).appendTo("body") if $("#bl").length is 0

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
          temp2 = VideoClipper.stripHTML(temp2)
          @caretPos = range.endOffset + temp2.split(temp1)[0].length
    @caretPos

  @stripHTML: (html) ->
    tmp = document.createElement("DIV")
    tmp.innerHTML = html
    tmp.textContent or tmp.innerText


