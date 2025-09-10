if [ -d "$HOME/.config/autostart" ]; then
    for file in $HOME/.config/autostart/*; do
        command=$(cat $file | grep '^Exec=' | head -n 1 | cut -d '=' -f 2-)
        $command&
    done
fi
