require "bundler/gem_tasks"

desc "Update the build date for the gem"
task :update_build_date do
  version_file = File.join(".", "lib", "swagr", "version.rb")
  lines = File.readlines(version_file)
  lines = lines.map do |line|
    if line =~ /(\s*)GemBuildDate = "(.+)"/
      timestamp = Time.new.strftime "%Y-%m-%d %H:%M.%S"
      "#{$1}GemBuildDate = #{timestamp.inspect}\n"
    else
      line
    end
  end
  File.open(version_file, "w") {|fh| fh.write lines.join()}
end

desc "Update build date then build and install gem"
task :uinstall => [:update_build_date, :install] do
  # Nothing to do! Work is done by the two other tasks...
end