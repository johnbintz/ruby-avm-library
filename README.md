## The Ruby AVM Library

The Astronomy Visualization Metadata (AVM) standard is an extension of the Adobe XMP format. This
extension adds information to an astronomical image that describes the scientific data and methods
of collection that went in to producing the image. This Ruby library assists in reading the metadata from
XMP documents and writing out AVM data as a new XMP file.

## Installing the library

### From Bundler

In your Gemfile:

    gem 'ruby-avm-library'

To use the current development version:

    gem 'ruby-avm-library', :git => 'git://github.com/johnbintz/ruby-avm-library.git'

### From RubyGems

    gem install ruby-avm-library

## Basic usage

### Reading an XMP file

    require 'avm/image'
    
    image = AVM::Image.from_xml(File.read('my-file.xmp'))
    
    puts image.title #=> "The title of the image"

### Writing XML data

    image.to_xml #=> <xmp data in xml format />

### Creating an Image from scratch

    image = AVM::Image.new
    image.title = "The title of the image"
    
    observation = image.create_observation(:instrument => 'HST', :color_assignment => 'Green')
    contact = image.creator.create_contact(:name => 'John Bintz')

## Command line tool

`avm2avm` currently performs one function: take an XMP file from stdin and pretty print the image as a Hash:

    avm2avm < my-file.xmp

## More resources

* RDoc: [http://rdoc.info/github/johnbintz/ruby-avm-library/frames](http://rdoc.info/github/johnbintz/ruby-avm-library/frames)
* AVM Standard: [http://www.virtualastronomy.org/avm_metadata.php](http://www.virtualastronomy.org/avm_metadata.php)

