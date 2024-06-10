{pkgs, ...}: ''
  mkdir -p /home/color/brain
  mkdir -p /home/color/CTF
  mkdir -p /home/color/ITU

  setfacl=${pkgs.acl}/bin/setfacl

  $setfacl -Rdm u:syncthing:rwx /home/color/brain
  $setfacl -Rdm u:syncthing:rwx /home/color/CTF
  $setfacl -Rdm u:syncthing:rwx /home/color/ITU
  $setfacl -Rm u:syncthing:rwx /home/color/brain
  $setfacl -Rm u:syncthing:rwx /home/color/CTF
  $setfacl -Rm u:syncthing:rwx /home/color/ITU

  $setfacl -m u:syncthing:--x /home/color
''
