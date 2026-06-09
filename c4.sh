sed -i '/alias patch='\''patch --force'\''/d;/alias repo-init='\''repo init --depth=1'\''/d' ~/.bashrc
sed -i '/^case $- in/,/^esac$/d' ~/.bashrc
 
echo "Non-interactive shell check removed from ~/.bashrc"
 
# Define aliases directly in current shell
alias patch='patch --force'
alias repo-init='repo init --depth=1'
 
# Also add to bashrc for future sessions
cat >> ~/.bashrc << 'EOF'
 
# Custom aliases
alias patch='patch --force'
alias repo-init='repo init --depth=1'
EOF
 
# Verify aliases are set
echo "Checking if aliases are defined:"
alias | grep patch
alias | grep repo-init
