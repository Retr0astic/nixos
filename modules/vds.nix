{ config, pkgs, lib, inputs, ... }:

let
  vds-src = inputs.vds-src;
  version = vds-src.shortRev or "unknown";

  vds = pkgs.stdenv.mkDerivation {
    pname   = "vds";
    inherit version;
    src     = vds-src;

    nativeBuildInputs = with pkgs; [ cmake pkg-config gitMinimal ];
    buildInputs       = with pkgs; [ libopus systemd.dev dbus bluez ];

    cmakeFlags = [ "-DINSTALL_SERVICE=NO" ];

    postPatch = ''
      sed -i \
        's/execute_process(COMMAND git describe[^)]*)/set(VDS_GIT_VERSION "${version}")/g' \
        CMakeLists.txt || true
    '';

    postInstall = ''
      install -Dm644 ${vds-src}/99-vds-dualsense-udev.rules \
        $out/lib/udev/rules.d/99-vds-dualsense-udev.rules
      install -Dm644 ${vds-src}/99-vds-dualsense-wireplumber.conf \
        $out/share/vds/99-vds-dualsense-wireplumber.conf
    '';

    meta = with lib; {
      description = "vDS userspace daemon and CLI for DualSense USB-Bluetooth bridge";
      homepage    = "https://github.com/hurryman2212/vds";
      license     = licenses.gpl2Only;
      mainProgram = "vdsd";
    };
  };

  vdsHcd = config.boot.kernelPackages.callPackage
    ({ lib, stdenv, kernel }: stdenv.mkDerivation {
      pname   = "vds-hcd";
      inherit version;
      src     = vds-src;

      nativeBuildInputs = kernel.moduleBuildDependencies;

      postPatch = ''
        patchShebangs .
      '';

      # Call the kernel build system directly with M= pointing at the module
      # directory. This bypasses the wrapper Makefile entirely and avoids the
      # uname -r sandbox problem — the standard approach in nixpkgs.
      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$(pwd)/module \
          KERNELRELEASE=${kernel.modDirVersion} \
          modules
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        install -Dm644 module/vds_hcd.ko \
          $out/lib/modules/${kernel.modDirVersion}/misc/vds_hcd.ko
        runHook postInstall
      '';

      meta = with lib; {
        description = "vDS virtual USB HCD kernel module (vds_hcd.ko)";
        license     = licenses.gpl2Only;
      };
    }) {};

in {

  boot.extraModulePackages = [ vdsHcd ];
  boot.kernelModules       = [ "vds_hcd" ];

  environment.systemPackages = [ vds ];

  systemd.services.vdsd = {
    description   = "vDS DualSense USB-Bluetooth bridge daemon";
    after         = [ "bluetooth.service" ];
    requires      = [ "bluetooth.service" ];
    wantedBy      = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart      = "${vds}/bin/vdsd";
      Restart        = "on-failure";
      StateDirectory = "vds";
    };
  };

  # ⚠ Disables BlueZ input plugin — breaks all other BT HID devices
  # (mice, keyboards) while vdsd is running. Upstream patch in progress.
  hardware.bluetooth.disabledPlugins = [ "input" ];

  services.udev.packages = [ vds ];

  home-manager.users.sree = {
    xdg.configFile."wireplumber/wireplumber.conf.d/99-vds-dualsense-wireplumber.conf".source =
      "${vds}/share/vds/99-vds-dualsense-wireplumber.conf";

    systemd.user.services.wireplumber.restartTriggers = {
      vdsConf = "${vds}/share/vds/99-vds-dualsense-wireplumber.conf";
    };
  };

}
