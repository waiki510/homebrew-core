class Megatools < Formula
  desc "Command-line client for Mega.co.nz"
  homepage "https://megatools.megous.com/"
  url "https://megatools.megous.com/builds/megatools-1.11.1.20230212.tar.gz"
  sha256 "ecfa2ee4b277c601ebae648287311030aa4ca73ea61ee730bc66bef24ef19a34"
  license "GPL-2.0-or-later" => { with: "openvpn-openssl-exception" }

  livecheck do
    url "https://megatools.megous.com/builds/"
    regex(/href=.*?megatools[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_ventura:  "e8925b9fb4ccf03fd6d15947b6ae21e6a175e4c345419a410d75a9a1fca9d125"
    sha256 cellar: :any, arm64_monterey: "1d96ad8f3ab6eeee0cbb8b378690dbf385edec19cc84ccd8d206e6db19607f0f"
    sha256 cellar: :any, arm64_big_sur:  "46ca1a3927faa2401ef76da94d888694e488d85bd2b6f5e651dfb00bd267ddba"
    sha256 cellar: :any, ventura:        "b75784854de2d3d39c4f9f5ec474cc3bde78c9e5ef7075ad85b64cdb55bc9f09"
    sha256 cellar: :any, monterey:       "87cd69892db63c73b019cd66320485970c4d703a279a4193ecb889b0f9356170"
    sha256 cellar: :any, big_sur:        "405fac1aace5b78db94c3a23bec9c240ca3c93164708baa11b2eedd4746e17e9"
    sha256 cellar: :any, catalina:       "4520b8dbb5260e663b565d9b57a6f35a9cf180d46f37fd280ab1ddf7cf97f740"
    sha256               x86_64_linux:   "57eeaa7ca64c95195ac12d5b2aef86fe558902420f91c704012b0afc726d8003"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "curl" # curl >= 7.85.0 is required
  depends_on "glib"
  depends_on "glib-networking"
  depends_on "openssl@1.1"

  def install
    mkdir "build" do
      system "meson", "setup", *std_meson_args, ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    # Downloads a publicly hosted file and verifies its contents.
    system "#{bin}/megadl",
      "https://mega.co.nz/#!3Q5CnDCb!PivMgZPyf6aFnCxJhgFLX1h9uUTy9ehoGrEcAkGZSaI",
      "--path", "testfile.txt"
    assert_equal File.read("testfile.txt"), "Hello Homebrew!\n"
  end
end
