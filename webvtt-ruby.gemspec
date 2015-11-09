Gem::Specification.new do |s|
  s.name          = 'webvtt-ruby'
  s.version       = '0.3.2'
  s.summary       = "WebVTT parser and segmenter in ruby"
  s.description   = "WebVTT parser and segmenter in ruby for HTML5 and HTTP Live Streaming (HLS)."
  s.authors       = ["Bruno Celeste"]
  s.email         = 'bruno@heywatch.com'
  s.homepage      = 'https://github.com/HeyWatch/webvtt-ruby'
  s.license       = 'MIT'
  s.bindir        = 'bin'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
