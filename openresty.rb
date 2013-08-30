require 'formula'

class Openresty < Formula
  homepage 'http://openresty.org/'
  url 'http://openresty.org/download/ngx_openresty-1.2.8.6.tar.gz'
  sha1 '4b47862a77577d06447d17c935e94dc935c279e5'

  option 'luajit', 'Build with LuaJIT support'
  option 'drizzle', 'Build with Drizzle module'
  option 'postgres', 'Build with Postgres module'
  option 'iconv', 'Build with iconv module'

  def install
    args = ["--prefix=#{prefix}"]

    args << "--with-luajit" if build.include? "luajit"
    args << "--with-http_drizzle_module" if build.include? "drizzle"
    args << "--with-http_postgres_module" if build.include? "postgres"
    args << "--with-http_iconv_module" if build.include? "iconv"

    system "./configure", *args
    system "make", "install"
  end
end
