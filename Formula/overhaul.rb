# Homebrew formula for Overhaul (tap: whitte-h/tap, `brew install whitte-h/tap/overhaul`).
# Template: scripts/homebrew.mjs fills in the version and each executable's sha256 from a release's
# .sha256 files; the release workflow attaches the result (overhaul.rb) and, with a tap token,
# commits it to the tap as Formula/overhaul.rb.
class Overhaul < Formula
  desc "Per-project agent orchestrator over tmux and Orca"
  homepage "https://github.com/whitte-h/overhaul"
  version "0.2.1"

  on_macos do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.1/overhaul-darwin-arm64"
      sha256 "f695e997665b4eebc30819d893b4bb8f03473b25e7693e285e9cbf25b36b12a0"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.1/overhaul-darwin-x64"
      sha256 "8dde34309bb7f858a77fd1558bced82f7e4072020c0026a6c2bb0821b48b11a1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.1/overhaul-linux-arm64"
      sha256 "3ad45cc84109c7d71ba70d78eb8baf36512509f8de52cce56de920f810bb2a3c"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.1/overhaul-linux-x64"
      sha256 "ed44514044027eefb60cc96ba892f1752d0cc027766461cc22ee8470e386a656"
    end
  end

  def install
    bin.install Dir["overhaul-*"].first => "overhaul"
  end

  # `brew services start overhaul` runs the hub only. `overhaul service install` runs the hub and
  # its bridge as user services instead (recommended); use one or the other, not both.
  service do
    run [opt_bin/"overhaul", "serve"]
    keep_alive true
    log_path var/"log/overhaul.log"
    error_log_path var/"log/overhaul.log"
  end

  def caveats
    <<~EOS
      Set up and start the hub and its bridge (user services, data in ~/.overhaul):
        overhaul setup
        overhaul set-password
        overhaul service install
      Then add each project from its folder (a repo, or a folder with several):
        cd ~/code/myproject && overhaul init
      An earlier installation (~/.config/overhaul, work-hub) is moved into ~/.overhaul, with a backup.
      Update with `brew upgrade overhaul`, then `overhaul service restart`.
      The desktop helper still needs Node: `overhaul helper install`.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/overhaul version").strip
    ENV["OVERHAUL_HOME"] = testpath/"oh"
    system bin/"overhaul", "setup"
    assert_path_exists testpath/"oh/config.yaml"
  end
end
