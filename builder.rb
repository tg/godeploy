require_relative 'shell'

class Builder
  attr_reader :os, :arch

  @os = nil
  @arch = nil

  # initialize will assign packages to builder.
  # Only main packages will be imported.
  def initialize(*pkgs)
    @targets = Shell.call("go list -f '{{.Name}} {{.ImportPath}}' #{pkgs.join(' ')}").
      scan(/^main (.*)/).
      flatten
  end

  # Installs dependencies into $GOPATH/pkg/$GOOS_$GOARCH.
  # If download flag is set, go get will be used to fetch missing dependencies.
  def install_deps(download = false)
    call_go(download ? :get : :install,  "-v #{deps.join(' ')}")
  end

  # Create executables for platform specified in $GOOS and $GOARCH,
  # pack it into a tarball and pass path to it into a block.
  def build
    Dir.mktmpdir("godeploy-") { |dir|
      tarname = "#{File.basename dir}.tar.gz"

      # Build targets
      @targets.each do |path|
        call_go(:build, "-v -o #{dir}/#{File.basename path} #{path}")
      end

      # Tar+gzip
      Shell.call("cd #{dir} && tar -czf #{tarname} #{@targets.map { |p| File.basename p }.join(' ')}")

      yield "#{dir}/#{tarname}"
    }
  end

  def set_platform(os, arch)
    @os = os
    @arch = arch
  end

  private

  def call_go(tool, args)
    Shell.call("#{"GOOS=#{@os} GOARCH=#{@arch}" if @os && @arch} go #{tool} #{args}")
  end

  # Get non-standard dependencies for target packages
  def deps
    # Get all dependencies
    deps = Shell.call(%(go list -f '{{join .Deps "\\n"}}' #{@targets.join(' ')})).strip.split
    # Remove standard library
    Shell.call("go list std").strip.split.each do |pkg|
      deps.delete(pkg)
    end

    deps
  end
end
