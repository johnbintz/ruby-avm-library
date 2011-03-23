require 'thor'
require 'avm/image'
require 'pp'

module AVM
  # The CLI interface
  class CLI < ::Thor
    default_task :convert

    desc 'convert', "Convert a file from one format to another"
    def convert
      data = $stdin.read

      pp AVM::Image.from_xml(data).to_h
    end
  end
end

