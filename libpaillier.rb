require 'formula'

class Libpaillier < Formula
  homepage 'http://hms.isi.jhu.edu/acsc/libpaillier/'
  url 'http://hms.isi.jhu.edu/acsc/libpaillier/libpaillier-0.8.tar.gz'
  sha1 'd0557c840a66d64b32727ce493bd09f191ea6e3f'

  depends_on 'gmp'

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
    doc.install 'README'
  end
end
