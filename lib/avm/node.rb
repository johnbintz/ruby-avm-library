require 'delegate'

module AVM
  class Node < DelegateClass(Nokogiri::XML::Node)
    def initialize(xmp, node)
      @xmp, @node = xmp, node
      super(@node)
    end

    def at_xpath(path)
      if node = @node.at_xpath(path, @xmp.namespaces)
        self.class.new(@xmp, node)
      else
        nil
      end
    end

    def search(path)
      self.class.from_nodeset(@xmp, @node.search(path, @xmp.namespaces))
    end

    def self.from_nodeset(xmp, nodeset)
      nodeset.collect { |node| new(xmp, node) }
    end
  end
end

