{...}: {
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      adjust-open = "width";
      recolor = true;
    };
  };
}
