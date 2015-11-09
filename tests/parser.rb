$LOAD_PATH << "lib/"
require "minitest/autorun"
require "webvtt"

class ParserTest < Minitest::Test
  def test_can_read_webvtt
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal "test.vtt", webvtt.filename
  end

  def test_cant_read_webvtt
    assert_raises(WebVTT::InputError) {
      webvtt = WebVTT.read("tests/subtitles/test_.vtt")
    }
  end

  def test_is_not_valid_webvtt
    assert_raises(WebVTT::MalformedFile) {
      webvtt = WebVTT.read("tests/subtitles/notvalid.vtt")
    }
  end

  def test_list_cues
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_instance_of Array, webvtt.cues
    assert !webvtt.cues.empty?, "Cues should not be empty"
    assert_instance_of WebVTT::Cue, webvtt.cues[0]
    assert_equal 15, webvtt.cues.size
  end

  def test_header
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal "WEBVTT\nX-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000", webvtt.header
  end

  def test_cue
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    cue = webvtt.cues[0]
    assert_equal "00:00:29.000", cue.start.to_s
    assert_equal "00:00:31.000", cue.end.to_s
    assert_instance_of Hash, cue.style
    assert_equal "75%", cue.style["line"]
    assert_equal "English subtitle 15 -Forced- (00:00:27.000)\nline:75%", cue.text
  end

  def test_cue_identifier
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    cue = webvtt.cues[1]
    assert_equal "2", cue.identifier
    assert_equal "00:00:31.000", cue.start.to_s
    assert_equal "00:00:33.000", cue.end.to_s
    assert_equal ["align", "line"].sort, cue.style.keys.sort
    assert_equal ["start", "0%"].sort, cue.style.values.sort
    assert_equal "English subtitle 16 -Unforced- (00:00:31.000)\nalign:start line:0%", cue.text
  end

  def test_ignore_if_note
    webvtt = WebVTT.read("tests/subtitles/withnote.vtt")
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
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal 359, webvtt.total_length
  end

  def test_cue_length
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal 2.0, webvtt.cues[2].length
  end

  def test_file_to_webvtt
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal webvtt.to_webvtt, File.read("tests/subtitles/test.vtt")
  end

  def test_cue_to_webvtt
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    assert_equal webvtt.cues[0].to_webvtt, %(00:00:29.000 --> 00:00:31.000 line:75%
English subtitle 15 -Forced- (00:00:27.000)
line:75%)
    assert_equal webvtt.cues[1].to_webvtt, %(2
00:00:31.000 --> 00:00:33.000 align:start line:0%
English subtitle 16 -Unforced- (00:00:31.000)
align:start line:0%)
  end

  def test_updating_webvtt
    webvtt = WebVTT.read("tests/subtitles/test.vtt")
    cue = webvtt.cues[0]
    cue.identifier = "1"
    cue.text = "The text should change"
    cue.start = "00:00:01.000"
    cue.style = {}
    webvtt.cues = [cue]

    assert_equal webvtt.to_webvtt, %(WEBVTT
X-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000

1
00:00:01.000 --> 00:00:31.000
The text should change)
  end

  def test_reading_all_cues
    return
    webvtt = WebVTT.read("tests/subtitles/withnote.vtt")
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
    webvtt = WebVTT.read("tests/subtitles/big_srt.vtt")
    webvtt.cues.each_with_index do |cue,i|
      puts "*#{i}"
      puts "identifier: #{cue.identifier}"
      puts "Timestamps: #{cue.start} --> #{cue.end}"
      puts "Style: #{cue.style.inspect}"
      puts "Text :#{cue.text}\n*"
      puts
    end
  end

  def test_parse_cue_with_no_text
    webvtt = WebVTT.read("tests/subtitles/no_text.vtt")
    assert_equal 2, webvtt.cues.size
    assert_equal "265", webvtt.cues[0].identifier
    assert_equal "00:08:57.409", webvtt.cues[0].start.to_s
    assert_equal "00:09:00.592", webvtt.cues[0].end.to_s
    assert_equal "", webvtt.cues[0].text
    assert_equal "266", webvtt.cues[1].identifier
    assert_equal "00:09:00.593", webvtt.cues[1].start.to_s
    assert_equal "00:09:02.373", webvtt.cues[1].end.to_s
    assert_equal "", webvtt.cues[1].text
  end
  
  def test_cue_offset_by
    cue = WebVTT::Cue.parse <<-CUE
    00:00:01.000 --> 00:00:25.432
    Test Cue
    CUE
    assert_equal 1.0, cue.start.to_f
    assert_equal 25.432, cue.end.to_f
    cue.offset_by( 12.0 )
    assert_equal 13.0, cue.start.to_f
    assert_equal 37.432, cue.end.to_f
  end

  def test_timestamp_from_string
    ts_str = "00:05:31.522"
    ts = WebVTT::Timestamp.new( ts_str )
    assert_equal ts_str, ts.to_s
    assert_equal (5*60 + 31.522), ts.to_f
  end

  def test_timestamp_from_number
    ts_f = (7*60 + 12.111)
    ts = WebVTT::Timestamp.new( ts_f )
    assert_equal "00:07:12.111", ts.to_s
    assert_equal ts_f, ts.to_f
  end

  def test_timestamp_errors_from_unknown_type
    assert_raises ArgumentError do
      WebVTT::Timestamp.new( nil )
    end
  end

  def test_timestamp_addition
    ts = WebVTT::Timestamp.new( "01:47:32.004" )
    ts2 = ts + (4*60 + 30)
    assert_equal "01:52:02.004", ts2.to_s
    ts3 = ts + ts2
    assert_equal "03:39:34.008", ts3.to_s
  end

  def test_build_cue
    cue = WebVTT::Cue.new
    cue.start = WebVTT::Timestamp.new 0
    cue.end = WebVTT::Timestamp.new 12
    cue.text = "Built from scratch"
    output = ""
    output << "00:00:00.000 --> 00:00:12.000\n"
    output << "Built from scratch"
    assert_equal output, cue.to_webvtt
  end

  def test_invalid_cue
    webvtt = WebVTT.convert_from_srt("tests/subtitles/invalid_cue.srt")
    assert_equal 1, webvtt.cues.size
  end
end
