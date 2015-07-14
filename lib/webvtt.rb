# encoding: UTF-8

if defined?(Encoding)
  Encoding.default_internal = Encoding.default_external = "UTF-8"
end

module WebVTT
  class MalformedFile < RuntimeError; end
  class InputError < RuntimeError; end
end

require "webvtt/parser"
require "webvtt/segmenter"
