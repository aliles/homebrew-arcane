require 'formula'

class Mpir < Formula
  homepage 'http://mpir.org/'
  url 'http://mpir.org/mpir-2.6.0.tar.bz2'
  sha1 '28a91eb4d2315a9a73dc39771acf2b99838b9d72'

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

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
    system "make", "check" unless build.include? "skip-check"
  end
end
