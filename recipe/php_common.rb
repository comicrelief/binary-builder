# encoding: utf-8
require_relative 'base'
require 'uri'

class RabbitMQRecipe < BaseRecipe
  def url
    "https://github.com/alanxz/rabbitmq-c/archive/v#{version}.tar.gz"
  end

  def work_path
    File.join(tmp_path, "rabbitmq-c-#{@version}")
  end

  def configure
  end

  def compile
    execute('compile', ['bash', '-c', 'cmake .'])
    execute('compile', ['bash', '-c', 'cmake --build .'])
    execute('compile', ['bash', '-c', 'cmake -DCMAKE_INSTALL_PREFIX=/usr/local .'])
    execute('compile', ['bash', '-c', 'cmake --build . --target install'])
  end
end

class LibRdKafkaRecipe < BaseRecipe
  def url
    "https://github.com/edenhill/librdkafka/archive/#{version}.tar.gz"
  end

  def work_path
    File.join(tmp_path, "librdkafka-#{version}")
  end

  def configure_prefix
    '--prefix=/usr'
  end

  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, 'w') { |f| f.write digest }

    execute('configure', %w(bash ./configure) + computed_options)
  end
end

class PeclRecipe < BaseRecipe
  def url
    "http://pecl.php.net/get/#{name}-#{version}.tgz"
  end

  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config"
    ]
  end

  def configure
    return if configured?

    md5_file = File.join(tmp_path, 'configure.md5')
    digest   = Digest::MD5.hexdigest(computed_options.to_s)
    File.open(md5_file, 'w') { |f| f.write digest }

    execute('configure', 'phpize')
    execute('configure', %w(sh configure) + computed_options)
  end
end

class LibmemcachedRecipe < BaseRecipe
  def url
    "https://launchpad.net/libmemcached/1.0/#{version}/+download/libmemcached-#{version}.tar.gz"
  end
end

class LuaRecipe < BaseRecipe
  def url
    "http://www.lua.org/ftp/lua-#{version}.tar.gz"
  end

  def configure
  end

  def compile
    execute('compile', ['bash', '-c', "#{make_cmd} linux MYCFLAGS=-fPIC"])
  end

  def install
    return if installed?

    execute('install', ['bash', '-c', "#{make_cmd} install INSTALL_TOP=#{path}"])
  end
end

class IonCubeRecipe < BaseRecipe
  def url
    "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64_#{version}.tar.gz"
  end

  def configure; end

  def compile; end

  def install; end

  def path
    tmp_path
  end
end

class HiredisRecipe < BaseRecipe
  def url
    "https://github.com/redis/hiredis/archive/v#{version}.tar.gz"
  end

  def configure
  end

  def install
    return if installed?

    execute('install', ['bash', '-c', "LIBRARY_PATH=lib PREFIX='#{path}' #{make_cmd} install"])
  end
end

class PHPIRedisRecipe < PeclRecipe
  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config",
      '--enable-phpiredis',
      "--with-hiredis-dir=#{@hiredis_path}"
    ]
  end

  def url
    "https://github.com/nrk/phpiredis/archive/#{version}.tar.gz"
  end
end

class AmqpPeclRecipe < PeclRecipe
  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config"
    ]
  end
end

class OraclePeclRecipe < PeclRecipe
  def configure_options
    [
      "--with-oci8=shared,instantclient,/oracle"
    ]
  end

  def self.oracle_sdk?
    File.directory?('/oracle')
  end

  def setup_tar
    system <<-eof
      cp -an /oracle/libclntshcore.so.12.1 #{@php_path}/lib
      cp -an /oracle/libclntsh.so #{@php_path}/lib
      cp -an /oracle/libclntsh.so.12.1 #{@php_path}/lib
      cp -an /oracle/libipc1.so #{@php_path}/lib
      cp -an /oracle/libmql1.so #{@php_path}/lib
      cp -an /oracle/libnnz12.so #{@php_path}/lib
      cp -an /oracle/libociicus.so #{@php_path}/lib
      cp -an /oracle/libons.so #{@php_path}/lib
    eof
  end
