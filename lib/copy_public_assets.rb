# install files
if !File.exists?(RAILS_ROOT + '/public/stylesheets/fat-free-semantic-menu/fat-free-semantic-menu.css')
  source_dir = File.dirname(__FILE__) + "/../public/stylesheets/fat-free-semantic-menu"
  source_files = Dir[source_dir + "/*"]
  return if source_files.size == 0
  dest_dir = RAILS_ROOT + "/public/stylesheets/fat-free-semantic-menu"
  FileUtils.mkdir_p(dest_dir) if !File.exists?(dest_dir)
  source_files.each do |file|
    begin
      target = File.join(dest_dir, file.gsub(source_dir, ''))
      unless File.exist?(target) && FileUtils.identical?(file, target)
        FileUtils.cp(file, target)
      end 
    rescue Exception => e
      raise "Could not copy #{file} to #{target}: \n" + e 
    end
  end  
end