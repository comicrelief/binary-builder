require 'mini_portile'
require 'tmpdir'
require 'fileutils'
require_relative 'determine_checksum'
require_relative '../lib/yaml_presenter'

class BaseRecipe < MiniPortile
  def initialize(name, version, options = {})
    super name, version

    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @files = [{
      url: self.url,
    }.merge(DetermineChecksum.new(options).to_h)]
  end

  def configure_options
    []
  end

  def compile
    execute('compile', [make_cmd, '-j4'])
  end

  def archive_filename
    "#{name}-#{version}-linux-x64.tgz"
  end

  def archive_files
    []
  end

  def archive_path_name
    ""
  end
end