end

class OraclePdoRecipe < PeclRecipe
  def url
    "file://#{@php_source}/ext/pdo_oci-#{version}.tar.gz"
  end

  def download
    # this copys an extension folder out of the PHP source director (i.e. `ext/<name>`)
    # it pretends to download it by making a zip of the extension files
    # that way the rest of the PeclRecipe works normally
    files_hashs.each do |file|
      path = URI(file[:url]).path.rpartition('-')[0] # only need path before the `-`, see url above
      system <<-eof
        echo 'tar czf "#{file[:local_path]}" -C "#{File.dirname(path)}" "#{File.basename(path)}"'
        tar czf "#{file[:local_path]}" -C "#{File.dirname(path)}" "#{File.basename(path)}"
      eof
    end
  end

  def configure_options
    [
      "--with-pdo-oci=shared,instantclient,/oracle,#{OraclePdoRecipe.oracle_version}"
    ]
  end

  def self.oracle_version
    Dir["/oracle/*"].select {|i| i.match(/libclntsh\.so\./) }.map {|i| i.sub(/.*libclntsh\.so\./, '')}.first
  end

  def setup_tar
    system <<-eof
      cp -an /oracle/libclntshcore.so.12.1 #{@php_path}/lib
      cp -an /oracle/libclntsh.so #{@php_path}/lib
      cp -an /oracle/libclntsh.so.12.1 #{@php_path}/lib
      cp -an /oracle/libipc1.so #{@php_path}/lib
      cp -an /oracle/libmql1.so #{@php_path}/lib
      cp -an /oracle/libnnz12.so #{@php_path}/lib
      cp -an /oracle/libociicus.so #{@php_path}/lib
      cp -an /oracle/libons.so #{@php_path}/lib
    eof
  end
end

class LuaPeclRecipe < PeclRecipe
  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config",
      "--with-lua=#{@lua_path}"
    ]
  end
end

class PHPProtobufPeclRecipe < PeclRecipe
  def url
    "https://github.com/allegro/php-protobuf/archive/v#{version}.tar.gz"
  end
end

class PhalconRecipe < PeclRecipe
  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config",
      '--enable-phalcon'
    ]
  end

  def set_php_version(php_version)
    @php_version = php_version
  end

  def work_path
    "#{super}/build/#{@php_version}/64bits"
  end

  def url
    "https://github.com/phalcon/cphalcon/archive/v#{version}.tar.gz"
  end
end

class MemcachedPeclRecipe < PeclRecipe
  def configure_options
    [
      "--with-php-config=#{@php_path}/bin/php-config",
      "--with-libmemcached-dir=#{@libmemcached_path}",
      '--enable-memcached-sasl',
      '--enable-memcached-msgpack',
      '--enable-memcached-igbinary',
      '--enable-memcached-json'
    ]
  end
end

class SuhosinPeclRecipe < PeclRecipe
  def url
    "http://download.suhosin.org/suhosin-#{version}.tar.gz"
  end
end

class TwigPeclRecipe < PeclRecipe
  def url
    "https://github.com/twigphp/Twig/archive/v#{version}.tar.gz"
  end

  def work_path
    "#{super}/ext/twig"
  end
end

class XcachePeclRecipe < PeclRecipe
  def url
    "http://xcache.lighttpd.net/pub/Releases/#{version}/xcache-#{version}.tar.gz"
  end
end

class XhprofPeclRecipe < PeclRecipe
  def url
    "https://github.com/phacility/xhprof/archive/#{version}.tar.gz"
  end

  def work_path
    "#{super}/extension"
  end
end

