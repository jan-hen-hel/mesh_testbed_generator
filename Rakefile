require "erb"
require "rake"
require 'yaml'
CONFIGURATION = {
  'openwrt_version' => "23.05.5",
  'platform' => 'x86',
  'platform_type' => '64',
  'download_base' => '',
  'sdk_base' => '',
  'directory' => '' 
}
task :default => :generate_all
task :generate_all do
  if (! (File.exists? 'secrets.yml'))
    raise "\n \t >>> Please decrypt secrets.yml.gpg first \n\n\n"
  end
  secrets = YAML.load_file("secrets.yml")
  nodes = YAML.load_file("nodes.yml")
  openwrt_version = nodes['build']['openwrt_version']
  platform = nodes['build']['platform']
  platform_type = nodes['build']['platform_type']
  CONFIGURATION['openwrt_version'] =  openwrt_version
  CONFIGURATION['platform'] = platform
  CONFIGURATION['platform_type'] = platform_type
  CONFIGURATION['download_base'] = "https://downloads.openwrt.org/releases/#{openwrt_version}/targets/#{platform}/#{platform_type}/"
  CONFIGURATION['sdk_base'] = "openwrt-imagebuilder-#{openwrt_version}-#{platform}-#{platform_type}.Linux-x86_64"
  sdk_archive = "#{CONFIGURATION['sdk_base']}.tar.xz"
  unless File.exists? CONFIGURATION['sdk_base'] 
    system("wget #{CONFIGURATION['download_base']}#{sdk_archive}") unless File.exists? sdk_archive
    system("tar xf #{sdk_archive}")
  end
  nodes.delete('build')
  nodes.values.each {|v| generate_node v,secrets}
end

def generate_node(node_cfg,secrets)
  dir_name = "#{CONFIGURATION['sdk_base']}/files_generated"
  prepare_directory(dir_name)
  Dir.glob("#{dir_name}/**/*.erb").each do |erb_file|
    basename = erb_file.gsub '.erb',''
    process_erb(node_cfg,erb_file,basename,secrets)    
  end
  generate_firmware(node_cfg['hostname'], node_cfg['profile'], node_cfg['packages'])
end

def prepare_directory(dir_name)
  FileUtils.rm_r dir_name if File.exists? dir_name
  dir = CONFIGURATION['directory']
  FileUtils.cp_r dir, dir_name, :preserve => true
end

def process_erb(node,erb,base,secrets)
  @node = node
  @secrets = secrets
  template = ERB.new File.new(erb).read
  File.open(base, 'w') { |file| file.write(template.result) }
  FileUtils.rm erb
end

def generate_firmware(node_name,profile,packages)
  FileUtils.rm_r "#{CONFIGURATION['sdk_base']}/bin/" if File.exists?  "#{CONFIGURATION['sdk_base']}/bin/"
  puts "Exec: make -C '#{CONFIGURATION['sdk_base']}' image PROFILE=#{profile} PACKAGES='#{packages}'  FILES=./files_generated"
  system("make -C '#{CONFIGURATION['sdk_base']}' image PROFILE=#{profile} PACKAGES='#{packages}'  FILES=./files_generated")

 Dir.glob("#{CONFIGURATION['sdk_base']}/bin/targets/#{CONFIGURATION['platform']}/#{CONFIGURATION['platform_type']}/openwrt-*").each do |bin_file|
    new_name = File.basename(bin_file).gsub "openwrt-#{CONFIGURATION['openwrt_version']}-#{CONFIGURATION['platform']}-#{CONFIGURATION['platform_type']}-#{profile}","#{node_name}"
    puts "Moving #{bin_file} to bin/#{new_name} "
    FileUtils.mv(bin_file, "bin/#{new_name}")
  end
  # Unzip certain images for easier dd'ing
  Dir.glob("bin/*.img.gz").each do |zipped_image|
    system("gunzip #{zipped_image}")
  end
end

