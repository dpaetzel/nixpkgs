{ config, lib, pkgs, ... }:
let
  cfg = config.services.clipmenu;
in {

  options.services.clipmenu = {
    enable = lib.mkEnableOption "clipmenu, the clipboard management daemon";

    syncPrimaryToClipboard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether clipmenud should sync the primary selection to the clipboard
        selection.
      '';
    };

    syncClipboardToPrimary = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether clipmenud should sync the clipboard selection to the primary
        selection.
      '';
    };

    package = lib.mkPackageOption pkgs "clipmenu" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.clipmenu = {
      enable      = true;
      environment = {
        CM_SYNC_PRIMARY_TO_CLIPBOARD = if cfg.syncPrimaryToClipboard then "1" else "0";
        CM_SYNC_CLIPBOARD_TO_PRIMARY = if cfg.syncClipboardToPrimary then "1" else "0";
      };
      description = "Clipboard management daemon";
      wantedBy = [ "graphical-session.target" ];
      after    = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${cfg.package}/bin/clipmenud";
    };

    environment.systemPackages = [ cfg.package ];
  };
}
