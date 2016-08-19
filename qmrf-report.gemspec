# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "qmrf-report"
  s.version     = File.read("./VERSION")
  s.date        = "2016-08-19"
  s.authors     = ["Micha Rautenberg"]
  s.email       = ["rautenberg@in-silico.ch"]
  s.homepage    = "http://github.com/opentox/qmrf-report"
  s.summary     = %q{qmrf-report}
  s.description = %q{QMRF reporting for OpenTox ruby module and Lazar Toxicology Predictions}
  s.license     = 'GPL-3'

  #s.rubyforge_project = "qmrf-report"

  s.files       = `git ls-files`.split("\n")
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency "nokogiri"

end