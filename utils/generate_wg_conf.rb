require "erb"
require "rake"
require 'yaml'


node_files = ['nodes-apu.yml', 'nodes-bpi.yml', 'nodes-celerway.yml']

node_data = {}

node_files.each do |nf|
  data = YAML.load_file(nf)
  data.delete 'build'
  node_data.merge! data
end

key_data = YAML.load_file('secrets.yml')['wireguard_keys']

@nodes = []
node_data.each_pair do |k,v|
  name = v['hostname']
  #puts v
  ip = "198.19.250.2#{v['apu_id']}"
  wg_key = key_data[name]
  #puts "echo #{wg_key} | wg pubkey"
  pubkey = `echo #{wg_key} | wg pubkey`.chomp
  @nodes << {name: name, ipv4: ip, pubkey: pubkey }
end
#puts key_data

template = ERB.new File.new('utils/wireguard.conf.erb').read
puts template.result