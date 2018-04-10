class Transform

  def initialize(inFd, outFd = $stdout)
    @in = inFd
    @out = outFd
    @mode = :read
    @argName = "block"
    @arg = ""
    @body = ""
  end

  def process
    @in.each do |line|
      processLine line
    end
  end

  protected def transform
    s = $stdout
    $stdout = @out
    eval("lambda { |#{@argName}|\n#{@body}\n}").call(@arg)
    $stdout = s
  end

  protected def processLine(line)
    case @mode

    when :read
      if line.lstrip.start_with?("@inline")
        args = line.split(' ')
        if !args[1].nil?
          @argName = args[1]
        end
        @mode = :body
      else
        @out.puts line
      end

    when :arg
      if line.lstrip.start_with?("@end")
        transform
        @arg = ""
        @body = ""
        @mode = :read
      else
        @arg << line
      end

    when :body
      @body << line
      if line.lstrip.start_with?("return")
        @mode = :arg
      end

    end
  end

end
