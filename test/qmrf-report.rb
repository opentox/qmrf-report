require_relative "setup.rb"

class QMRFReportTest < MiniTest::Test

  def test_0_self
    puts "MiniTest #{self.class} start OK"
  end

  def test_1_base
    report = OpenTox::QMRFReport.new
    assert report
    assert_kind_of(OpenTox::QMRFReport, report)
  end

  def test_2_validate
    report = OpenTox::QMRFReport.new
    assert_empty report.validate
  end

  def test_3_write_some_values
    report = OpenTox::QMRFReport.new
    report.value "QSAR_title", "My QSAR Title"
    report.value "QSAR_models", "My QSAR Model"
    assert_equal report.value("QSAR_title"), "My QSAR Title"
    assert_equal report.value("QSAR_models"), "My QSAR Model"
    refute_equal report.value("QSAR_title"), "lazar"
  end

  def test_4_write_check
    report = OpenTox::QMRFReport.new
    report.value "QSAR_title", "My QSAR Title"
    report.value "QSAR_models", "My QSAR Model"
    assert_equal report.to_xml, File.read(File.join(File.join(DATA_DIR, "qmrf_t4.xml")))
  end

  def test_5_write_catalog
    report = OpenTox::QMRFReport.new
    report.change_catalog :software_catalog, :firstsoftware, {:name => "lazar", :contact => "in-silico toxicology gmbh", :url => "https://lazar.in-silico.ch", :description => "lazar toxicity predictions"}
    assert "in-silico toxicology gmbh", report.get_catalog_value(:software_catalog, :firstsoftware, :contact)
    assert "lazar", report.get_catalog_value(:software_catalog, :firstsoftware, :name)
    assert "https://lazar.in-silico.ch", report.get_catalog_value(:software_catalog, :firstsoftware, :url)
    assert "lazar toxicity predictions", report.get_catalog_value(:software_catalog, :firstsoftware, :description)
  end

  def test_6_check_catalog_exists
    report = OpenTox::QMRFReport.new
    assert_raises RuntimeError do
      report.catalog_exists? :noexist_catalog
    end
    assert report.catalog_exists? :software_catalog
  end
  
  def test_7_write_alot
    report = OpenTox::QMRFReport.new
    report.value "QSAR_title", "My QSAR Title"
    report.value "QSAR_models", "My QSAR Model"
    report.change_catalog :software_catalog, :firstsoftware, {:name => "lazar", :contact => "in-silico toxicology gmbh", :url => "https://lazar.in-silico.ch", :description => "lazar toxicity predictions"}
    report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "MyName M (2016) My Publication Title, QSAR News, 10, 14-22", :url => "http://myqsarnewsmag.dom"}
    report.change_catalog :publications_catalog, :publications_catalog_2, {:title => "MyName M (2016) My Second Publication Title, Hornblower, 101ff.", :url => "http://hornblower.dom"}
    assert_equal report.to_xml, File.read(File.join(File.join(File.dirname(__FILE__),"data/qmrf_t7.xml")))
    report.change_catalog :publications_catalog, :publications_catalog_3, {:title => "MyName M (2016) My Third Publication Title, Somewhereelse, 43f.", :url => "http://somewhereelse.dom"}
    refute_equal report.to_xml, File.read(File.join(File.join(DATA_DIR, "qmrf_t7.xml")))
  end

  def test_8_ref_catalog_entry
    report = OpenTox::QMRFReport.new
    report.change_catalog :authors_catalog, :firstauthor, {:name => "Dr. My MyName", :url => "http://myauthor.dom", :email => "myauthor@myauthor.dom"}
    report.ref_catalog :qmrf_authors, :authors_catalog, :firstauthor
    report.change_catalog :authors_catalog, :secondauthor, {:name => "Dr. Mysec MysecName", :url => "http://myauthor.dom", :email => "myauthor@myauthor.dom"}
    report.ref_catalog :qmrf_authors, :authors_catalog, :secondauthor
    assert_equal report.to_xml, File.read(File.join(File.join(DATA_DIR, "qmrf_t8.xml")))
  end

  def test_9_set_attributes
    report = OpenTox::QMRFReport.new
    report.change_attributes "training_set_data", {:inchi => "Yes", :smiles => "Yes"}
    assert_equal report.to_xml, File.read(File.join(File.join(DATA_DIR, "qmrf_t9y.xml")))
    report.change_attributes "training_set_data", {:inchi => "No", :smiles => "No"}    
    assert_equal report.to_xml, File.read(File.join(File.join(DATA_DIR, "qmrf_t9n.xml")))

  end

end
