class Dir
  def self.require_multiple(*directories)
    Dir.glob(directories.map! {|d| File.join d, '*.rb'}).each {|f| require "./#{f}"}
  end
end