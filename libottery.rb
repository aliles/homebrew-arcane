require 'formula'

class Libottery < Formula
  homepage 'https://github.com/nmathewson/libottery'
  head 'https://github.com/nmathewson/libottery.git'
  # url 'https://github.com/nmathewson/libottery.git'
  # version '0.0'

  option 'skip-check', 'Do not run `make check` to verify library'

  def install
    system "make"
    system "make", "check" unless build.include? "skip-check"

    include.install 'src/ottery.h'
    include.install 'src/ottery_common.h'
    lib.install 'libottery.a'
  end
end
