describe "A suite", ->
  it "contains spec with an expectation", ->
    expect(true).toBe(true)

describe "VideoClipper", ->
  beforeEach ->
    clippy = new VideoClipper();
  it "should exist", ->
    expect(clippy).toBeDefined();
