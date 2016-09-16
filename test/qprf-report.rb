require_relative "setup.rb"

class QPRFReportTest < MiniTest::Test

  def test_0_self
    puts "MiniTest #{self.class} start OK"
  end

  def test_1_base
    report = OpenTox::QPRFReport.new
    assert report
    assert_kind_of(OpenTox::QPRFReport, report)
    assert report.to_json
    assert report.to_html
    assert report.pretty_json
  end

  def test_2_md
    report = OpenTox::QPRFReport.new
    assert report.to_html
  end

  def test_3_get_Title
    report = OpenTox::QPRFReport.new
    assert_equal report.Title, "QSAR Prediction Reporting Format (QPRF)"
  end
  
  def test_4_set_values
    report = OpenTox::QPRFReport.new
    report.Title = "My Test Title"
    report.Version = "12"
    assert_equal report.Title, "My Test Title"
    assert_equal report.Version, "12"
    #puts report.to_html
  end

  def test_5_get_11
    report = OpenTox::QPRFReport.new
    report.value "1.1", "7732-18-5"
    assert_equal report.value("1.1"), "7732-18-5"
  end

  def test_6_set_more_values
    report = OpenTox::QPRFReport.new
    report.Title = "My QPRF Report"
    report.Version = "2.1"
    report.Date = "2016/08/21"
    report.value "1.1", "7732-18-5"
    assert_equal report.pretty_json, File.read(File.join(DATA_DIR,'qprf-t6.json'))
  end

end