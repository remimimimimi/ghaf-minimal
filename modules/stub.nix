{lib, ...}: with lib; {
  options = {
    boot.initrd.luks = mkEnableOption "luks";
  };
}
