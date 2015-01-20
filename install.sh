#!/bin/bash

PWD=`pwd`
BIN_PATH=${HOME}/.local/bin

mkdir -p $BIN_PATH

cat > $BIN_PATH/pm << EOF
#!/bin/bash

cd $PWD
./pm.pl "\$@"
cd - >/dev/null 2>/dev/null
EOF

chmod +x $BIN_PATH/pm

echo "Please add $BIN_PATH to your \$PATH variable"
