require 'formula'


class Libstemmer < Formula
  # upstream is constantly changing the tarball,
  # so doing checksum verification here would require
  # constant, rapid updates to this formula.
  head 'http://snowball.tartarus.org/dist/libstemmer_c.tgz'
  homepage 'http://snowball.tartarus.org/'
end

class Dovecot < Formula
  homepage 'http://dovecot.org/'
  url 'http://dovecot.org/releases/2.2/dovecot-2.2.5.tar.gz'
  mirror 'http://fossies.org/linux/misc/dovecot-2.2.5.tar.gz'
  sha256 '15b2cd607e6533f4805f471a61dd1c8bd81675cecc6ea6361504247dd9af5cf8'

  def install
    Libstemmer.new.brew { (buildpath/'libstemmer_c').install Dir['*'] }
    ENV.append 'CPPFLAGS', "-I/usr/local/Cellar/clucene/2.3.3.4/lib"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--libexecdir=#{libexec}",
                          "--sysconfdir=#{etc}",
                          "--localstatedir=#{var}",
                          "--with-ssl=openssl",
                          "--with-sqlite",
                          "--with-lucene",
                          "--with-zlib",
                          "--with-bzlib"
    system "make install"
  end

  def caveats; <<-EOS
For Dovecot to work, you will need to do the following:

1) Create configuration in #{etc}

2) If required by the configuration above, create a dovecot user and group

3) possibly create a launchd item in /Library/LaunchDaemons/#{plist_path.basename}, like so:
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>OnDemand</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
                <string>#{HOMEBREW_PREFIX}/sbin/dovecot</string>
                <string>-F</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>ServiceDescription</key>
        <string>Dovecot mail server</string>
</dict>
</plist>

Source: http://wiki.dovecot.org/LaunchdInstall
4) start the server using: sudo launchctl load /Library/LaunchDaemons/#{plist_path.basename}
    EOS
  end
end

