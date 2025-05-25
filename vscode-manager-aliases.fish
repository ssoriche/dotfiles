# Add to your fish config
# VS Code Settings Management with Extensions
alias vscode-manage='~/.local/share/chezmoi/manage-vscode-settings.fish'
alias vscode-setup='vscode-manage setup all'
alias vscode-diff='vscode-manage diff all'
alias vscode-apply='vscode-manage apply all'
alias vscode-status='vscode-manage status'
alias vscode-sync='vscode-manage sync-extensions all'

# Editor-specific shortcuts
alias cursor-setup='vscode-manage setup cursor'
alias cursor-diff='vscode-manage diff cursor'
alias cursor-apply='vscode-manage apply cursor'
alias cursor-sync='vscode-manage sync-extensions cursor'

alias codium-setup='vscode-manage setup codium'
alias codium-diff='vscode-manage diff codium'
alias codium-apply='vscode-manage apply codium'
alias codium-sync='vscode-manage sync-extensions codium'
