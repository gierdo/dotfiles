# Get cdk completions and always use cdk from the project context, if available
_cdk_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" cdk --get-yargs-completions "${words[@]}"))
  IFS=$si
  _describe 'values' reply
}
compdef _cdk_yargs_completions cdk

cdk() { npx -- cdk "$@" }
if command -v flatpak 1>/dev/null 2>&1; then
  _load_zsh_plugin "flatpak-zsh-completion" "flatpak.plugin.zsh"
fi
