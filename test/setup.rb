require 'minitest/autorun'
require_relative '../lib/qmrf-report.rb'
require_relative '../lib/qprf-report.rb'
include OpenTox
TEST_DIR ||= File.expand_path(File.dirname(__FILE__))
DATA_DIR ||= File.join(TEST_DIR,"data")