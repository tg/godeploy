module Platform
  # Guess GOOS and GOARCH from os/arch provided by uname
  def self.guess_from_uname(os, arch)
    goos =
      case os.to_sym
      when :darwin, :dragonfly, :freebsd, :linux, :netbsd,
           :openbsd, :plan9, :solaris, :windows
           os.to_sym
      end

    goarch =
      case arch
      when :i386, :i686
        :"386"
      when :x86_64
        :amd64
      end

      [goos, goarch]
  end
end