# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.silentSDDM.nixosModules.default
    ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelModules = ["ntsync"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    luksroot = {
       device = "/dev/disk/by-uuid/85719e7e-dcea-4a0a-afe1-d0c796b0e59d";
       preLVM = true;
       allowDiscards = true;
    };
};
   networking.hostName = "chapel"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
   networking.networkmanager.enable = true;

  # Set your time zone.
   time.timeZone = "Asia/Dubai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };
 
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sree = {
     isNormalUser = true;
     description = "Sree";
     extraGroups = [ "wheel" "video" "input" "networkmanager" "libvirtd" "render"]; # Enable ‘sudo’ for the user.
     shell = pkgs.bash;
        home = "/home/sree";
  };

  programs.virt-manager.enable = true;

  programs.firefox.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.dconf.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;



  programs.silentSDDM = {
    enable = true;
    theme = "default";
    settings = { 
	"General" = {
		background_fill_mode = "crop";
	};
    };
  };


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      vim
      wget
      pkgs.sbctl
      git
      glib
      gsettings-desktop-schemas
      pkgs.opencode
      pkgs.dconf
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      ddcutil
      pkgs.seahorse
      gnome-keyring
      libsecret
      pkgs.nwg-look
      hyprpolkitagent
      adw-gtk3
      qt6Packages.qt6ct
      openrgb-with-all-plugins
      qemu
      quickemu
      (heroic.override {
      extraPkgs = pkgs: with pkgs; [
        gamescope
        gamemode
      ];
    })
    ];

nixpkgs.config.permittedInsecurePackages = [
  "electron-39.8.10"
];

  environment.sessionVariables = {
	NIXOS_OZONE_WL = "1";
	FREETYPE_PROPERTIES = "autofitter:darkening-parameters=500,300,1000,200 autofitter:no-stem-darkening=0";
	SDL_VIDEODRIVER = "wayland";
  };

   nixpkgs.config.allowUnfree = true; # To allow unfree packages

  #Hardware
    hardware.graphics = {
	enable = true;
	enable32Bit = true;
    };
	# Nvidia
	   services.xserver.videoDrivers = ["nvidia"];
	   hardware.nvidia = {
	         modesetting.enable = true;
        	 powerManagement.enable = true;
                 nvidiaPersistenced = true;
	         open = false;
	   };
     hardware.bluetooth.enable = true;

  # XDG Portal

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk 
    ];
   config = {
     hyprland = {
       default = [ "hyprland" "gtk" ];
       "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
    };
  };
     };

  services.displayManager.sddm = {
    enable = true;

  # Enables experimental Wayland support
    wayland.enable = true;
  };

 # Nix Settings
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ "root" "sree" ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Font
    fonts.fontconfig = {
      enable = true;
      hinting = {
        enable = true;
        style = "slight";
     };
    subpixel.rgba = "none";
    };

    fonts.packages = with pkgs; [
 	 inter
 	 geist-font
 	 jetbrains-mono
 	 iosevka
 	 noto-fonts
 	 noto-fonts-color-emoji
	 nerd-fonts.jetbrains-mono
    ];

    virtualisation.libvirtd = {
	enable = true;
	qemu = {
	#    package = pkgs.qemu_kvm;   # leaner KVM-only build
#	    runAsRoot = true;
	    swtpm.enable = true;       # TPM emulation (needed for Win11)
	};
    };
  # List services that you want to enable:
    services.power-profiles-daemon.enable = true;
    services.dbus.packages = [ pkgs.gsettings-desktop-schemas ];
    services.displayManager.defaultSession = "hyprland";
    services.gnome.gnome-keyring.enable = true;
    services.hardware.openrgb.enable = true;

  # Systemd Services
  systemd.services.nvidia-power-limit = {
    description = "Set NVIDIA GPU Power Limit";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 314";
    };
  };
  # Security
    security.pam.services.sddm.enableGnomeKeyring = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

