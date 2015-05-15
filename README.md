# WebVTT Ruby parser and segmenter

The [WebVTT format](http://dev.w3.org/html5/webvtt/) is a standard captionning format used for HTML5 videos and HTTP Live Streaming (HLS).

## Installation

Add this line to your application's Gemfile:

    gem 'webvtt-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webvtt-ruby

## Usage

To parse a webvtt file:

```ruby
require "webvtt"

webvtt = WebVTT.read("path/sub.vtt")
webvtt.cues.each do |cue|
  puts "identifier: #{cue.identifier}"
  puts "Start: #{cue.start}"
  puts "End: #{cue.end}"
  puts "Style: #{cue.style.inspect}"
  puts "Text: #{cue.text}"
  puts "--"
end
```

## Converting from SRT

You can also convert an SRT file to a standard WebVTT file:

```ruby
webvtt = WebVTT.convert_from_srt("path/sub.srt", "path/sub.vtt")
puts webvtt.to_webvtt
```

## Segmenting for HTTP Live Streaming (HLS)

Segmenting is required to work with HLS videos.

```ruby
WebVTT.segment("subtitles/en.vtt", :length => 10, :output => "subtitles/en-%05d.vtt", :playlist => "subtitles/en.m3u8")
```

It will also generate the playlist in `m3u8`:

```
#EXTM3U
#EXT-X-TARGETDURATION:17
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD
#EXTINF:13,
en-00000.vtt
#EXTINF:17,
en-00001.vtt
#EXTINF:12,
en-00002.vtt
#EXT-X-ENDLIST
```

To use the segmented webvtt files with your HLS playlist:

```
#EXTM3U

#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=NO,AUTOSELECT=YES,FORCED=NO,LANGUAGE="en",URI="subtitles/en.m3u8"

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=300000,SUBTITLES="subs"
demo-300000.m3u8

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=600000,SUBTITLES="subs"
demo-600000.m3u8
```

## CLI

You can also segment webvtt files using the command line `webvtt-segmenter`:

```
$ webvtt-segmenter -i subtitles/en.vtt -t 10 -m subtitles/en.m3u8 -o "subtitles/en-%05d.vtt"
```

```
$ webvtt-segmenter -h
Usage: bin/webvtt-segmenter [--arg]
    -i, --input [PATH]               WebVTT or SRT file
    -b, --base-url [URL]             Base URL
    -t, --target-duration [DUR]      Duration of each segments. Default: 10
    -o, --output [PATH]              Path where WebVTT segments will be saved. Default: fileSequence-%05d.vtt
    -m, --playlist [PATH]            Path where the playlist in m3u8 will be saved. Default: prog_index.m3u8
```

## Note

`webvtt-ruby` was written in a few hours because there was no open source tool to segment webvtt files. It's not perfect at all but it does the job.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

**Bruno Celeste**

* http://www.heywatchencoding.com
* bruno@heywatch.com
* [@sadikzzz](http://twitter.com/sadikzzz)
