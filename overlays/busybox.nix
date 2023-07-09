# Replace common utilites with busybox
(final: prev: {
  coreutils = prev.busybox;
  gnugrep = prev.busybox;
  findutils = prev.busybox;
  shadow = prev.busybox;
  nettools = prev.busybox;
  util-linux = prev.busybox;
})
