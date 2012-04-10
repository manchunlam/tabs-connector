# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tabs-connector/version"

Gem::Specification.new do |s|
  s.name        = "tabs-connector"
  s.version     = TabsConnector::VERSION
  s.authors     = ["Joe Lam"]
  s.email       = ["joelam@vitrue.com"]
  s.homepage    = "https://www.vitrue.com"
  s.summary     = %q{A Library for IFrame Modules to Communicate with Tabs}
  s.description = %q{A Library for IFrame Modules to Communicate with Tabs}

  s.rubyforge_project = "tabs-connector"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
