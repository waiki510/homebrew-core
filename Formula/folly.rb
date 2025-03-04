class Folly < Formula
  desc "Collection of reusable C++ library artifacts developed at Facebook"
  homepage "https://github.com/facebook/folly"
  url "https://github.com/facebook/folly/archive/v2022.01.24.00.tar.gz"
  sha256 "5c8511eaed524da292ae7f624269153d45533995cb88e34f487ded49f8db388d"
  license "Apache-2.0"
  head "https://github.com/facebook/folly.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "0067e58cd36f278b727ea871e6b8f7e0793af7096ea185a32f209b795f9772c4"
    sha256 cellar: :any,                 arm64_big_sur:  "a52e49011d714447d9dc3f16f8c016e09755468339420e387a8484bc313b2185"
    sha256 cellar: :any,                 monterey:       "5e10f4910a655af2ce0b8fa311256cd26d4ff1797afed47c794c14acb24585ee"
    sha256 cellar: :any,                 big_sur:        "ecaa8c9bda71a4ef3ff6a6bfb1752ee845bda6d432de81895cbf1052274906d9"
    sha256 cellar: :any,                 catalina:       "6a1a0888ca9f9e1a30972bdd5259d939e24f9abf7567d38cda0801f40b40a954"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c6a5e6652e9a74bf08ad65f3b92284a9efdffa44ee3fd5dcabc7a0fdd635fa23"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmt"
  depends_on "gflags"
  depends_on "glog"
  depends_on "libevent"
  depends_on "lz4"
  depends_on "openssl@1.1"
  depends_on "snappy"
  depends_on "xz"
  depends_on "zstd"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1100
  end

  on_linux do
    depends_on "gcc"
  end

  fails_with :clang do
    build 1100
    # https://github.com/facebook/folly/issues/1545
    cause <<-EOS
      Undefined symbols for architecture x86_64:
        "std::__1::__fs::filesystem::path::lexically_normal() const"
    EOS
  end

  fails_with gcc: "5"

  def install
    ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)

    mkdir "_build" do
      args = std_cmake_args + %w[
        -DFOLLY_USE_JEMALLOC=OFF
      ]

      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=ON"
      system "make"
      system "make", "install"

      system "make", "clean"
      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=OFF"
      system "make"
      lib.install "libfolly.a", "folly/libfollybenchmark.a"
    end
  end

  test do
    # Force use of Clang rather than LLVM Clang
    ENV.clang if OS.mac?

    (testpath/"test.cc").write <<~EOS
      #include <folly/FBVector.h>
      int main() {
        folly::fbvector<int> numbers({0, 1, 2, 3});
        numbers.reserve(10);
        for (int i = 4; i < 10; i++) {
          numbers.push_back(i * 2);
        }
        assert(numbers[6] == 12);
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cc", "-I#{include}", "-L#{lib}",
                    "-lfolly", "-o", "test"
    system "./test"
  end
end
