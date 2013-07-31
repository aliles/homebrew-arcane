require 'formula'

class Piratte < Formula
  homepage 'http://hms.isi.jhu.edu/acsc/piratte/'
  url 'http://hms.isi.jhu.edu/acsc/piratte/piratte.zip'
  sha1 'ed9c29b128625ed216115126b8a63f176c1d27ad'
  version '2012-08-24'

  depends_on 'pkg-config' => :build
  depends_on 'glib'
  depends_on 'pbc'
  depends_on 'libbswabe-piratte'

  def install
    cd 'piratte/piratte' do
      system "./configure", "--disable-debug", "--prefix=#{prefix}"
      system "make", "install"
    end
    doc.install 'piratte/README'
  end
end
