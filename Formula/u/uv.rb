class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.4.26.tar.gz"
  sha256 "a85767a9a230216774a9b57b8b29f09a255074ad3216e9502090a4a03cd2a494"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5b74f118e69703ae6742884d3d05b2e41e718f2685a7316bf22cc0864d4819f7"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f263b7ab8bc98735eaa23934190ba5f98de0a2085101cc6bcc78f993a2a737b0"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "1b9b65e640d2b71e3528b979bc884c160d6534b0f598300ca5dc6974245c1150"
    sha256 cellar: :any_skip_relocation, sonoma:        "9187feb6ba82f88b85c0b3ffbdbc0fb553e5957f0239e38042d2734d5b954ac1"
    sha256 cellar: :any_skip_relocation, ventura:       "7522ef68b64a19116b19122f2c6373ef8db9558163256fd1931fb23ec4d9ee63"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5d051f613c7f11304efe1ecc8b55317766f69225bdbe31d670b6675a6c610d06"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "bzip2"
  uses_from_macos "xz"

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
    generate_completions_from_executable(bin/"uvx", "--generate-shell-completion", base_name: "uvx")
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
