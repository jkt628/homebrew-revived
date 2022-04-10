class ConfluentPlatform < Formula
  desc "Developer-optimized distribution of Apache Kafka"
  homepage "https://www.confluent.io/product/confluent-platform/"
  url "https://packages.confluent.io/archive/7.1/confluent-community-7.1.0.tar.gz"
  version "7.1.0"
  sha256 "a2ca9c0a0a4f8428bc5510279991c801af1706d16e9fd725156522aa9e01461f"

  livecheck do
    url "https://docs.confluent.io/platform/#{version}/release-notes/changelog.html"
    regex(/>Version (\d+(?:\.\d+)+)</i)
  end

  bottle :unneeded

  disable! date: "2999-12-31", because: "does not have an OSI license"

  depends_on "jenv" => :recommended

  conflicts_with "kafka", because: "kafka also ships with identically named Kafka related executables"

  def install
    libexec.install %w[bin etc share]
    rm_rf libexec/"bin/windows"

    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      confluent-platform requires Java 11 and is known to fail with some versions >= 13.
      Package "jenv" is recommended to wrangle multiple versions of Java.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kafka-broker-api-versions --version")

    # The executable "confluent" tries to create .confluent under the home directory
    # without considering the envrionment variable "HOME", so the execution will fail
    # due to sandbox-exec.
    # The message "unable to load config" means that the execution will succeed
    # if the user has write permission.
    assert_match(/Confluent Platform|unable to load config/, shell_output("#{bin}/confluent 2>&1", 1))

    assert_match "usage: confluent-hub", shell_output("#{bin}/confluent-hub help")
  end
end