class SnmpRecipe
  def initialize(php_path)
    @php_path = php_path
  end

  def cook
    system <<-eof
      cd #{@php_path}
      mkdir -p mibs
      cp "/usr/lib/x86_64-linux-gnu/libnetsnmp.so.30" lib/
      # copy mibs that are packaged freely
      cp /usr/share/snmp/mibs/* mibs
      # copy mibs downloader & smistrip, will download un-free mibs
      cp /usr/bin/download-mibs bin
      cp /usr/bin/smistrip bin
      sed -i "s|^CONFDIR=/etc/snmp-mibs-downloader|CONFDIR=\$HOME/php/mibs/conf|" bin/download-mibs
      sed -i "s|^SMISTRIP=/usr/bin/smistrip|SMISTRIP=\$HOME/php/bin/smistrip|" bin/download-mibs
      # copy mibs download config
      cp -R /etc/snmp-mibs-downloader mibs/conf
      sed -i "s|^DIR=/usr/share/doc|DIR=\$HOME/php/mibs/originals|" mibs/conf/iana.conf
      sed -i "s|^DEST=iana|DEST=|" mibs/conf/iana.conf
      sed -i "s|^DIR=/usr/share/doc|DIR=\$HOME/php/mibs/originals|" mibs/conf/ianarfc.conf
      sed -i "s|^DEST=iana|DEST=|" mibs/conf/ianarfc.conf
      sed -i "s|^DIR=/usr/share/doc|DIR=\$HOME/php/mibs/originals|" mibs/conf/rfc.conf
      sed -i "s|^DEST=ietf|DEST=|" mibs/conf/rfc.conf
      sed -i "s|^BASEDIR=/var/lib/mibs|BASEDIR=\$HOME/php/mibs|" mibs/conf/snmp-mibs-downloader.conf
      # copy data files
      mkdir mibs/originals
      cp -R /usr/share/doc/mibiana mibs/originals
      cp -R /usr/share/doc/mibrfcs mibs/originals
    eof
  end
end

# PHP 5 and PHP 7 Common recipes

def hiredis_recipe
  HiredisRecipe.new('hiredis', '0.13.3', md5: '43dca1445ec6d3b702821dba36000279')
end

def phpiredis_recipe
  PHPIRedisRecipe.new('phpiredis', 'a64e3bfe7', md5: '84c68887c3b9744106f4ccb2969f3a2a',
                                                php_path: php_recipe.path,
                                                hiredis_path: hiredis_recipe.path)
end


def amqppecl_recipe
  AmqpPeclRecipe.new('amqp', '1.7.1', md5: '901befb3ba9c906e88ae810f83599baf',
                                      php_path: php_recipe.path,
                                      rabbitmq_path: rabbitmq_recipe.work_path)
end

def lua_recipe
  LuaRecipe.new('lua', '5.3.3', md5: '703f75caa4fdf4a911c1a72e67a27498')
end

def rabbitmq_recipe
  RabbitMQRecipe.new('rabbitmq', '0.8.0', md5: '51d5827651328236ecb7c60517c701c2')
end

def librdkafka_recipe
  LibRdKafkaRecipe.new('librdkafka', '0.9.1', md5: 'feb25faed02815f60ff363b2f40ba1b9')
end

def install_cassandra_dependencies
  cassandra_version = "2.4.3"
  system <<-eof
    wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.8.0/libuv_1.8.0-1_amd64.deb
    wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.8.0/libuv-dev_1.8.0-1_amd64.deb
    wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v#{cassandra_version}/cassandra-cpp-driver_#{cassandra_version}-1_amd64.deb
    wget http://downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v#{cassandra_version}/cassandra-cpp-driver-dev_#{cassandra_version}-1_amd64.deb

    dpkg -i libuv_1.8.0-1_amd64.deb
    dpkg -i libuv-dev_1.8.0-1_amd64.deb
    dpkg -i cassandra-cpp-driver_#{cassandra_version}-1_amd64.deb
    dpkg -i cassandra-cpp-driver-dev_#{cassandra_version}-1_amd64.deb
  eof
end
