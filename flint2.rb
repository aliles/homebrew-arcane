require 'formula'

class Flint2 < Formula
  homepage 'http://flintlib.org/'
  url 'http://flintlib.org/flint-2.3.tar.gz'
  sha1 '58534b28ba30e63b183476b2b914cb767d1ec919'

  depends_on 'mpir'
  depends_on 'mpfr'

  option '32-bit'
  option 'skip-check', 'Do not run `make check` to verify libraries'

  fails_with :clang do
    cause <<-EOS.undent
      Build system requires a GCC compatible compiler.
      EOS
  end

  def install
    if MacOS.prefer_64_bit? and not build.build_32_bit?
        ENV['ABI'] = '64'
    else
        ENV['ABI'] = '32'
    end

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    system "make", "check" unless build.include? "skip-check"
  end
end
