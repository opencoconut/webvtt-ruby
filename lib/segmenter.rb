module WebVTT

  def self.segment(input, options={})
    if input.is_a?(String)
      input = File.new(input)
    end

    if ! input.respond_to?(:to_webvtt)
      raise InputError, "Input must be a WebVTT instance or a path"
    end

    segmenter = Segmenter.new(input, options)
    subs = segmenter.split_to_files
    playlist = segmenter.generate_playlist(subs)

    return [playlist, subs]
  end

  class Segmenter
    attr_reader :webvtt

    def initialize(webvtt, options={})
      @webvtt = webvtt
      @options = options
      @options[:length] ||= 10
      @options[:output] ||= "fileSequence-%05d.vtt"
      @options[:playlist] ||= "prog_index.m3u8"
    end

    def find_segment_files(cue)
      seg = find_segments(cue)

      # we need to find out how many segments we
      # have to remove from our calculation
      # in the case of first cue not starting at 0
      start = @webvtt.cues[0].start_in_sec
      to_remove = (start / @options[:length]).floor
      return seg.map{|s| s-to_remove}
    end

    def find_segments(cue)
      all_cues = @webvtt.cues
      index_cue = all_cues.index(cue)
      seg = [(cue.start_in_sec / @options[:length]).floor]
      start_seg = seg[0] * @options[:length]
      end_seg = start_seg + @options[:length]

      # if the cue length is > than desired length
      # or if cue end in sec is > end of the segment in sec
      # we display it in the next segment as well

      if (cue.length > @options[:length]) ||
        (cue.end_in_sec > end_seg)

        (cue.length / @options[:length]).ceil.to_i.times.each do |s|
          seg << seg.last + 1
        end
      end

      return seg
    end

    def generate_playlist(files)
      lines = []
      target_duration = 0
      files.each_with_index do |file,i|

        # if first cue ever we calculate from 0 sec
        if i == 0
          total_length = file.total_length
        else
          total_length = file.actual_total_length
        end

        target_duration = total_length if total_length > target_duration
        if @options[:base_url].nil?
          url = file.filename
        else
          url = ::File.join(@options[:base_url], file.filename)
        end
        lines << %(#EXTINF:#{total_length.round},
#{url})
      end

      playlist = [%(#EXTM3U
#EXT-X-TARGETDURATION:#{target_duration.ceil}
#EXT-X-VERSION:3
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-PLAYLIST-TYPE:VOD)]
      playlist.concat(lines)
      playlist << "#EXT-X-ENDLIST"

      ::File.open(@options[:playlist], "w") {|f| f.write(playlist.join("\n")) }
      return @options[:playlist]
    end

    def split_to_files
      filenames = []
      segment_files = []

      @webvtt.cues.each_with_index do |cue,i|
        find_segment_files(cue).each do |seg|
          segment_files[seg] ||= []
          segment_files[seg] << cue
        end
      end

      segment_files.compact.each_with_index do |f,i|
        filename = sprintf(@options[:output], i)
        header = @webvtt.header

        if !header.include?("X-TIMESTAMP-MAP")
          # FIXME: the value should be configurable
          header << "\nX-TIMESTAMP-MAP=MPEGTS:900000,LOCAL:00:00:00.000"
        end

        content = [header, f.map{|c| c.to_webvtt }.join("\n\n")].join("\n\n")

        ::File.open(filename, "w") {|f| f.write(content)}

        filenames << filename
      end
      return filenames.map{|f| File.new(f) }
    end
  end
end