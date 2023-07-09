# Replace common utilites with busybox
(final: prev: {
  # Not working
  # coreutils = prev.busybox;
  # gnugrep = prev.busybox;
  # findutils = prev.busybox;
  # shadow = prev.busybox // { su = prev.busybox; };

  # Working
  # nettools = prev.busybox;
  # util-linux = prev.busybox // { override = {...}: prev.busybox; };
  # util-linuxMinimal = prev.busybox;
})
