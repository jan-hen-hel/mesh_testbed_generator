require "erb"
require "rake"
require 'yaml'


node_files = ['nodes-apu.yml', 'nodes-bpi.yml', 'nodes-celerway.yml']

node_data = {}

node_files.each do |nf|
  data = YAML.load_file(nf)
  node_data.merge! data.nodes
end

key_data = YAML.load_file(secrets.yml)