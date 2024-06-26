{pkgs, ...}: owner: ''
  mkdir -p /home/${owner}/brain
  mkdir -p /home/${owner}/CTF
  mkdir -p /home/${owner}/ITU
  mkdir -p /home/${owner}/Documents

  setfacl=${pkgs.acl}/bin/setfacl

  $setfacl -Rdm u:syncthing:rwx /home/${owner}/brain
  $setfacl -Rdm u:syncthing:rwx /home/${owner}/CTF
  $setfacl -Rdm u:syncthing:rwx /home/${owner}/ITU
  $setfacl -Rdm u:syncthing:rwx /home/${owner}/Documents
  $setfacl -Rm u:syncthing:rwx /home/${owner}/brain
  $setfacl -Rm u:syncthing:rwx /home/${owner}/CTF
  $setfacl -Rm u:syncthing:rwx /home/${owner}/ITU
  $setfacl -Rm u:syncthing:rwx /home/${owner}/Documents

  $setfacl -Rdm u:${owner}:rwx /home/${owner}/brain
  $setfacl -Rdm u:${owner}:rwx /home/${owner}/CTF
  $setfacl -Rdm u:${owner}:rwx /home/${owner}/ITU
  $setfacl -Rdm u:${owner}:rwx /home/${owner}/Documents
  $setfacl -Rm u:${owner}:rwx /home/${owner}/brain
  $setfacl -Rm u:${owner}:rwx /home/${owner}/CTF
  $setfacl -Rm u:${owner}:rwx /home/${owner}/ITU
  $setfacl -Rm u:${owner}:rwx /home/${owner}/Documents

  $setfacl -m u:syncthing:--x /home/${owner}
''
