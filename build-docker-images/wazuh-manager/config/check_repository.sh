## variables
GPG_SIGN='[arch=amd64 signed-by=/etc/apt/keyrings/wazuh.gpg]'
APT_KEY=https://packages.wazuh.com/key/GPG-KEY-WAZUH
REPOSITORY="deb ${GPG_SIGN} https://packages.wazuh.com/4.x/apt/ stable main"
WAZUH_CURRENT_VERSION=$(curl --silent https://api.github.com/repos/wazuh/wazuh/releases/latest | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\1/' | cut -c 2-)
MAJOR_BUILD=$(echo $WAZUH_VERSION | cut -d. -f1)
MID_BUILD=$(echo $WAZUH_VERSION | cut -d. -f2)
MINOR_BUILD=$(echo $WAZUH_VERSION | cut -d. -f3)
MAJOR_CURRENT=$(echo $WAZUH_CURRENT_VERSION | cut -d. -f1)
MID_CURRENT=$(echo $WAZUH_CURRENT_VERSION | cut -d. -f2)
MINOR_CURRENT=$(echo $WAZUH_CURRENT_VERSION | cut -d. -f3)

## check version to use the correct repository
if [ "$MAJOR_BUILD" -gt "$MAJOR_CURRENT" ]; then
  APT_KEY=https://packages-dev.wazuh.com/key/GPG-KEY-WAZUH
  REPOSITORY="deb ${GPG_SIGN} https://packages-dev.wazuh.com/staging/apt/ unstable main"
elif [ "$MAJOR_BUILD" -eq "$MAJOR_CURRENT" ]; then
  if [ "$MID_BUILD" -gt "$MID_CURRENT" ]; then
    APT_KEY=https://packages-dev.wazuh.com/key/GPG-KEY-WAZUH
    REPOSITORY="deb ${GPG_SIGN} https://packages-dev.wazuh.com/staging/apt/ unstable main"
  elif [ "$MID_BUILD" -eq "$MID_CURRENT" ]; then
    if [ "$MINOR_BUILD" -gt "$MINOR_CURRENT" ]; then
      APT_KEY=https://packages-dev.wazuh.com/key/GPG-KEY-WAZUH
      REPOSITORY="deb ${GPG_SIGN} https://packages-dev.wazuh.com/staging/apt/ unstable main"
    fi
  fi
fi

curl ${APT_KEY} | gpg --dearmor -o /etc/apt/keyrings/wazuh.gpg
echo ${REPOSITORY} | tee -a /etc/apt/sources.list.d/wazuh.list