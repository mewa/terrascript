#!/usr/bin/env ruby

require 'digest'
require 'fileutils'

class Transform
  def transform
    eval("lambda { |#{@argName}|\n#{@body}\n}").call(@arg)
  end

  def initialize(fname)
    @fname = fname
    @mode = :read
    @argName = "block"
    @arg = ""
    @body = ""
  end

  def process
    $stdout = File.new(@fname.gsub(".tfrb", ".tf"), "w")
    File.open(@fname).each do |line|
      processLine line
    end
    $stdout.close
    $stdout = STDOUT
  end

  def processLine(line)
    case @mode

    when :read
      if line.start_with?("@inline")
        args = line.split(' ')
        if !args[1].nil?
          @argName = args[1]
        end
        @mode = :body
      else
        puts line
      end

    when :arg
      if line.start_with?("@end")
        @arg << "\n"
        transform
        @mode = :read
      else
        @arg << line
      end

    when :body
      @body << line
      if line.start_with?("return")
        @mode = :arg
      end

    end
  end

end

def processFile f
  hash_dir = ".terraform/.tfrb"
  FileUtils.mkdir_p(hash_dir)

  fname_hash = Digest::SHA256.hexdigest f

  hash_file = "#{hash_dir}/#{fname_hash}"

  old_sha = ""
  if File.file?(hash_file)
    old_sha = File.read hash_file
  end

  sha = Digest::SHA256.hexdigest File.read f

  if old_sha != sha
    File.open(hash_file, "w") { |hash_fd| hash_fd.write sha}

    File.open(f).each do |l|
      Transform.new(f).process
    end
    puts "=> Done"
  else
    puts "=> Unchanged"
  end
end

Dir.glob("**/*.tfrb").each do |f|
  puts "Processing #{f}"
  processFile(f)
end

exec("terraform", *ARGV)
