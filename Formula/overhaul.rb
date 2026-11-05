# Homebrew formula for Overhaul (tap: whitte-h/tap, `brew install whitte-h/tap/overhaul`).
# Template: scripts/homebrew.mjs fills 0.2.0 and each executable's sha256 from a release's
# .sha256 files; the release workflow attaches the result (overhaul.rb) and, with a tap token,
# commits it to the tap as Formula/overhaul.rb.
class Overhaul < Formula
  desc "Per-project agent orchestrator over tmux and Orca"
  homepage "https://github.com/whitte-h/overhaul"
  version "0.2.0"

  on_macos do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.0/overhaul-darwin-arm64"
      sha256 "114ccdccd89f0c3127cfb165cc066fd1ade06340ad6acfa7b6302164629fc6d5"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.0/overhaul-darwin-x64"
      sha256 "ce49fbc4d1899e52b4dc7bf62655066a24206dd709dcfd0781121b2e627a2658"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.0/overhaul-linux-arm64"
      sha256 "797b18354ccafe44120dd1653c005604073ab62073736625fdc58afbf382fda9"
    end
    on_intel do
      url "https://github.com/whitte-h/overhaul/releases/download/v0.2.0/overhaul-linux-x64"
      sha256 "9d51b1f4e9a32f19c75c99d99a16e60e22b9f8f242378e0b9bce92fa8527d33d"
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
        overhaul init
        overhaul set-password
        overhaul service install
      An earlier installation (~/.config/overhaul, work-hub) is moved into ~/.overhaul, with a backup.
      Update with `brew upgrade overhaul`, then `overhaul service restart`.
      The desktop helper still needs Node: `overhaul helper install`.
    EOS
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/overhaul version").strip
    ENV["OVERHAUL_HOME"] = testpath/"oh"
    system bin/"overhaul", "init"
    assert_path_exists testpath/"oh/config.yaml"
  end
end
