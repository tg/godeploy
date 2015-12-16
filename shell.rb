module Shell
  def self.call(cmd)
    out = `#{cmd}`
    exit 1 if $?.exitstatus != 0
    out
  end
end