require "nokogiri"

# OpenTox module
module OpenTox

  #Class for QMRF reporting. 
  #
  #Provides a ruby OpenTox class to prepare an initial version of a QMRF report. 
  #The XML output is in QMRF version 1.3 and can be finalized with the QMRF editor 2.0 (https://sourceforge.net/projects/qmrf/)  
  #@example Report
  #  require ""
  #  report = OpenTox::QMRFReport.new
  #  report.change_qmrf_tag "QSAR_title", "My QSAR Title"
  #  report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "MyName M (2016) My Publication Title, QSAR News, 10, 14-22", :url => "http://myqsarnewsmag.dom"}
  #  report.ref_catalog :bibliography, :publications_catalog, :publications_catalog_1
  #  puts report.to_xml

  class QMRFReport
    # QMRF XML Schema file 
    SCHEMA_FILE   = File.join(File.dirname(__FILE__),"template/qmrf.xsd")
    # QMRF XML Template file
    TEMPLATE_FILE = File.join(File.dirname(__FILE__),"template/qmrf.xml")
    
    attr_accessor :xml, :report

    # Open an existing QMRF xml report
    # @param [String] file Name of the file
    def open file
      xml = File.read("#{file}")
      @report = Nokogiri.XML(xml)
    end

    # Initialize a new report instance from qmrf template
    def initialize
      xml = File.read(TEMPLATE_FILE)
      @report = Nokogiri.XML(xml)
    end

    # returns XML representation (QMRF XML report) of report instance
    # @return [String] returns XML
    def to_xml
      @report.to_xml
    end

    # Change a value
    # e.G.: <QSAR_title chapter="1.1" help="" name="QSAR identifier (title)">Title of My QSAR</QSAR_title>
    # @param [String] key Name of the node
    # @param [String] value Value to change
    # @return [Error]  returns Error message if fails
    def change_qmrf_tag key, value
      raise "Can not edit attribute #{key} directly. Edit the catalog with 'report.change_catalog(catalog, key, value)'." if ["QSAR_software","QSAR_Algorithm", ""].include? key
      t = @report.at_css key
      t.content = value
    end

    # Change a catalog
    # @param [String] catalog Name of the catalog - One of "software_catalog", "algorithms_catalog", "descriptors_catalog", "endpoints_catalog", "publications_catalog", "authors_catalog" in QMRF v1.3
    # @param [String] id Single entry node in the catalog e.G.: "<software contact='mycontact@mydomain.dom' description="My QSAR Software " id="software_catalog_2" name="MySoftware" number="" url="https://mydomain.dom"/>
    # @param [Hash] valuehash Key-Value Hash with attributes for a single catalog node
    # @return [Error]  returns Error message if fails
    def change_catalog catalog, id, valuehash
      catalog_exists? catalog
      if @report.at_css("#{catalog}").at("//*[@id='#{id}']")
        valuehash.each do |key, value|
          @report.at_css("#{catalog}").at("//*[@id='#{id}']")["#{key}"]= value
        end
      else
        cat = @report.at_css("#{catalog}")
        newentry = Nokogiri::XML::Node.new("#{catalog.to_s.gsub(/s?_catalog/,'')}", self.report)
        newentry["id"] = id
        valuehash.each do |key, value|
          newentry["#{key}"] = value
        end
        cat << newentry
      end
    end

    # Set reference to a catalog entry.
    # e.g.: reference an author entry from authors_catalog to Chapter 2.2 QMRF authors
    #@example ref_catalog
    #  report.ref_catalog 'qmrf_authors', 'authors_catalog', 'firstauthor'
    # @param [String] chapter Name of the chapter to add the catalog reference. e.g.: qmrf_authors, model_authors, QSAR_software, ...
    # @param [String] catalog Name of the catalog 
    # @param [String] id entry node in the catalog
    def ref_catalog chapter, catalog, id
      catalog_exists? catalog
      if @report.at_css("#{catalog}").at("//*[@id='#{id}']")
        chap = @report.at_css("#{chapter}")
        if chap.at("//*[@idref='#{id}']").nil?
          newentry = Nokogiri::XML::Node.new("#{catalog.to_s.gsub(/s?_catalog/,'_ref')}", self.report)
          newentry["idref"] = id
          chap << newentry
        end
      else
        raise "catalog entry with id: #{id} do not exist."      
      end
    end

    # get value of a QMRF node
    # @param [String] key Nodename e.g.: "QSAR_title"
    # @return [String] returns value
    def get_qmrf_tag key
      t = @report.at_css key
      t.content
    end

    # get an attribute from a catalog entry
    # @param [String] catalog Name of the catalog
    # @param [String] id entry id in the catalog 
    # @param [String] key returns value of a key in a catalog node
    # @return [String, false] returns value of a key in a catalog node or false if catalog entry do not exists.
    def get_catalog_value catalog, id, key
      catalog_exists? catalog
      if @report.at_css("#{catalog}").at("//*[@id='#{id}']")
        @report.at_css("#{catalog}").at("//*[@id='#{id}']")["#{key}"]
      else
        return false
      end
    end

    # Check if a catalog exists in this QMRF version
    # @param [String] catalog Catalog
    # @return [Error, true]  returns true or Error if a catalog do not exists
    def catalog_exists? catalog
      raise "Unknown catalog: #{catalog}" unless ["software_catalog", "algorithms_catalog", "descriptors_catalog", "endpoints_catalog", "publications_catalog", "authors_catalog"].include? catalog.to_s
      true
    end

    # Validates a report instance against qmrf.xsd (XML Structure Definition)
    def validate
      xsd = Nokogiri::XML::Schema(File.read(SCHEMA_FILE))
      out = ""
      xsd.validate(@report).each do |error|
        out << error.message unless error.message == "Element 'algorithm', attribute 'publication_ref': '' is not a valid value of the atomic type 'xs:IDREF'." || error.message == "Element 'descriptor', attribute 'publication_ref': '' is not a valid value of the atomic type 'xs:IDREF'."
      end
      return out
    end

  end
end