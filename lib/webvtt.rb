# encoding: UTF-8

if defined?(Encoding)
  Encoding.default_internal = Encoding.default_external = "UTF-8"
end

require "parser"
require "segmenter"