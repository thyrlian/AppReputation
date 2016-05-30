$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!

require 'app_reputation'
require 'minitest/autorun'
