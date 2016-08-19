ENV["LAZAR_ENV"] = "development"
require 'minitest/autorun'
require_relative '../lib/qmrf-report.rb'
#require 'lazar'
include OpenTox
TEST_DIR ||= File.expand_path(File.dirname(__FILE__))
DATA_DIR ||= File.join(TEST_DIR,"data")