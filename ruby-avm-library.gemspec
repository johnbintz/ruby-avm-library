# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby-avm-library/version"

Gem::Specification.new do |s|
  s.name        = "ruby-avm-library"
  s.version     = Ruby::Avm::Library::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Bintz"]
  s.email       = ["bintz@stsci.edu"]
  s.homepage    = ""
  s.summary     = %q{Library for reading and writing AVM XMP metadata}
  s.description = %q{This library makes working with Astronomy Visualization Metadata (AVM) tags within XMP easier. Reading existing XMP files and generating new ones is made simple through a fully object oriented interface.}

  s.rubyforge_project = "ruby-avm-library"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mocha'

  s.add_dependency 'nokogiri'
  s.add_dependency 'thor'
end
