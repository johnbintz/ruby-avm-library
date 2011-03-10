require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class QuickFixFormatter < BaseTextFormatter
        def dump_summary(duration, example_count, failure_count, pending_count)
        end

        def dump_profile
        end

        def dump_pending
        end

        def dump_failures
          failed_examples.each do |example|
            output.puts "%s:%s:%s" % [ example.file_path, example.metadata[:line_number], example.metadata[:execution_result][:exception].message ]
          end
        end
      end
    end
  end
end


