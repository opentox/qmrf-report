# QSAR-Report
QMRF and QPRF reporting extension to OpenTox ruby modules and lazar.
## About
Class for QMRF and QPRF reporting.  
* QMRF:
  Provides a ruby OpenTox class to prepare an initial version of a QMRF report.
  The XML output is in QMRF version 1.3 and can be finalized with the QMRF editor 2.0 (https://sourceforge.net/projects/qmrf/)
* QPRF:
  Provides a ruby OpenTox class to prepare an initial version of a QPRF (version 1.1) report in JSON or HTML.

## Usage
### QMRF
create a new QMRF report, add some content and show output:
```ruby
require "qsar-report"

# create a new report
report = OpenTox::QMRFReport.new

# add a title
report.value "QSAR_title", "My QSAR Title"

# change 6.2 'Available information for the training set' set inchi and smiles to Yes
report.change_attributes "training_set_data", {:inchi => "Yes", :smiles => "Yes"}

# add a publication to the publication catalog
report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "MyName M (2016) My Publication Title, QSAR News, 10, 14-22", :url => "http://myqsarnewsmag.dom"}

# link/reference the publication to the report bibliography
report.ref_catalog :bibliography, :publications_catalog, :publications_catalog_1

# output
puts report.to_xml

# validate a report (as created above) against qmrf.xsd
report.validate
```
### QPRF
create a new QPRF report, add some content and show output:
```ruby
require "qsar-report"

# create a new QPRF report instance
report = OpenTox::QPRFReport.new

# Set Title of the report
report.Title = "My QPRF Report"

# Set Version
report.Version = "1"

# Set Date
report.Date = Time.now.strftime("%Y/%m/%d")

# Set the CAS number in chapter 1.1
report.value "1.1", "7732-18-5" # set CAS number for H²O

# print HTML version
puts report.to_html

# print formated JSON version
puts report.pretty_json

```

Installation
------------

  gem install qsar-report

Documentation
-------------
* [RubyDoc.info Code documentation](http://www.rubydoc.info/gems/qsar-report)
* For full information on QSAR reporting see: [JRC QSAR Model Database and QSAR Model Reporting Formats](https://eurl-ecvam.jrc.ec.europa.eu/databases/jrc-qsar-model-database-and-qsar-model-reporting-formats)

Copyright
---------
Copyright (c) 2016 Christoph Helma, Micha Rautenberg, Denis Gebele. See LICENSE for details.

Lazar QMRF Example
------------------
Here is an advanced example of the usage of the gem in lazar code:

{include:file:example/example.rb}

