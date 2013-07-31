require 'formula'

class LibbswabeCpabe < Formula
  homepage 'http://hms.isi.jhu.edu/acsc/cpabe/'
  url 'http://hms.isi.jhu.edu/acsc/cpabe/libbswabe-0.9.tar.gz'
  sha1 'ed94479cde2cc0351487597be477ac7f87242727'

  keg_only 'Conflicts with libbswabe for PIRATTE'

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'pbc'

  def install
    system "./configure", "--disable-debug", "--prefix=#{prefix}"
    system "make", "install"
    doc.install 'README'
  end
end
