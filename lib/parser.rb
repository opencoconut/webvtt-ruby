module WebVTT

  class MalformedFile < RuntimeError; end
  class InputError < RuntimeError; end

  def self.read(file)
    File.new(file)
  end

  def self.convert_from_srt(srt_file, output=nil)
    if !::File.exists?(srt_file)
      raise InputError, "SRT file not found"
    end

    srt = ::File.read(srt_file)
    output ||= srt_file.gsub(".srt", ".webvtt")

    # convert timestamps and save the file
    srt.gsub!(/([0-9]{2}:[0-9]{2}:[0-9]{2})([,])([0-9]{3})/, '\1.\3')
    # normalize new line character
    srt.gsub!("\r\n", "\n")

    srt = "WEBVTT\n\n#{srt}"
    ::File.open(output, "w") {|f| f.write(srt)}

    return File.new(output)
  end

  class File
    attr_reader :header, :path, :filename
    attr_accessor :cues

    def initialize(webvtt_file)
      if !::File.exists?(webvtt_file)
        raise InputError, "WebVTT file not found"
      end

      @path = webvtt_file
      @filename = ::File.basename(@path)
      @content = ::File.read(webvtt_file).gsub("\r\n", "\n") # normalizing new line character
      parse
    end

    def to_webvtt
      [@header, @cues.map(&:to_webvtt)].flatten.join("\n\n")
    end

    def total_length
      @cues.last.end_in_sec
    end

    def actual_total_length
      @cues.last.end_in_sec - @cues.first.start_in_sec
    end

    def save(output=nil)
      output ||= @path.gsub(".srt", ".webvtt")

      File.open(output, "w") {|f| f.write(to_webvtt)}
      return output
    end

    def parse
      # remove bom first
      @content.gsub!("\uFEFF", '')

      cues = @content.split("\n\n")
      @header = cues.shift
      header_lines = @header.split("\n").map(&:strip)
      if (header_lines[0] =~ /^WEBVTT/).nil?
        raise MalformedFile, "Not a valid WebVTT file"
      end

      @cues = []
      cues.each do |cue|
        cue_parsed = Cue.new(cue)
        if !cue_parsed.text.nil?
          @cues << cue_parsed
        end
      end
      @cues
    end
  end

  class Cue
    attr_accessor :identifier, :start, :end, :style, :text

    def initialize(cue)
      @content = cue
      parse
    end

    def to_webvtt
      res = ""
      if @identifier
        res << "#{@identifier}\n"
      end
      res << "#{@start} --> #{@end} #{@style.map{|k,v| "#{k}:#{v}"}.join(" ")}".strip + "\n"
      res << @text

      res
    end

    def self.timestamp_in_sec(timestamp)
      mres = timestamp.match(/([0-9]{2}):([0-9]{2}):([0-9]{2}\.[0-9]{3})/)
      sec = mres[3].to_f # seconds and subseconds
      sec += mres[2].to_f * 60 # minutes
      sec += mres[1].to_f * 60 * 60 # hours
      return sec
    end

    def start_in_sec
      Cue.timestamp_in_sec(@start)
    end

    def end_in_sec
      Cue.timestamp_in_sec(@end)
    end

    def length
      end_in_sec - start_in_sec
    end

    def parse
      lines = @content.split("\n").map(&:strip)

      # it's a note, ignore
      return if lines[0] =~ /NOTE/

      if !lines[0].include?("-->")
        @identifier = lines[0]
        lines.shift
      end

      if lines[0].match(/([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}) -+> ([0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3})(.*)/)
        @start = $1
        @end = $2
        @style = Hash[$3.strip.split(" ").map{|s| s.split(":").map(&:strip) }]
      end
      @text = lines[1..-1].join("\n")
    end
  end
end