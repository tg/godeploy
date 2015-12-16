require_relative 'shell'

class Remote
  attr_accessor :dir, :tmpdir
  attr_reader :host

  def initialize(host)
    @host = host
    @dir = '.'
    @tmpdir = '.'
  end

  # Connect to remote host, create directories, return platform info.
  def ping
    os, arch =
      Shell.call("ssh #{@host} 'mkdir -p #{tmpdir} #{dir} && uname -sm'").
      strip.
      downcase.
      split(' ', 2).map(&:to_sym)
  end

  # Deploy tarball by copying it over via ssh and extracting.
  def deploy(tarfile)
    # Set up path to remote tarfile
    rtar = "#{tmpdir}/#{File.basename tarfile}"
    Shell.call("ssh #{@host} 'cat - > #{rtar} && tar -xf #{rtar} -C #{dir} && rm #{rtar}' < #{tarfile}")
  end

  def hostname
    host.split('@',2)[-1]
  end
end