require 'formula'

class Json2sqlite3 < Formula
  VERSION = '0.20240220.1'
  homepage 'https://github.com/yyuu/json2sqlite3'
  url 'https://github.com/yyuu/json2sqlite3.git', tag: "v#{VERSION}"
  head 'https://github.com/yyuu/json2sqlite3.git', branch: "main"

  depends_on "bash"
  depends_on "coreutils" => :recommended
  depends_on "jq"
  depends_on "sqlite" => :recommended

  def install
    if build.head?
      system "make PREFIX=#{prefix} VERSION=HEAD install"
    else
      system "make PREFIX=#{prefix} VERSION=#{VERSION} install"
    end
  end
end
