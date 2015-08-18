require 'spec_helper'
require 'fileutils'

describe 'building a binary', :integration do
  before do
    output, _ = run_binary_builder(binary_name, binary_version, checksum)
  end

  context 'when node is specified', binary: 'node' do
    let(:binary_name) { 'node' }
    let(:binary_version) { '0.12.2' }
    let(:checksum) { "don'tcare" }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = File.join(Dir.pwd, 'node-0.12.2-linux-x64.tar.gz')
      expect(File).to exist(binary_tarball_location)

      node_version_cmd = %q{./spec/assets/binary-exerciser.sh node-0.12.2-linux-x64.tar.gz node-v0.12.2-linux-x64/bin/node -e 'console.log(process.version)'}
      output, status = run(node_version_cmd)

      expect(status).to be_success
      expect(output).to include('v0.12.2')
      FileUtils.rm(binary_tarball_location)
    end
  end

  context 'when ruby is specified', binary: 'ruby' do
    let(:binary_name) { 'ruby' }
    let(:binary_version) { '2.2.0' }
    let(:checksum) { 'cd03b28fd0b555970f5c4fd481700852' }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = File.join(Dir.pwd, 'ruby-2.2.0-linux-x64.tgz')
      expect(File).to exist(binary_tarball_location)

      ruby_version_cmd = %q{./spec/assets/binary-exerciser.sh ruby-2.2.0-linux-x64.tgz ./bin/ruby -e 'puts RUBY_VERSION'}
      output, status = run(ruby_version_cmd)

      expect(status).to be_success
      expect(output).to include('2.0.0')
      FileUtils.rm(binary_tarball_location)
    end
  end

  context 'when jruby is specified', binary: 'jruby' do
    let(:binary_name) { 'jruby' }
    let(:binary_version) { '9.0.0.0-2.2.0' }
    let(:checksum) { '270ebfba1bb57aca3b41a98aadd53549' }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = File.join(Dir.pwd, 'jruby-9.0.0.0-2.2.0-linux-x64.tgz')
      expect(File).to exist(binary_tarball_location)

      jruby_version_cmd = %q{./spec/assets/jruby-exerciser.sh}
      output, status = run(jruby_version_cmd)

      expect(status).to be_success
      expect(output).to include('java 2.2.2')
      FileUtils.rm(binary_tarball_location)
    end
  end

  context 'when python is specified', binary: 'python' do
    let(:binary_name) { 'python' }
    let(:binary_version) { '3.4.3' }
    let(:checksum) { "don'tcare" }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = File.join(Dir.pwd, 'python-3.4.3-linux-x64.tgz')
      expect(File).to exist(binary_tarball_location)

      python_version_cmd = %q{env LD_LIBRARY_PATH=/tmp/binary-exerciser/lib ./spec/assets/binary-exerciser.sh python-3.4.3-linux-x64.tgz ./bin/python -c 'import sys;print(sys.version[:5])'}
      output, status = run(python_version_cmd)

      expect(status).to be_success
      expect(output).to include('3.4.3')
      FileUtils.rm(binary_tarball_location)
    end
  end

  context 'when httpd is specified', binary: 'httpd' do
    let(:binary_name) { 'httpd' }
    let(:binary_version) { '2.4.12' }
    let(:checksum) { 'b8dc8367a57a8d548a9b4ce16d264a13' }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = File.join(Dir.pwd, 'httpd-2.4.12-linux-x64.tgz')
      expect(File).to exist(binary_tarball_location)

      httpd_version_cmd = %q{env LD_LIBRARY_PATH=/tmp/binary-exerciser/lib ./spec/assets/binary-exerciser.sh httpd-2.4.12-linux-x64.tgz ./httpd/bin/httpd -v}

      output, status = run(httpd_version_cmd)

      expect(status).to be_success
      expect(output).to include('2.4.12')
      FileUtils.rm(binary_tarball_location)
    end
  end

  context 'when php is specified', binary: 'php' do
    let(:binary_name) { 'php' }
    let(:binary_version) { '5.6.9' }
    let(:checksum) { '561f37377833772ace776143c5687884' }

    it 'builds the specified binary, tars it, and places it in your current working directory' do
      binary_tarball_location = Dir.glob(File.join(Dir.pwd, 'php-5.6.9-linux-x64-*.tgz')).first
      expect(File).to exist(binary_tarball_location)

      php_version_cmd = %{./spec/assets/php-exerciser.sh 5.6.9 #{File.basename(binary_tarball_location)} ./php/bin/php -r 'echo phpversion();'}

      output, status = run(php_version_cmd)

      expect(status).to be_success
      expect(output).to include('5.6.9')
      FileUtils.rm(binary_tarball_location)
    end
  end
end
