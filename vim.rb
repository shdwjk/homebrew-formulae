require 'formula'

class Vim < Formula
  homepage 'http://www.vim.org/'
  # Get stable versions from hg repo instead of downloading an increasing
  # number of separate patches.
  url 'https://vim.googlecode.com/hg/', :revision => '1d1cce57421c'
  version '7.3.502'

  head 'https://vim.googlecode.com/hg/'

  def patches
	  # Add breakindent command
	  "https://retracile.net/raw-attachment/blog/2011/08/23/21.30/vim-7.3.285-breakindent.patch"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "--enable-gui=no",
                          "--without-x",
                          "--disable-nls",
                          "--enable-multibyte",
                          "--with-tlib=ncurses",
                          "--enable-pythoninterp",
                          "--enable-rubyinterp",
                          "--enable-cscope",
                          "--with-ruby-command=/usr/bin/ruby",
                          "--with-features=huge"
    system "make"
    system "make install"

    ln_s bin+"vim", "vi"
    bin.install "vi"
  end
end
