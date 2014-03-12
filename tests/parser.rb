$LOAD_PATH << "lib/"
require "test/unit"
require "webvtt"

class ParserTest < Test::Unit::TestCase
  def test_can_read_webvtt
    assert_nothing_raised(WebVTT::InputError) {
      webvtt = WebVTT.read("tests/subtitles/test.webvtt")
      assert_equal "test.webvtt", webvtt.filename
    }
  end

  def test_cant_read_webvtt
    assert_raise(WebVTT::InputError) {
      webvtt = WebVTT.read("tests/subtitles/test_.webvtt")
    }
  end

  def test_is_valid_webvtt
    assert_nothing_raised(WebVTT::MalformedFile) {
      webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    }
  end

  def test_is_not_valid_webvtt
    assert_raise(WebVTT::MalformedFile) {
      webvtt = WebVTT.read("tests/subtitles/notvalid.webvtt")
    }
  end

  def test_list_cues
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    assert_instance_of Array, webvtt.cues
    assert !webvtt.cues.empty?, "Cues should not be empty"
    assert_instance_of WebVTT::Cue, webvtt.cues[0]
    assert_equal 15, webvtt.cues.size
  end

  def test_header
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    assert_equal "WEBVTT\nX-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000", webvtt.header
  end

  def test_cue
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    cue = webvtt.cues[0]
    assert_equal "00:00:29.000", cue.start
    assert_equal "00:00:31.000", cue.end
    assert_instance_of Hash, cue.style
    assert_equal "75%", cue.style["line"]
    assert_equal "English subtitle 15 -Forced- (00:00:27.000)\nline:75%", cue.text
  end

  def test_cue_identifier
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    cue = webvtt.cues[1]
    assert_equal "2", cue.identifier
    assert_equal "00:00:31.000", cue.start
    assert_equal "00:00:33.000", cue.end
    assert_equal ["align", "line"].sort, cue.style.keys.sort
    assert_equal ["start", "0%"].sort, cue.style.values.sort
    assert_equal "English subtitle 16 -Unforced- (00:00:31.000)\nalign:start line:0%", cue.text
  end

  def test_ignore_if_note
    webvtt = WebVTT.read("tests/subtitles/withnote.webvtt")
    assert_equal 3, webvtt.cues.size
    # ignoring the first cue which is a NOTE
    assert_equal "1", webvtt.cues[0].identifier
  end

  def test_timestamp_in_sec
    assert_equal 60.0, WebVTT::Cue.timestamp_in_sec("00:01:00.000")
    assert_equal 126.23, WebVTT::Cue.timestamp_in_sec("00:02:06.230")
    assert_equal 5159.892, WebVTT::Cue.timestamp_in_sec("01:25:59.892")
  end

  def test_total_length
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    assert_equal 359, webvtt.total_length
  end

  def test_cue_length
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    assert_equal 2.0, webvtt.cues[2].length
  end

  def test_to_webvtt
    webvtt = WebVTT.read("tests/subtitles/test.webvtt")
    assert_equal webvtt.to_webvtt, File.read("tests/subtitles/test.webvtt")
  end

  def test_reading_all_cues
    return
    webvtt = WebVTT.read("tests/subtitles/withnote.webvtt")
    webvtt.cues.each_with_index do |cue,i|
      puts "#{i}"
      puts "identifier: #{cue.identifier}"
      puts "Timestamps: #{cue.start} --> #{cue.end}"
      puts "Style: #{cue.style.inspect}"
      puts "Text :#{cue.text}\n*"
      puts
    end
  end

  def test_convert_srt_to_webvtt
    webvtt = WebVTT.convert_from_srt("tests/subtitles/test_from_srt.srt")
    assert_instance_of WebVTT::File, webvtt
    assert_equal 2, webvtt.cues.size
  end

  def test_parse_big_file
    return
    webvtt = WebVTT.read("tests/subtitles/big_srt.webvtt")
    webvtt.cues.each_with_index do |cue,i|
      puts "*#{i}"
      puts "identifier: #{cue.identifier}"
      puts "Timestamps: #{cue.start} --> #{cue.end}"
      puts "Style: #{cue.style.inspect}"
      puts "Text :#{cue.text}\n*"
      puts
    end
  end
end