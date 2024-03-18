repo sync -j1 --fail-fast | grep 'Failing repos:' | xargs -I {} rm -rf {}
