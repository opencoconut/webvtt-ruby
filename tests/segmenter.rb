$LOAD_PATH << "lib/"
require "test/unit"
require "webvtt"
require "fileutils"

class ParserTest < Test::Unit::TestCase

  def test_segment_of_a_given_cue
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    segmenter = WebVTT::Segmenter.new(webvtt, :length => 5)
    assert_equal [5, 6], segmenter.find_segments(webvtt.cues[0])
    assert_equal [6], segmenter.find_segments(webvtt.cues[1])
    assert_equal [6], segmenter.find_segments(webvtt.cues[2])
    assert_equal [7], segmenter.find_segments(webvtt.cues[3])
    assert_equal [9,10], segmenter.find_segments(webvtt.cues[10])
    assert_equal [10,11,12], segmenter.find_segments(webvtt.cues[12])
  end

  def test_segment_file_of_a_given_cue
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    segmenter = WebVTT::Segmenter.new(webvtt, :length => 5)
    assert_equal [0, 1], segmenter.find_segment_files(webvtt.cues[0])
    assert_equal [1], segmenter.find_segment_files(webvtt.cues[1])
    assert_equal [1], segmenter.find_segment_files(webvtt.cues[2])
    assert_equal [2], segmenter.find_segment_files(webvtt.cues[3])
    assert_equal [4,5], segmenter.find_segment_files(webvtt.cues[10])
    assert_equal [5,6,7], segmenter.find_segment_files(webvtt.cues[12])
  end

  def test_split_to_files
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    sub_webvtt_files = WebVTT::Segmenter.new(webvtt, :length => 5).split_to_files
    assert_equal 68, sub_webvtt_files.size

    assert_equal 31, sub_webvtt_files[0].total_length

    # clean up
    sub_webvtt_files.each {|f| FileUtils.rm(f.filename)}
  end

  def test_generate_playlist
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    segmenter = WebVTT::Segmenter.new(webvtt, :length => 5, :playlist => "test.m3u8")
    subs = segmenter.split_to_files
    segmenter.generate_playlist(subs)

    assert File.exists?("test.m3u8")
    # clean up
    subs.each {|f| FileUtils.rm(f.filename)}
  end

  def test_shortcut_method
    res = WebVTT.segment("tests/subtitles/test.webvtt")
    assert_instance_of Array, res
    assert_equal 2, res.size
    assert_equal 35, res[1].size
  end

  def test_segmenting_big_srt
    #webvtt = WebVTT.convert_from_srt("tests/subtitles/big_srt.srt")
    #res = WebVTT.segment(webvtt, :length => 10, :output => "tests/subtitles/big-%05d.webvtt", :playlist => "tests/subtitles/big.m3u8")
    res = WebVTT.segment("tests/subtitles/big_srt.webvtt", :length => 10, :output => "/Users/sadikzzz/Sites/HLS/truedetective/subtitles/en-%05d.webvtt", :playlist => "/Users/sadikzzz/Sites/HLS/truedetective/subtitles/en.m3u8")
    #assert_instance_of Array, res
    #assert File.exists?("tests/subtitles/big.m3u8")
    #assert Dir.glob("tests/subtitles/big-*.webvtt").size > 0
  end

  def test_segment_to_webvtt_files
    return
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    sub_webvtt_files = WebVTT::Segmenter.new(webvtt, :length => 5).split
    assert_equal 67, sub_webvtt_files.size
    puts
    sub_webvtt_files.each_with_index do |f,i|
      puts "//"
      puts "SEQUENCE: #{i}"
      puts "--------------"
      puts f.map{|c| c.to_webvtt }.join("\n\n")
      puts "--"
    end
  end
end