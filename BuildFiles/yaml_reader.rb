#! /usr/bin/ruby

require 'yaml'

# usage
# ./BuildFiles/yaml_reader.rb path/to/yaml hoge fuga #=> yaml[hoge][fuga]

yaml = YAML.load_file(ARGV[0])
ARGV.shift
ARGV.each do |arg|
    yaml = yaml[arg]
end

puts yaml
