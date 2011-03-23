watch('lib/(.*)\.rb') { |file| reek(file[0]) }
watch('spec/(.*)_spec\.rb') { |file| reek("lib/#{file[1]}.rb") }

def reek(file = nil)
  file ||= Dir['lib/**/*.rb'].join(' ')
  spec_file = file.gsub('lib/', 'spec/').gsub('.rb', '_spec.rb')

  system %{bundle exec rspec -c #{spec_file}}
  system %{reek #{file}}
end

reek
