require 'terrascript'
require 'minitest/autorun'
require 'stringio'

TC_BASIC1_IN = <<EOF
abc
@inline
puts block
puts "test"
puts block
return
efg
@end
EOF

TC_BASIC1_OUT = <<EOF
abc
efg
test
efg
EOF

TC_ARG_IN = <<EOF
abc
@inline xyz
puts xyz
puts "test"
puts xyz
return
efg
@end
EOF

TC_ARG_OUT = TC_BASIC1_OUT

TC_WHITESPACE_IN = <<EOF
 abc
	  @inline
   puts block
 return
x blk x
	tab blk
	@end
EOF

TC_WHITESPACE_OUT = <<EOF
 abc
x blk x
	tab blk
EOF

TC_NESTED_IN = <<EOF
abc
@inline
        puts block
        return
test
        @inline
        [1, 2, 3].each do |num|
            puts num, block
        end
        return
repeat
        @end
@end
EOF

TC_NESTED_OUT = <<EOF
abc
test
1
repeat
2
repeat
3
repeat
EOF

class TestTransform < Minitest::Test

  def test(input, output)
    f = StringIO.new(input)
    out = StringIO.new
    Transform.new(f, out).process
    assert_equal output, out.string
  end

  def test_basic
    test(TC_BASIC1_IN, TC_BASIC1_OUT)
  end

  def test_arg
    test(TC_ARG_IN, TC_ARG_OUT)
  end

  def test_whitespaces
    test(TC_WHITESPACE_IN, TC_WHITESPACE_OUT)
  end

  def test_nested
    test(TC_NESTED_IN, TC_NESTED_OUT)
  end

end
