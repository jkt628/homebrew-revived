class ConfluentPlatform < Formula
  desc "Developer-optimized distribution of Apache Kafka"
  homepage "https://www.confluent.io/product/confluent-platform/"
  url "https://packages.confluent.io/archive/7.6/confluent-community-7.6.1.tar.gz"
  sha256 "ae9a81f3cc914a21b977abeff1fa4778bf79a2c2dc8f5fc822e2da15d960bb92"

  livecheck do
    url "https://docs.confluent.io/platform/#{version}/release-notes/changelog.html"
    regex(/>Version (\d+(?:\.\d+)+)</i)
  end

  disable! date: "2999-12-31", because: "does not have an OSI license"

  conflicts_with "kafka", because: "kafka also ships with identically named Kafka related executables"

  def install
    libexec.install %w[bin etc share]
    rm_rf libexec/"bin/windows"

    bin.write_exec_script Dir["#{libexec}/bin/*"]
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
