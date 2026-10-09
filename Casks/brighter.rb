cask "brighter" do
  version "1.0.0"
  sha256 "ebc74f8156e96841dcdf6d46c4d8fff6049d22eddd4609efa5f71bae895e4ed3"

  url "https://github.com/developcu/brighter/releases/download/v#{version}/Brighter.zip"
  name "Brighter"
  desc "Menu bar HDR brightness control for built-in XDR displays"
  homepage "https://github.com/developcu/brighter"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Brighter.app"

  caveats <<~EOS
    HDR boost requires a compatible built-in XDR display, such as the
    Liquid Retina XDR display on an Apple silicon 14-inch or 16-inch MacBook Pro.
    External displays and SDR-only displays are not supported.
  EOS
end
