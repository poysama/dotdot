# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dotdot/version"

Gem::Specification.new do |s|
  s.name        = "dotdot"
  s.version     = Dotdot::VERSION
  s.authors     = ["Jan Mendoza"]
  s.email       = ["poymode@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Parking this gem}
  s.description = %q{Parking this gem}

  s.rubyforge_project = "dotdot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "sqlite3"
  s.add_dependency "sequel"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
