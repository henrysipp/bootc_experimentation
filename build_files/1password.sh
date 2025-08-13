#!/bin/bash
# Ensure /var/opt exists so /opt/1Password can be created by the RPM
dnf5 install -y 1password-cli 1password
# Move 1Password from /opt/
# Needed on Silverblue because Silverblue treats /opt/ as persistent.
# The bootc images do not.
mv /var/opt/1Password /usr/lib/1Password
rm /usr/bin/1password
ln -s /usr/lib/1Password/1password /usr/bin/1password
GID_ONEPASSWORD=1001
# Any available value over 1000 should do
GID_ONEPASSWORDCLI=1019
chgrp "${GID_ONEPASSWORD}" /usr/lib/1Password/1Password-BrowserSupport
chmod g+s /usr/lib/1Password/1Password-BrowserSupport
chgrp "${GID_ONEPASSWORDCLI}" /usr/bin/op
chmod g+s /usr/bin/op
# Dynamically create the required groups via sysusers.d
# and set the GID based on the files we just chgrp'd
cat >/usr/lib/sysusers.d/onepassword.conf <<EOF
g onepassword ${GID_ONEPASSWORD}
EOF
cat >/usr/lib/sysusers.d/onepassword-cli.conf <<EOF
g onepassword-cli ${GID_ONEPASSWORDCLI}
EOF
# remove the sysusers.d entries created by onepassword RPMs.
# They don't magically set the GID like we need them to.
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword.conf
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword-cli.conf
# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/onepassword.conf <<EOF
L  /opt/1Password  -  -  -  -  /usr/lib/1Password
EOF