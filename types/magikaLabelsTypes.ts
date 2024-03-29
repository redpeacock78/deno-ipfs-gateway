const types: { [key: string]: string[] } = {
  "application/x-plist": ["appleplist"],
  "text/html": ["asp"],
  "text/x-msdos-batch": ["batch"],
  "application/x-bzip2": ["bzip"],
  "application/x-coff": ["coff"],
  "text/plain": ["cs", "symlinktext"],
  "application/vnd.debian.binary-package": ["deb"],
  "application/x-android-dex": ["dex"],
  "inode/directory": ["directory"],
  "application/x-executable-elf": ["elf", "odex"],
  "text/x-golang": ["go"],
  "application/gzip": ["gzip"],
  "application/x-mswinurl": ["internetshortcut"],
  "application/x-iso9660-image": ["iso"],
  "application/x-java-applet": ["javabytecode"],
  "application/javascript": ["javascript"],
  "text/x-lisp": ["lisp"],
  "application/x-mach-o": ["macho"],
  "text/x-makefile": ["makefile"],
  "application/x-mimearchive": ["mht"],
  "application/x-ms-compress-szdd": ["mscompress"],
  "application/x-msi": ["msi"],
  "text/xml": ["mum"],
  "application/vnd.ms-outlook": ["outlook"],
  "application/x-dosexec": ["pebin"],
  "text/x-perl": ["perl"],
  "application/postscript": ["postscript"],
  "application/x-powershell": ["powershell"],
  "text/x-python": ["python"],
  "application/x-bytecode.python": ["pythonbytecode"],
  "text/x-rst": ["rst"],
  "application/x-ruby": ["ruby"],
  "application/x-rust": ["rust"],
  "application/x-scala": ["scala"],
  "application/x-7z-compressed": ["sevenzip"],
  "text/x-shellscript": ["shell"],
  "application/x-smali": ["smali"],
  "application/octet-stream": ["squashfs"],
  "text/vbscript": ["vba"],
  "text/x-ms-regedit": ["winregistry"],
  "application/zlib": ["zlibstream"],
};
Object.freeze(types);
export default types;
