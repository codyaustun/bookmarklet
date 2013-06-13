describe "A suite", ->
  it "contains spec with an expectation", ->
    expect(true).toBe(true)

describe "VideoClipper", ->
  clippy = undefined

  beforeEach ->
    clippy = new VideoClipper

  it "should have VideoClipper class", ->
    expect(clippy).toBeDefined()

  # Not sure if a constructor actually makes sense yet
  xdescribe "when constructing", ->
    it "should give reel a default but allow it to be set", ->
      expect(clippy.reel).not.toBeFalsy

      reelString = "http://web.mit.edu/colemanc/www/bookmarklet/images/film2Small.png"
      clippy2 = new VideoClipper
        reel: reelString

      expect(clippy2.reel).toEqual(reelString)

    it "should give answerClass a default but allow it to be set", ->
      expect(clippy.answer_class).not.toBeFalsy

      answer_class = "VC-answer"
      clippy2 = new VideoClipper
        answerClass: answer_class 

      expect(clippy2.answer_class).toEqual(answer_class)

    it "should require vid to be set", ->
      vid = "d_z2CA-o13U"
      clippy2 = new VideoClipper
        videoID: vid 

      expect(clippy2.vid).toEqual(vid)

      # Should throw error
      expect('pending').toEqual('completed')

    it "should require video_type to be set", ->
      video_type = "yt"
      clippy2 = new VideoClipper
        videoType: video_type 

      expect(clippy2.video_type).toEqual(video_type)
      # Should throw error
      expect('pending').toEqual('completed')

    it "should require textareaid to be set", ->
      expect('pending').toEqual('completed')

    it "should allow button to be turned off", ->
      expect('pending').toEqual('completed')

  describe "when setting up", ->

    it "should replace textarea with div", ->
      expect('pending').toEqual('completed')

    it "should generate a snippet box if it doesn't exist", ->
      expect('pending').toEqual('completed')

    describe "with a valid snippet box", ->
      it "should make the start button respond to clicks", ->
        expect('pending').toEqual('completed')

      it "should make the end button respond to clicks", ->
        expect('pending').toEqual('completed')

      it "should make the reset button respond to clicks", ->
        expect('pending').toEqual('completed')

      it "should make the done button respond to clicks", ->
        expect('pending').toEqual('completed')

    it "should generate a video box if it doesn't exist", ->
      expect('pending').toEqual('completed')

    it "should add a hidden overlay div", ->
      expect('pending').toEqual('completed')

    it "should close modal window when overlay is clicked", ->
      expect('pending').toEqual('completed')

    it "should update textarea's value whenever the div's html is changed", ->
      expect('pending').toEqual('completed')

  describe "when closing a modal window", ->

    it "should hide overlay", ->
      expect('pending').toEqual('completed')

    it "should stop the video player", ->
      expect('pending').toEqual('completed')

    it "should hide the modal window", ->
      expect('pending').toEqual('completed')

  describe "when opening a modal window", ->

    it "should get the data from the element", ->
      expect('pending').toEqual('completed')

    it "should determine which modal window to open", ->
      expect('pending').toEqual('completed')

    describe "with a snippet box", ->
      it "should get video type and id", ->
        expect('pending').toEqual('completed')

      it "should clear inputs", ->
        expect('pending').toEqual('completed')

      it "should create a video player if it doesn't exist", ->
        expect('pending').toEqual('completed')

      it "should show snippet box", ->
        expect('pending').toEqual('completed')

      it "should show overlay", ->
        expect('pending').toEqual('completed')

    describe "with a video box", ->

      it "should get video type, id, start time and end time", ->
        expect('pending').toEqual('completed')

      it "should create a video player if it doesn't exist", ->
        expect('pending').toEqual('completed')

      it "should show video box", ->
        expect('pending').toEqual('completed')

      it "should show overlay", ->
        expect('pending').toEqual('completed')

  describe "when checking for errors", ->
    it "should parse floats from the input box", ->
      expect('pending').toEqual('completed')

    it "should remove incorrect highlighting class if correct", ->
       expect('pending').toEqual('completed')

    it "should add incorrect highlighting class if incorrect", ->
      expect('pending').toEqual('completed') 

  describe "when getting data from an element", ->
    it "should check if it has a data-bl attribute", ->
      expect('pending').toEqual('completed') 

    describe "with a data-bl attribute", ->

      it "should parse a JSON object from the data-bl attribute", ->
        expect('pending').toEqual('completed')

      it "should produce a valid JSON object with the correct data", ->
        expect('pending').toEqual('completed')

    describe "without a data-bl attribute", ->

      it "should parse a JSON object from the elements text", ->
        expect('pending').toEqual('completed')

      it "should produce a valid JSON object with the correct data", ->
        expect('pending').toEqual('completed')

  describe "when clearing start and end time inputs", ->
    it "should clear values for input box in the snippet box", ->
      expect('pending').toEqual('completed')

    it "should clear values for the textarea in the snippet box", ->
      expect('pending').toEqual('completed')

    it "should remove the incorrect highlighting class from the input boxes", ->
      expect('pending').toEqual('completed')

  describe "when updating output box", -> 

    it "should generate a string representing the JSON data object", ->
      expect('pending').toEqual('completed')

    it "should encoded the data string", ->
      expect('pending').toEqual('completed') 

    it "should find the source question", ->
      expect('pending').toEqual('completed')

    it "should get the question's current contents", ->
      expect('pending').toEqual('completed')

    it "should iterate through the question's text and html", ->
      expect('pending').toEqual('completed')

    it "should place the new link at the caret position", ->
      expect('pending').toEqual('completed')

    it "should replace the question's content with the new content", ->
      expect('pending').toEqual('completed')

    it "should update the question's textarea", ->
      expect('pending').toEqual('completed')

  describe "when YouTube clip player is ready", ->
    it "should cue the video in the video box at the correct start and end times", ->
      expect('pending').toEqual('completed')

  describe "when setting up for YouTube Videos", ->
    it "should create a script element", ->
      expect('pending').toEqual('completed')

    it "should set the script element's source to YouTube iframe API", ->
      expect('pending').toEqual('completed')

    it "should the first script tag", ->
      expect('pending').toEqual('completed')

    it "should insert the new script tag before the first script tag", ->
      expect('pending').toEqual('completed') 

  describe "when generating output box", ->
    it "should find the textarea by id", ->
      expect('pending').toEqual('completed')

    it "should get the textarea's width, height and value", ->
      expect('pending').toEqual('completed')

    it "should insert an div after the textarea area and hide the textarea", ->
      expect('pending').toEqual('completed')

    it "should give the new div the same height, width and value", ->
      expect('pending').toEqual('completed')

    it "should add an input button after the div", ->
      expect('pending').toEqual('completed')

    it "should store an encoded data string in the button", ->
      expect('pending').toEqual('completed')

  describe "when generating clip a tag", ->

    it "should get start and end times from snippet box", ->
      expect('pending').toEqual('completed')

    it "should check for errors in the start and end times", ->
      expect('pending').toEqual('completed')

    describe "with correct values", ->

      it "should make sure there is a correct value for end_time", ->
        expect('pending').toEqual('completed')

      it "should generate a show data JSON string", ->
        expect('pending').toEqual('completed')

      it "should encode the data string", ->
        expect('pending').toEqual('completed')

      it "should create an a tag with the encodedData in the text", ->
        expect('pending').toEqual('completed')

      it "should return the tag", ->
        expect('pending').toEqual('completed')

    describe "without correct values", ->

      it "should return and empty string", ->
        expect('pending').toEqual('completed')

  describe "when generating JSON clip data", ->

    it "should check for data in the argument and default to instance values if needed", ->
      expect('pending').toEqual('completed')

    it "should return a data string according to the type in the argument", ->
      expect('pending').toEqual('completed')

    describe "without a type", ->

      it "should return an empty string", ->
        expect('pending').toEqual('completed')

  describe "when generating video box", -> 

    it "should create a div with an id of bl-vid", ->
      expect('pending').toEqual('completed')

    it "should have a div with the id of bl-playerV inside", ->
      expect('pending').toEqual('completed')

  describe "when generating clipping box", ->

    it "should create a div with an id of bl", ->
      expect('pending').toEqual('completed')

    it "should have a div with the id of bl-player inside", ->
      expect('pending').toEqual('completed')

  describe "when getting caret position", ->

    it "should have a spec", ->
      expect('pending').toEqual('completed')


  describe "when stripping html", ->

    it "should create a div", ->
      expect('pending').toEqual('completed')

    it "should put the html into the div's innerHTML", ->
      expect('pending').toEqual('completed')

    it "should return div's textContent or innerText", ->
      expect('pending').toEqual('completed')

