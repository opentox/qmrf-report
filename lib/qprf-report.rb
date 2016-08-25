require "json"
require "haml"

# OpenTox module
module OpenTox

  #Class for QPRF reporting.
  #
  #Provides a ruby OpenTox class to prepare an initial version of a QPRF report.
  #The QPRF output is in QPRF version 1.1  from May 2008
  #@example Report
  #  require "qsar-report"
  #  report = OpenTox::QPRFReport.new
  #  report.Title = "My QPRF Report"
  #  report.Version = "1"
  #  report.Date = Time.now.strftime("%Y/%m/%d")
  #  report.value "1.1", "7732-18-5" # set CAS number for H²O
  #  puts report.to_html

  class QPRFReport
    # QPRF JSON Template file
    TEMPLATE_FILE = File.join(File.dirname(__FILE__),"template/qprf.json")

    # QPRF MarkDown Template file
    MD_TEMPLATE_FILE = File.join(File.dirname(__FILE__),"template/qprf.haml")

    attr_accessor :json, :report

    # Open an existing QPRF json report
    # @param [String] file Name of the file
    def open file
      json = File.read("#{file}")
      @report = JSON.parse(json)
    end

    # Initialize a new report instance from QPRF template. With helper functions for Title, Version and Date
    def initialize
      json = File.read(TEMPLATE_FILE)
      @report = JSON.parse(json)

      attr_hash = {self.report['singleCalculations'] => ["Title", "Version", "Date"] }
      attr_hash.each_pair do |block, attributes|
        attributes.each do |attribute|
          define_singleton_method "#{attribute}" do
            return block[attribute]
          end
          define_singleton_method "#{attribute}=" do |val=nil|
            block[attribute] = val unless val.nil?
            return block[attribute]
          end
        end
      end

    end

    # Set or Get a value in the QPRF report
    #@example for CAS Number
    #  report = OpenTox::QPRFReport.new
    #  report.value "1.1", "7732-18-5"
    #
    # @param [String] chapter Name of the chapter - e.g.:  "1.1", "1.2", "1.3", "1.4", "1.5 General", "1.5 a.", "1.5 b.", "1.5 c.", "1.5 d.", "2.1" ...
    # @param [String] value Value to set. If not set the function returns the current value
    # @return [String]  returns Value
    def value chapter, value=nil
      case chapter
      when /^1\.\d*/
        block = "1. Substance"
      when /^2\.\d*/
        block = "2. General information"
      when /^3\.\d*/
        block = "3. Prediction"
      when /^4\.\d*/
        block = "4. Adequacy (Optional)"
      end
      @report["arrayCalculations"][block]['values'][chapter][1] = value unless value.nil?
      @report["arrayCalculations"][block]['values'][chapter][1]
    end

    # returns prettified JSON representation (QPRF JSON report) of report instance
    # @return [String] returns JSON
    def pretty_json
      JSON.pretty_generate(@report)
    end

    # Creates a HTML representation of the QPRF report
    # @return [String] returns HTML
    def to_html
      Haml::Engine.new(File.read(MD_TEMPLATE_FILE)).render @report
    end

  end
end