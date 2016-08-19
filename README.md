# lazar-report
QMRF reporting extension to OpenTox ruby modules and lazar
## About
Class for QMRF reporting. 
Provides a ruby OpenTox class to prepare an initial version of a QMRF report. 
The XML output is in QMRF version 1.3 and can be finalized with the QMRF editor 2.0 (https://sourceforge.net/projects/qmrf/)  



## Usage
create a new report, add some content and show output:
```ruby 
require ""

# create a new report
report = OpenTox::QMRFReport.new

# add a title
report.change_qmrf_tag "QSAR_title", "My QSAR Title"

# add a publication to the publication catalog
report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "MyName M (2016) My Publication Title, QSAR News, 10, 14-22", :url => "http://myqsarnewsmag.dom"}

# link/reference the publication to the report bibliography
report.ref_catalog :bibliography, :publications_catalog, :publications_catalog_1

# output
puts report.to_xml

# validate a report (as created above) against qmrf.xsd
report.validate
```
