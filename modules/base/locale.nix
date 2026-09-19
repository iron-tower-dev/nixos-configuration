{ ... }:
let
  moduleBody = { ... }: {
    config = {
      time.timeZone = "UTC";
      i18n.defaultLocale = "en_US.UTF-8";
      services.xserver.xkb.layout = "us";
      console.keyMap = "us";
    };
  };
in
{
  flake.nixosModules.locale = moduleBody;
}
