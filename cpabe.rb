require 'formula'

class Cpabe < Formula
  homepage 'http://hms.isi.jhu.edu/acsc/cpabe/'
  url 'http://hms.isi.jhu.edu/acsc/cpabe/cpabe-0.11.tar.gz'
  sha1 '3781df5b3c8f900120dfa124345c66d35bfdd234'

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'libbswabe-cpabe'

  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make", "install"
    doc.install 'README'
  end
end
