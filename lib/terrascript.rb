require 'stringio'

class Transform

  def initialize(inFd, outFd = $stdout)
    @in = inFd
    @out = outFd
    @mode = :read
    @argName = "block"
    @arg = ""
    @body = ""
    @depth = 0
  end

  def process
    @in.each do |line|
      processLine line
    end
  end

  protected def transform
    s = $stdout
    $stdout = @out

    # process nested directives
    if @arg.include? "@inline"
      stream = StringIO.new(@arg)
      outStream = StringIO.new
      Transform.new(stream, outStream).process
      @arg = outStream.string
    end

    eval("lambda { |#{@argName}|\n#{@body}\n}").call(@arg)

    $stdout = s
  end

  protected def keyword?(line, s)
    line.lstrip.start_with? ("@" << s)
  end

  protected def processLine(line)
    case @mode

    when :read
      case
      when keyword?(line, "inline")
        args = line.split(' ')
        if !args[1].nil?
          @argName = args[1]
        end
        @mode = :body
      else
        @out.puts line
      end

    when :arg
      case
      when keyword?(line, "end")
        if @depth == 0
          transform
          @arg = ""
          @body = ""
          @mode = :read
        else
          @depth = @depth - 1
          @arg << line
        end

      when keyword?(line, "inline")
        @depth = @depth + 1
        @arg << line

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
