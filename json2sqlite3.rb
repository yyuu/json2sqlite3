require 'formula'

class Json2sqlite3 < Formula
  homepage 'https://github.com/yyuu/json2sqlite3'
  head 'https://github.com/yyuu/json2sqlite3.git', branch: "main"

  depends_on "bash"
  depends_on "coreutils" => :recommended
  depends_on "jq"
  depends_on "sqlite" => :recommended

  def install
    if build.head?
      system "make PREFIX=#{prefix} install"
    else
      abort("only HEAD installation is supported")
    end
  end
end
