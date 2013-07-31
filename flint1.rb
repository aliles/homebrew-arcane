require 'formula'

class Flint1 < Formula
  homepage 'http://flintlib.org/'
  url 'http://flintlib.org/flint-1.6.tgz'
  sha1 '878a725339a8de8c92900d378a814569f60481f9'

  keg_only 'Conflicts with flint2'

  depends_on 'mpir'
  depends_on 'mpfr'

  def install
    system "bash", "-c", "source flint_env; make library"

    system "mkdir", "-p", "extra/zn_poly/src/"
    Dir['zn_poly/include/*.h'].each do |header|
      system "cp", header, 'extra/zn_poly/src/'
    end

    include.install Dir['*.h']
    include.install Dir['extra/zn_poly']
    lib.install 'libflint.dylib'
  end
end
