class Shaderc < Formula
  desc "Collection of tools, libraries, and tests for Vulkan shader compilation"
  homepage "https://github.com/google/shaderc"
  license "Apache-2.0"

  stable do
    url "https://github.com/google/shaderc/archive/refs/tags/v2023.8.tar.gz"
    sha256 "dfec5045f30d8f6d3d3914ab5b3cc2695947f266d41261b1459177cd789308d1"

    resource "glslang" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/glslang.git",
          revision: "a91631b260cba3f22858d6c6827511e636c2458a"
    end

    resource "spirv-headers" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/SPIRV-Headers.git",
          revision: "1c6bb2743599e6eb6f37b2969acc0aef812e32e3"
    end

    resource "spirv-tools" do
      # https://github.com/google/shaderc/blob/known-good/known_good.json
      url "https://github.com/KhronosGroup/SPIRV-Tools.git",
          revision: "f0cc85efdbbe3a46eae90e0f915dc1509836d0fc"
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "33f9f476a1a57bb93e019deffadc69e788b1581e17df9f98f4648d053f83b424"
    sha256 cellar: :any,                 arm64_ventura:  "f72e5f7f0da8b9b82cc8ca890760c6b33b1f5e041e3dcc1bdfc60c321ded25db"
    sha256 cellar: :any,                 arm64_monterey: "b5c8b42e754bf4f348514efc19db6fb073d66f09447677f7e18d5b6dc3b7f64d"
    sha256 cellar: :any,                 sonoma:         "271b067ae2f1438a5b2271b3a8d95d333f5658806677dfd590bf3d4db3fe89c3"
    sha256 cellar: :any,                 ventura:        "953b737d858fb1a319d43e80b5231fdd8857775e9a489b464185d735d2085402"
    sha256 cellar: :any,                 monterey:       "b47422248e90574c2d641f88c48491a3de899649c5a713d2655f88ec1426ff43"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "33e4d6ffb6dade9df0ed5aecb7e5538e5306638fccedc1f364fafdcef3744ecc"
  end

  head do
    url "https://github.com/google/shaderc.git", branch: "main"

    resource "glslang" do
      url "https://github.com/KhronosGroup/glslang.git", branch: "main"
    end

    resource "spirv-tools" do
      url "https://github.com/KhronosGroup/SPIRV-Tools.git", branch: "main"
    end

    resource "spirv-headers" do
      url "https://github.com/KhronosGroup/SPIRV-Headers.git", branch: "main"
    end
  end

  depends_on "cmake" => :build
  depends_on "python@3.12" => :build

  def install
    resources.each do |res|
      res.stage(buildpath/"third_party"/res.name)
    end

    # Avoid installing packages that conflict with other formulae.
    inreplace "third_party/CMakeLists.txt", "${SHADERC_SKIP_INSTALL}", "ON"
    system "cmake", "-S", ".", "-B", "build",
                    "-DSHADERC_SKIP_TESTS=ON",
                    "-DSKIP_GLSLANG_INSTALL=ON",
                    "-DSKIP_SPIRV_TOOLS_INSTALL=ON",
                    "-DSKIP_GOOGLETEST_INSTALL=ON",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <shaderc/shaderc.h>
      int main() {
        int version;
        shaderc_profile profile;
        if (!shaderc_parse_version_profile("450core", &version, &profile))
          return 1;
        return (profile == shaderc_profile_core) ? 0 : 1;
      }
    EOS
    system ENV.cc, "-o", "test", "test.c", "-I#{include}",
                   "-L#{lib}", "-lshaderc_shared"
    system "./test"
  end
end
