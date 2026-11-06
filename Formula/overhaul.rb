# Homebrew formula for Overhaul (tap: whitte-h/tap, `brew install whitte-h/tap/overhaul`).
# Template: scripts/homebrew.mjs fills in the version and each executable's sha256 from a release's
# .sha256 files; the release workflow attaches the result (overhaul.rb) and, with a tap token,
# commits it to the tap as Formula/overhaul.rb.
class Overhaul < Formula
  desc "Per-project agent orchestrator over tmux and Orca"
  homepage "https://github.com/whitte-h/overhaul"
  version "0.3.2"

  on_macos do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.3.2/overhaul-darwin-arm64"
      sha256 "960ab0d0f322c3befcb3bb0ca27c6748a597531e0a26a2d00ba9359900680c38"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.3.2/overhaul-darwin-x64"
      sha256 "ec2a8d6ce818707f573fb314714b6878bcbc2194a95fd9229cd7cdd31cd8aac1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.3.2/overhaul-linux-arm64"
      sha256 "bf0a6c4e654722d7c6c9edeb1c6d56adda1f00ce1caf8db5c5ba88c96e4fe3d1"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.3.2/overhaul-linux-x64"
      sha256 "75957f36c82488a37aa3bcd0e20aa0c8afda687c4050f0710286f45111241751"
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
