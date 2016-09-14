require "nokogiri"

# OpenTox module
module OpenTox

  #Class for QMRF reporting. 
  #
  #Provides a ruby OpenTox class to prepare an initial version of a QMRF report. 
  #The XML output is in QMRF version 1.3 and can be finalized with the QMRF editor 2.0 (https://sourceforge.net/projects/qmrf/)  
  #@example Report
  #  require "qsar-report"
  #  report = OpenTox::QMRFReport.new
  #  report.value "QSAR_title", "My QSAR Title"
  #  report.change_attributes "training_set_data", {:inchi => "Yes", :smiles => "Yes"}
  #  report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "MyName M (2016) My Publication Title, QSAR News, 10, 14-22", :url => "http://myqsarnewsmag.dom"}
  #  report.ref_catalog :bibliography, :publications_catalog, :publications_catalog_1
  #  puts report.to_xml

  class QMRFReport
    # QMRF XML Schema file 
    SCHEMA_FILE   = File.join(File.dirname(__FILE__),"template/qmrf.xsd")
    # QMRF XML Template file
    TEMPLATE_FILE = File.join(File.dirname(__FILE__),"template/qmrf.xml")
    # QMRF XML tags with attributes to edit
    ATTRIBUTE_TAGS = ["training_set_availability", "training_set_data", "training_set_descriptors", "dependent_var_availability", "validation_set_availability", "validation_set_data", "validation_set_descriptors", "validation_dependent_var_availability"]
    
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

    # Get or Set a value
    # e.G.: <QSAR_title chapter="1.1" help="" name="QSAR identifier (title)">Title of My QSAR</QSAR_title>
    # @param [String] key Nodename e.g.: "QSAR_title"
    # @param [String] value Value to change. If not set the function returns the current value
    # @return [Error]  returns Error message if fails
    # @return [String] returns value    
    def value key, value=nil
      raise "Can not edit attribute #{key} directly. Edit the catalog with 'report.change_catalog(catalog, key, value)'." if ["QSAR_software","QSAR_Algorithm", ""].include? key
      t = @report.at_css key
      t.content = value unless value.nil?
      t.content
    end

    # Set attributes of an report XML tag
    # e.G.: <training_set_data cas="Yes" chapter="6.2" chemname="Yes" formula="Yes" help="" inchi="Yes" mol="Yes" name="Available information for the training set" smiles="Yes"/>
    #@example change_attributes
    #  report.change_attributes "training_set_data", {:inchi => "Yes", :smiles => "Yes"}
    # @param [String] key Nodename e.g.: "training_set_data"
    # @param [Hash] valuehash Key-Value Hash of tag attributes to change.
    # @return [Error]  returns Error message if fails
    def change_attributes tagname, valuehash
      raise "Can not edit the attributes of tag: #{tagname}." unless ATTRIBUTE_TAGS.include? tagname
      tag = @report.at_css tagname
      valuehash.each do |key, value|
        tag.attributes["#{key}"].value = value
      end
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
        # @todo ignore case sensitivity error: error.message The value 'NO' is not an.Element of the set {'Yes', 'No'}.
      end
      return out
    end

  end
end